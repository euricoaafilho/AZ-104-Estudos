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
$subnetName = "VM-Subnet" # Esta é a primeira subnet que você cria
$subnetPrefix = "10.0.1.0/24"

# Criar Virtual Network
Write-Host "Criando Virtual Network..." -ForegroundColor Yellow

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $resourceGroupName `
  -Name $vnetName `
  -AddressPrefix $addressPrefix `
  -Location $location

Write-Host "VNet criada!" -ForegroundColor Green

# Criar a primeira Subnet (VM-Subnet)
Write-Host "Criando Subnet '$subnetName'..." -ForegroundColor Yellow

$vnet = Add-AzVirtualNetworkSubnetConfig `
  -Name $subnetName `
  -VirtualNetwork $vnet `
  -AddressPrefix $subnetPrefix | Set-AzVirtualNetwork # Aplica a configuração da primeira subnet imediatamente

Write-Host "Subnet '$subnetName' criada!" -ForegroundColor Green

# Criar Multiplas SubNets na VNET
Write-Host "Criando Subnets adicionais..." -ForegroundColor Yellow

# Adicionando VM-Subnet1
$vnet = Add-AzVirtualNetworkSubnetConfig `
  -Name "VM-Subnet1" `
  -VirtualNetwork $vnet `
  -AddressPrefix "10.0.2.0/24" | Set-AzVirtualNetwork 

Write-Host "Subnet 'VM-Subnet1' criada!" -ForegroundColor Green

# Adicionando VM-Subnet2
$vnet = Add-AzVirtualNetworkSubnetConfig `
  -Name "VM-Subnet2" `
  -VirtualNetwork $vnet `
  -AddressPrefix "10.0.3.0/24" | Set-AzVirtualNetwork 

Write-Host "Subnet 'VM-Subnet2' criada!" -ForegroundColor Green

# Adicionando VM-Subnet3
$vnet = Add-AzVirtualNetworkSubnetConfig `
  -Name "VM-Subnet3" `
  -VirtualNetwork $vnet `
  -AddressPrefix "10.0.4.0/24" | Set-AzVirtualNetwork

Write-Host "Subnet 'VM-Subnet3' criada!" -ForegroundColor Green
Write-Host "Todas as subnets criadas!" -ForegroundColor Green

# Listar VNETs (para verificar as subnets criadas)
Write-Host "Listando informacoes da VNet '$vnetName'..." -ForegroundColor Cyan
Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName | Format-List Name, Location, AddressSpace, Subnets


# Exibir informacoes
Write-Host "Informacoes da VNet:" -ForegroundColor Cyan
Write-Host "Nome: $($vnet.Name)"
Write-Host "Resource Group: $($vnet.ResourceGroupName)"
Write-Host "Address Space: $($vnet.AddressSpace.AddressPrefixes)"
Write-Host "Subnets: $($vnet.Subnets.Count)"
'@

$conteudo | Out-File 01-VirtualNetworks\vnet-creation.ps1

Write-Host "Arquivo criado com sucesso!" -ForegroundColor Green
