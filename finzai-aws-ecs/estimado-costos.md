# Estimado de costos de infraestructura AWS — Finzai

**Proyecto:** Finzai en ECS Fargate con base en RDS
**Fecha del estimado:** 2026-10-13
**Base de cálculo:** precios de lista en `us-east-1`, 730 horas al mes (24/7), todo encendido todo el mes.

> Es una estimación de referencia. El dato firme sale de la [AWS Pricing Calculator](https://calculator.aws/)
> con la región que elija la organización. Los tamaños de las 31 tareas son iniciales (medidos en reposo) y
> se ajustan al ver el consumo real. Los precios de lista cambian con el tiempo.

## Resumen

| Concepto | USD/mes |
|---|---|
| ECS Fargate (8.5 vCPU + 31.5 GB en 31 tareas) | ≈ 353 |
| RDS PostgreSQL `db.t4g.medium` + almacenamiento | ≈ 50 |
| NAT Gateway (uno) | ≈ 33 + tráfico |
| Balanceador de aplicación (ALB) | ≈ 20 – 28 |
| EFS, secretos, bitácoras, ECR, Route 53 | ≈ 10 – 18 |
| **Total mensual recurrente** | **≈ 466 – 482** |

Esto confirma el rango de **450 – 500 USD/mes** de la solicitud. El cálculo cae en la mitad alta porque
incluye las LCU del balanceador y un margen para bitácoras y tráfico.

## 1. ECS Fargate — el componente dominante (~75% del costo)

31 tareas = 8.5 vCPU + 31.5 GB, una tarea deseada por servicio, siempre encendidas.
Precio Fargate `us-east-1`: $0.04048 por vCPU-hora y $0.004445 por GB-hora.

| Recurso | Cálculo | USD/mes |
|---|---|---|
| vCPU | 8.5 × $0.04048 × 730 h | 251.18 |
| Memoria | 31.5 × $0.004445 × 730 h | 102.21 |
| **Subtotal Fargate** | | **≈ 353** |

## 2. RDS PostgreSQL (`db.t4g.medium`, una sola zona)

| Recurso | Cálculo | USD/mes |
|---|---|---|
| Instancia `db.t4g.medium` (2 vCPU, 4 GB) | $0.065/h × 730 h | 47.45 |
| Almacenamiento gp3 (arranca en 20 GB, crece a 50) | ~20 GB × $0.115/GB | 2.30 |
| Respaldos automáticos (7 días, base de 3.6 GB) | dentro del margen gratuito aprox. | ~0 |
| **Subtotal RDS** | | **≈ 50** |

Si el almacenamiento crece al tope de 50 GB, suma unos +3.5 USD/mes.

## 3. Red

| Recurso | Cálculo | USD/mes |
|---|---|---|
| NAT Gateway (uno solo, no uno por zona) | $0.045/h × 730 h | 32.85 |
| Procesamiento de datos NAT | $0.045/GB (variable) | depende del tráfico |
| Elastic IP (en uso, asociada) | — | 0 |
| **Subtotal red** | | **≈ 33 + tráfico** |

El NAT mueve: descarga de imágenes de Docker Hub, correo SMTP (`smtp.office365.com:587`) y consultas HTTPS a
aseguradoras. Para una demo son pocos GB; con tráfico moderado estima +5 a 15 USD.

## 4. Balanceador de aplicación (ALB)

| Recurso | Cálculo | USD/mes |
|---|---|---|
| ALB (horas) | $0.0225/h × 730 h | 16.43 |
| LCU (carga baja/demo) | 1–2 LCU × $0.008 × 730 h | 6 – 12 |
| **Subtotal ALB** | | **≈ 20 – 28** |

## 5. Almacenamiento, secretos, bitácoras y otros

| Recurso | Cálculo | USD/mes |
|---|---|---|
| EFS (uso general, pocos GB de documentos) | ~$0.30/GB | 2 – 5 |
| Secrets Manager (3 secretos) | $0.40 c/u | 1.20 |
| CloudWatch Logs (ingesta + retención 30 días) | ~$0.50/GB de ingesta | 3 – 10 |
| ECR (1 repositorio, imagen de nginx) | $0.10/GB | <1 |
| ACM (certificado público) | gratis | 0 |
| Route 53 (zona privada, opcional del punto 10) | $0.50/zona | 0.50 |
| **Subtotal otros** | | **≈ 10 – 18** |

## 6. Carga inicial (una sola vez, no recurrente)

| Recurso | Nota | USD |
|---|---|---|
| Instancia temporal `t3.small` | $0.0208/h; se borra tras usarla, unas horas | <2 |
| Bucket S3 (objetos expiran a 30 días) | pocos GB | <1 |

## Palancas de ahorro

- **Fargate es el ~75% del costo.** Los tamaños de las 31 tareas son iniciales. Al ver el consumo real,
  ajustar a la baja las sobredimensionadas es el mayor ahorro. Los fronts estáticos (nginx, cdn, mainhost,
  etc.) con 0.25 vCPU ya están en el mínimo de Fargate.
- **Fargate Spot** o **Savings Plans de Compute**: recorte del 20–50% si el ambiente es estable y tolera
  reinicios.
- **Apagado fuera de horario:** si es demo/dev y no requiere 24/7, bajar las tareas deseadas a 0 por las
  noches y fines de semana reduce Fargate proporcionalmente.
- **Región:** fuera de `us-east-1` los precios cambian; algunas regiones de México/Sudamérica son más caras.
- **Tráfico de salida (NAT + egreso):** es la variable menos predecible. Conviene activar la alerta de
  presupuesto que ya menciona el punto 10 de la solicitud.

## Supuestos del estimado

- Región `us-east-1` y 730 horas/mes (24/7). Otra región o un apagado nocturno cambian el total.
- Una sola zona para RDS, sin réplicas de lectura ni Multi-AZ (según la solicitud).
- Un solo NAT Gateway (según la solicitud).
- Sin autoescalado: una tarea deseada por servicio.
- Tráfico de datos bajo, propio de un ambiente de demo. El egreso a internet se cobra aparte y es variable.
- No se incluyen CloudFront, WAF, Redis, colas ni SES porque la solicitud los descarta explícitamente.
