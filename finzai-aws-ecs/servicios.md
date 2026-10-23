# Servicios de ECS — ambiente Finzai

Los 31 servicios que corren en el clúster, uno por contenedor. Cada uno es una definición de tarea de
Fargate (Linux, x86_64) con **una** tarea deseada. Todos se registran en Service Connect con su propio
nombre y puerto, porque así se llaman entre ellos (`http://iamapi:8080`).

Esta tabla sale del archivo de composición con que la plataforma ya corre en una sola máquina; las
variables están copiadas de ahí, no transcritas a mano.

## Resumen

| # | Servicio y alias en Service Connect | Tipo | Imagen | Puerto | vCPU | Memoria | Usa la base |
|---|---|---|---|---|---|---|---|
| | **Entrada** | | | | | | |
| 1 | `nginx` | Proxy | `<repositorio ECR>/finzai-nginx:<etiqueta>` | 80 | 0.25 | 0.5 GB | No |
| | **Núcleo** | | | | | | |
| 2 | `cdn` | Front estático | `danielsancheztekprovider1/cdn` | 80 | 0.25 | 0.5 GB | No |
| 3 | `registration` | Front estático | `danielsancheztekprovider1/registrationapp:<etiqueta para AWS>` | 8080 | 0.25 | 0.5 GB | No |
| 4 | `mainhost` | Front estático | `danielsancheztekprovider1/mainhost:<etiqueta para AWS>` | 8080 | 0.25 | 0.5 GB | No |
| 5 | `coredesk` | Front estático | `danielsancheztekprovider1/coredesk:<etiqueta para AWS>` | 8080 | 0.25 | 0.5 GB | No |
| 6 | `iamapi` | API | `danielsancheztekprovider1/iam` | 8080 | 0.25 | 1 GB | Sí |
| 7 | `notificationapi` | API | `danielsancheztekprovider1/notificationapi` | 8080 | 0.25 | 1 GB | Sí |
| 8 | `configurationapi` | API | `danielsancheztekprovider1/configurationapi` | 8080 | 0.5 | 2 GB | Sí |
| 9 | `registrationapi` | API | `danielsancheztekprovider1/registrationapi` | 8080 | 0.25 | 1 GB | Sí |
| 10 | `filemanagementapi` | API | `danielsancheztekprovider1/filemanagementapi` | 8080 | 0.25 | 1 GB | Sí |
| | **Cotizador automotriz** | | | | | | |
| 11 | `quoterauto-shell` | BFF | `danielsancheztekprovider1/quoterauto-shell:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 12 | `quoterauto-intake` | BFF | `danielsancheztekprovider1/quoterauto-intake:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 13 | `quoterauto-product` | BFF | `danielsancheztekprovider1/quoterauto-product:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 14 | `quoterauto-finance` | BFF | `danielsancheztekprovider1/quoterauto-finance:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 15 | `quoterauto-addons` | BFF | `danielsancheztekprovider1/quoterauto-addons:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 16 | `quoterauto-insurance` | BFF | `danielsancheztekprovider1/quoterauto-insurance:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 17 | `quoterauto-financedetail` | BFF | `danielsancheztekprovider1/quoterauto-financedetail:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 18 | `quoterapi` | API | `danielsancheztekprovider1/quoterapi` | 8080 | 0.5 | 2 GB | Sí |
| 19 | `financialplanapi` | API | `danielsancheztekprovider1/financialplanapi` | 8080 | 0.25 | 1 GB | Sí |
| 20 | `insurancebrokerapi` | API | `danielsancheztekprovider1/insurancebrokerapi:1.3.0` | 8080 | 0.25 | 1 GB | Sí |
| | **Onboarding** | | | | | | |
| 21 | `onboarding-shell` | BFF | `danielsancheztekprovider1/onboarding-shell:<etiqueta para AWS>` | 8080 | 0.25 | 1 GB | No |
| 22 | `onboarding-generaldata` | BFF | `danielsancheztekprovider1/onboarding-generaldata:1.1.11` | 8080 | 0.25 | 1 GB | No |
| 23 | `onboarding-employment` | BFF | `danielsancheztekprovider1/onboarding-employment:1.1.1` | 8080 | 0.25 | 1 GB | No |
| 24 | `onboarding-references` | BFF | `danielsancheztekprovider1/onboarding-references:1.0.5` | 8080 | 0.25 | 1 GB | No |
| 25 | `onboarding-personalinterview` | BFF | `danielsancheztekprovider1/onboarding-personalinterview:1.0.3` | 8080 | 0.25 | 1 GB | No |
| 26 | `onboarding-bureau` | BFF | `danielsancheztekprovider1/onboarding-bureau:1.0.6` | 8080 | 0.25 | 1 GB | No |
| 27 | `onboarding-documents` | BFF | `danielsancheztekprovider1/onboarding-documents:1.0.15` | 8080 | 0.25 | 1 GB | No |
| 28 | `onboarding-liveness` | BFF | `danielsancheztekprovider1/onboarding-liveness:1.0.2` | 8080 | 0.25 | 1 GB | No |
| 29 | `onboarding-liabilities` | BFF | `danielsancheztekprovider1/onboarding-liabilities:1.0.1` | 8080 | 0.25 | 1 GB | No |
| 30 | `onboarding-balances` | BFF | `danielsancheztekprovider1/onboarding-balances:1.0.1` | 8080 | 0.25 | 1 GB | No |
| 31 | `originationapi` | API | `danielsancheztekprovider1/originationapi` | 8080 | 0.5 | 2 GB | Sí |

Total: 31 tareas, 8.5 vCPU y 31.5 GB de memoria.

Notas:

- **Tamaños iniciales.** Salen de la memoria medida en reposo en una sola máquina, más el margen que pide
  el proxy de Service Connect. Se ajustan después de ver el consumo real.
- **`<etiqueta para AWS>`**: son los fronts que llevan la dirección pública dentro de la imagen. El
  solicitante los reconstruye para el subdominio y entrega la etiqueta.
- **`nginx`** es el único servicio que recibe tráfico del balanceador. Su imagen lleva dentro el archivo de
  rutas y la publica el solicitante en el repositorio de ECR.
- **`filemanagementapi`** monta el sistema de archivos EFS en `/mnt/FinzaiDocs`.
- Las direcciones `*.invalid` son a propósito: la prueba de vida y el motor de flujos quedan fuera de este
  alcance y así no llaman a otro ambiente.
- `quoterauto-shell` apunta a `customdocumentapi`, que no está en este alcance: el botón Imprimir del
  cotizador responde error hasta que se agregue ese módulo.

## Variables por servicio

«Secreto» = la variable se llena desde Secrets Manager (campo `secrets` de la definición de tarea), nunca
como texto en la definición.

### Entrada

**`nginx`**

Sin variables. Puerto 80; comprobación de salud del balanceador en `GET /salud`.

### Núcleo

**`cdn`**

Sin variables.

**`registration`**

Sin variables.

**`mainhost`**

Sin variables.

**`coredesk`**

Sin variables.

**`iamapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__DefaultConnection` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `JwtSettings__KeyProtectionKey` | Secreto `finzai/<ambiente>/iam-key-protection` |
| `JwtSettings__PublicBaseUrl` | `https://<subdominio>/IAMApi/` |
| `NotificationApi__BaseUrl` | `http://notificationapi:8080/api/v1/` |

**`notificationapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__NotificationApi` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `IamApi__BaseUrl` | `http://iamapi:8080/` |
| `WorkflowApi__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |

**`configurationapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__ConfigurationApi` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `FinzaiPermissions__IamBaseUrl` | `http://iamapi:8080/` |

**`registrationapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__RegistrationApi` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `FinzaiPermissions__IamBaseUrl` | `http://iamapi:8080/` |

**`filemanagementapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__ConfigurationApi` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `ConnectionStrings__FileManagementApi` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `FinzaiPermissions__IamBaseUrl` | `http://iamapi:8080/` |

### Cotizador automotriz

**`quoterauto-shell`**

| Variable | Valor |
|---|---|
| `InternalApi__ConfigurationApi__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__CustomDocumentsApi__BaseUrl` | `http://customdocumentapi:8080/api/v1/` |
| `InternalApi__FinancialPlanApi__BaseUrl` | `http://financialplanapi:8080/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__QuoterApi__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |
| `PublicAccess__AllowedOrigin` | `https://<subdominio>` |

**`quoterauto-intake`**

| Variable | Valor |
|---|---|
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`quoterauto-product`**

| Variable | Valor |
|---|---|
| `InternalApi__ConfigurationApi__BaseUrl` | `http://configurationapi:8080/` |
| `InternalApi__FileManagementApi__BaseUrl` | `http://filemanagementapi:8080/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`quoterauto-finance`**

| Variable | Valor |
|---|---|
| `InternalApi__ConfigurationApi__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FinancialPlan__BaseUrl` | `http://financialplanapi:8080/api/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`quoterauto-addons`**

| Variable | Valor |
|---|---|
| `InternalApi__FinancialPlan__BaseUrl` | `http://financialplanapi:8080/api/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`quoterauto-insurance`**

| Variable | Valor |
|---|---|
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__InsuranceBroker__BaseUrl` | `http://insurancebrokerapi:8080/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`quoterauto-financedetail`**

| Variable | Valor |
|---|---|
| `InternalApi__ConfigurationApi__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FinancialPlanApi__BaseUrl` | `http://financialplanapi:8080/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`quoterapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__postgre` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `FinzaiPermissions__IamBaseUrl` | `http://iamapi:8080/` |
| `PublicAccess__AllowedOrigins__0` | `https://<subdominio>` |

**`financialplanapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__postgre` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `FinzaiPermissions__IamBaseUrl` | `http://iamapi:8080/` |

**`insurancebrokerapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__InsuranceBrokerDb` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `ConnectionStrings__ProviderIntegrationDb` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |

### Onboarding

**`onboarding-shell`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-generaldata`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-employment`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-references`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-personalinterview`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-bureau`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-documents`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-liveness`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-liabilities`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`onboarding-balances`**

| Variable | Valor |
|---|---|
| `InternalApi__Catalogs__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Configuration__BaseUrl` | `http://configurationapi:8080/api/v1/` |
| `InternalApi__FileManagement__BaseUrl` | `http://filemanagementapi:8080/api/v1/` |
| `InternalApi__IAM__BaseUrl` | `http://iamapi:8080/` |
| `InternalApi__Liveness__BaseUrl` | `http://liveness-apagado.invalid/api/liveness/` |
| `InternalApi__Origination__BaseUrl` | `http://originationapi:8080/api/v1/` |
| `InternalApi__Quoter__BaseUrl` | `http://quoterapi:8080/api/` |
| `InternalApi__Registration__BaseUrl` | `http://registrationapi:8080/api/v1/` |
| `InternalApi__Workflow__BaseUrl` | `http://workflow-apagado.invalid/api/v1/` |
| `Jwt__IamBaseUrl` | `http://iamapi:8080/` |
| `Kestrel__Limits__MaxRequestHeadersTotalSize` | `65536` |

**`originationapi`**

| Variable | Valor |
|---|---|
| `ConnectionStrings__OriginationApi` | Secreto `finzai/<ambiente>/bd-cadena-conexion` |
| `FinzaiPermissions__IamBaseUrl` | `http://iamapi:8080/` |
