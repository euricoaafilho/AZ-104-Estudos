# -----------------------------------------------------------------------------
# Script: 04-client-config.ps1
# Descrição: Baixa o pacote de configuração do cliente VPN Point-to-Site
#            para autenticação via Azure AD.
# -----------------------------------------------------------------------------

# --- Configurações Iniciais (devem ser as mesmas dos scripts anteriores) ---
$rgName = "rg-vpn-p2s"
$vpnGatewayName = "vnet-p2s-gw"

# --- Variáveis para o Cliente VPN ---
# Pasta onde o pacote de configuração do cliente VPN será salvo
$clientConfigPath = ".\VPNClientConfiguration" 

# --- Verificações e Download ---

Write-Host "Verificando o status do VPN Gateway..."
# Tenta obter o objeto do VPN Gateway. -ErrorAction SilentlyContinue evita que o script pare se o gateway não for encontrado.
$vpnGateway = Get-AzVirtualNetworkGateway -ResourceGroupName $rgName -Name $vpnGatewayName -ErrorAction SilentlyContinue

# Verifica se o gateway foi encontrado
if ($null -eq $vpnGateway) {
    Write-Error "VPN Gateway '$vpnGatewayName' não encontrado no Grupo de Recursos '$rgName'. Certifique-se de que ele foi criado e está provisionado."
    exit 1 # Sai do script com erro
}

# Verifica se o gateway está totalmente provisionado
if ($vpnGateway.ProvisioningState -ne "Succeeded") {
    Write-Warning "O VPN Gateway '$vpnGatewayName' ainda não está totalmente provisionado. Por favor, aguarde até que o ProvisioningState seja 'Succeeded' antes de continuar."
    Write-Host "Você pode verificar o status com: az network vnet-gateway show -g $rgName -n $vpnGatewayName -o table"
    exit 1 # Sai do script com erro
}

Write-Host "VPN Gateway '$vpnGatewayName' está provisionado. Prosseguindo com o download da configuração do cliente."

# Criar a pasta de destino se não existir
if (-not (Test-Path $clientConfigPath)) {
    New-Item -Path $clientConfigPath -ItemType Directory | Out-Null
    Write-Host "Pasta '$clientConfigPath' criada para salvar a configuração do cliente."
}

# Baixar o pacote de configuração do cliente VPN para autenticação Azure AD
# O parâmetro -AuthenticationMethod AAD é crucial aqui para obter o pacote correto.
Write-Host "Baixando o pacote de configuração do cliente VPN para autenticação Azure AD..."
Get-AzVirtualNetworkGatewayVpnClientPackage -ResourceGroupName $rgName -VirtualNetworkGatewayName $vpnGatewayName -ProcessorArchitecture Amd64 -AuthenticationMethod AAD -OutputDirectory $clientConfigPath

Write-Host "Pacote de configuração do cliente VPN baixado para: $clientConfigPath"
Write-Host ""
Write-Host "--- Próximos Passos para o Usuário ---"
Write-Host "1. Navegue até a pasta '$clientConfigPath'."
Write-Host "2. Descompacte o arquivo ZIP baixado (ex: AzureVPNClient.zip)."
Write-Host "3. Dentro da pasta descompactada, você encontrará o instalador 'AzureVPN.exe' (ou similar)."
Write-Host "4. Execute 'AzureVPN.exe' para instalar o aplicativo 'Azure VPN Client' no seu computador."
Write-Host "5. Abra o aplicativo 'Azure VPN Client'."
Write-Host "6. No aplicativo, clique em 'Importar' e selecione o arquivo XML de perfil VPN (ex: azurevpnconfig.xml) que estará dentro da pasta descompactada."
Write-Host "7. Conecte-se usando suas credenciais do Azure AD."
Write-Host "-------------------------------------"

Write-Host "Configuração do cliente VPN concluída."