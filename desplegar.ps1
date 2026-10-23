<#
    Despliegue de la plataforma base Finzai (puntos 1-9) en AWS.
    Region objetivo: mx-central-1.

    Uso:
        .\desplegar.ps1 -Environment finzai-demo -Subdomain finzai-demo.tekprovider.net `
                        -HostedZoneId Z0123456789ABCDEFGHIJ `
                        -OperatorArn arn:aws:iam::111122223333:user/cflores `
                        -AllowedIngress "203.0.113.10/32"

    Requisitos:
      - AWS CLI v2 configurada (aws configure) con permisos de administracion.
      - La plantilla finzai-plataforma.yaml en el mismo directorio.

    Nota: el ALB y RDS exigen dos zonas; la cuenta debe tener >= 2 AZ en la
    region. Valida que EFS este disponible en mx-central-1 antes de ejecutar.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Environment,

    [string]$Region = "mx-central-1",

    [string]$Subdomain = "",

    [string]$HostedZoneId = "",

    [string]$OperatorArn = "",

    [string]$AllowedIngress = "0.0.0.0/0",

    [string]$StackName = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrEmpty($StackName)) {
    $StackName = "finzai-$Environment"
}

$templatePath = Join-Path $PSScriptRoot "finzai-plataforma.yaml"
if (-not (Test-Path $templatePath)) {
    throw "No se encontro la plantilla en $templatePath"
}

Write-Host "Validando la plantilla..." -ForegroundColor Cyan
aws cloudformation validate-template `
    --template-body file://$templatePath `
    --region $Region | Out-Null

Write-Host "Desplegando pila '$StackName' en $Region ..." -ForegroundColor Cyan
aws cloudformation deploy `
    --stack-name $StackName `
    --template-file $templatePath `
    --region $Region `
    --capabilities CAPABILITY_NAMED_IAM `
    --parameter-overrides `
        EnvironmentName=$Environment `
        Subdomain=$Subdomain `
        HostedZoneId=$HostedZoneId `
        OperatorPrincipalArn=$OperatorArn `
        AllowedIngressCidr=$AllowedIngress

Write-Host "`nSalidas de la pila:" -ForegroundColor Green
aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query "Stacks[0].Outputs" `
    --output table

Write-Host "`nListo. Si definiste un operador, adjunta la politica:" -ForegroundColor Yellow
Write-Host "  aws iam attach-user-policy --user-name <usuario> --policy-arn <OperatorPolicyArn>" -ForegroundColor Yellow
