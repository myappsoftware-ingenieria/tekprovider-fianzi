# Despliegue de la plataforma Finzai en AWS (CloudFormation)

Plantilla de infraestructura que cubre los **puntos 1 al 9** de
`solicitud-infraestructura.md`. Región objetivo: **`mx-central-1`** (México Central).

## Qué crea

| Punto | Recursos |
|---|---|
| 1. Red | VPC `/16`, 2 subredes públicas, 2 de aplicación, 2 de datos (multi-AZ), IGW, **un** NAT Gateway con EIP, tablas de ruteo |
| 2. Grupos de seguridad | `alb`, `ecs`, `rds`, `efs` con las reglas de la solicitud |
| 3. Entrada | Certificado ACM (si hay subdominio), ALB internet-facing, listeners 80/443, target group tipo IP con health check `GET /salud`, registro DNS opcional |
| 4. ECS | Clúster Fargate, namespace de Service Connect, rol de ejecución (+ lectura de secretos), rol de tarea (ECS Exec), log group `/ecs/finzai-<ambiente>` (30 días), repositorio ECR `finzai-nginx` |
| 5. RDS | PostgreSQL 14, `db.t4g.medium`, una zona, gp3 cifrado 20→50 GB, backups 7 días, protección de borrado, sin acceso público |
| 6. EFS | Sistema de archivos cifrado, mount targets en ambas subredes de datos, access point `/FinzaiDocs` (POSIX 1000, permisos 755) |
| 7. Secretos | `bd-cadena-conexion`, `iam-key-protection`, `dockerhub` (marcadores) y `rds-master` (contraseña generada) |
| 9. Operador | Política administrada con los permisos del punto 9 (se adjunta aparte al principal) |

**No** incluye: las 31 definiciones de tarea/servicios (punto 4.7 detalle), la instancia de carga inicial (punto 8), ni los recomendados (punto 10). Eso lo opera el solicitante.

## Requisitos previos

1. AWS CLI v2 configurada con permisos de administración en la cuenta.
2. Confirmar que **EFS** está disponible en `mx-central-1` (ya validado por ti).
3. La región debe exponer al menos 2 zonas de disponibilidad (ALB y RDS lo exigen).

## Desplegar

```powershell
.\desplegar.ps1 `
    -Environment finzai-demo `
    -Subdomain finzai-demo.tekprovider.net `
    -HostedZoneId Z0123456789ABCDEFGHIJ `
    -OperatorArn arn:aws:iam::111122223333:user/cflores `
    -AllowedIngress "203.0.113.10/32"
```

O directamente con la CLI:

```powershell
aws cloudformation deploy `
    --stack-name finzai-demo `
    --template-file finzai-plataforma.yaml `
    --region mx-central-1 `
    --capabilities CAPABILITY_NAMED_IAM `
    --parameter-overrides EnvironmentName=finzai-demo AllowedIngressCidr="203.0.113.10/32"
```

### Parámetros clave

- `EnvironmentName` — prefijo de nombres y de los ARN de secretos (`finzai/<ambiente>/...`).
- `Subdomain` / `HostedZoneId` — déjalos vacíos si el dominio aún no se define: el ALB queda solo con listener 80 reenviando a nginx, sin certificado ni DNS. Al tener dominio, re-despliega con ambos y el listener 80 pasa a redirigir a 443.
- `OperatorPrincipalArn` — ARN de cflores. La plantilla crea la política pero **no la adjunta** (no sabe si es usuario o rol). Tras desplegar, adjúntala con el ARN de la salida `OperatorPolicyArn`.
- `AllowedIngressCidr` — un CIDR de origen permitido al ALB; por omisión `0.0.0.0/0` (abierto): restríngelo antes de producción. Para varios rangos, ver el aviso de lista de prefijos al final.

## Después de desplegar

1. Adjunta la política de operador:
   ```powershell
   aws iam attach-user-policy --user-name cflores --policy-arn <OperatorPolicyArn>
   ```
2. Carga los valores reales en los secretos (`bd-cadena-conexion`, `iam-key-protection`, y `dockerhub` si aplica). La contraseña maestra de RDS ya quedó generada en `rds-master`.
3. Las salidas de la pila entregan los 10 datos del punto 12 de la solicitud (IDs de subredes, ARN de roles, endpoint de RDS, etc.).

## Eliminar

```powershell
aws cloudformation delete-stack --stack-name finzai-demo --region mx-central-1
```

RDS tiene `DeletionPolicy: Snapshot` y `DeletionProtection: true`: para borrarla debes desactivar la protección primero. El snapshot final se conserva.

## Rol vinculado al servicio ECS (importante en cuentas/regiones nuevas)

ECS necesita el rol `AWSServiceRoleForECS` para crear el clúster y su
namespace de Service Connect. En una cuenta/región nueva ese rol puede no
existir todavía, y `CreateCluster` falla con:

> `ECS Service Linked Role is not ready in customers account`

La plantilla **no** crea ese rol (intentar crearlo cuando ya existe falla con
`AlreadyExists`). El enfoque robusto es crearlo **una sola vez por cuenta**,
fuera de la pila, antes del primer despliegue:

```powershell
# Si falla con "has been taken / already exists", ya existe: ignóralo y sigue.
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

Compruébalo con `aws iam get-role --role-name AWSServiceRoleForECS`. Una vez
que exista, el despliegue de la pila funciona sin cambios. El rol es global en
la cuenta: solo se crea una vez, no por región.

Si la pila quedó en `ROLLBACK_COMPLETE` tras un intento fallido, **no se puede
actualizar en ese estado**; bórrala y vuelve a crearla:

```powershell
aws cloudformation delete-stack --stack-name finzai-demo --region mx-central-1
aws cloudformation wait stack-delete-complete --stack-name finzai-demo --region mx-central-1
```

## Avisos

- **Versión de PostgreSQL:** la plantilla fija `14.19`. Verifica con `aws rds describe-db-engine-versions --engine postgres --region mx-central-1 --query "DBEngineVersions[].EngineVersion"` cuál es la versión menor 14 más reciente disponible en la región y ajústala si hace falta. PostgreSQL 14 pierde soporte comunitario en noviembre de 2026.
- **Costos:** el estimado de 450–500 USD/mes se calculó en `us-east-1`. En `mx-central-1` los precios difieren; confirma con la [calculadora de AWS](https://calculator.aws/).
- **Reglas de ingress del ALB:** esta versión expande un solo CIDR de la lista a reglas 80/443. Si necesitas varios rangos, lo más limpio es una lista de prefijos administrada (`AWS::EC2::PrefixList`); puedo añadirla si la quieres.
