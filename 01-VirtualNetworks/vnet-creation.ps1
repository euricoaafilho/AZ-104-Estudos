$conteudo = @'
# ============================================
# Script: VNet Creation
# Descricao: Cria uma Virtual Network no Azure
# Data: 24/09/2026
# Topico: AZ-104 - Virtual Networks
# ============================================

# Conectar ao Azure
# Connect-AzAccount

# Variaveis
$resourceGroupName = "rg-app-services"
$vnetName = "KNET1"
$location = "eastus"
$addressPrefix = "10.0.0.0/16"
$subnetName = "VM-Subnet"
$subnetPrefix = "10.0.1.0/24"

# Criar Virtual Network
Write-Host "Criando Virtual Network..." -ForegroundColor Yellow

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Name $vnetName `
  -AddressPrefix $addressPrefix `
  -Location $location

Write-Host "VNet criada!" -ForegroundColor Green

# Criar Subnet
Write-Host "Criando Subnet..." -ForegroundColor Yellow

$subnet = Add-AzVirtualNetworkSubnetConfig `
  -Name $subnetName `
  -VirtualNetwork $vnet `
  -AddressPrefix $subnetPrefix

$vnet | Set-AzVirtualNetwork

Write-Host "Subnet criada!" -ForegroundColor Green

# Exibir informacoes
Write-Host "Informacoes da VNet:" -ForegroundColor Cyan
Write-Host "Nome: $($vnet.Name)"
Write-Host "Resource Group: $($vnet.ResourceGroupName)"
Write-Host "Address Space: $($vnet.AddressSpace.AddressPrefixes)"
Write-Host "Subnets: $($vnet.Subnets.Count)"
'@

$conteudo | Out-File 01-VirtualNetworks\vnet-creation.ps1

Write-Host "Arquivo criado com sucesso!" -ForegroundColor Green