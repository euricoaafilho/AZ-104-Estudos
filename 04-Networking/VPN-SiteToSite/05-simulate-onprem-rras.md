# Simulação de Dispositivo VPN Local (On-Premises) com Windows Server RRAS

Este documento fornece um guia para configurar uma máquina virtual Windows Server no Azure para simular um dispositivo VPN local (on-premises) usando o **Serviço de Roteamento e Acesso Remoto (RRAS)**. Esta VM atuará como o gateway VPN do seu lado "local", estabelecendo a conexão Site-to-Site com o Azure VPN Gateway.

## Pré-requisitos

*   Uma VM Windows Server (2019 ou 2022 recomendado) no Azure.
    *   **Importante**: Esta VM deve ter **DUAS PLACAS DE REDE (NICs)**:
        *   Uma NIC "Externa" (WAN) com um **endereço IP público** (este será o `onprem_public_ip` que você usou no script `03-local-network-gateway.azcli`). Esta NIC deve estar em uma VNet e Subnet **diferente** da VNet `vnet-s2s` do Azure VPN Gateway.
        *   Uma NIC "Interna" (LAN) em uma Subnet que representará sua rede local. O prefixo de endereço desta VNet/Subnet será o `onprem_address_prefix` usado no script `03-local-network-gateway.azcli`.
    *   A VM deve ter acesso RDP.
*   Permissões de administrador na VM Windows Server.

## Passos de Configuração

### 1. Criar a VM Windows Server com Duas NICs (Simulação On-Premises)

Se você ainda não tem uma VM Windows Server com duas NICs para simular o ambiente local, crie uma no Azure.

**Exemplo de criação de VM (usando Azure CLI):**

```bash
# --- Variáveis para a VM local simulada ---
rg_onprem_name="rg-onprem-rras" # Novo RG para RRAS
location="eastus"
vnet_onprem_name="vnet-onprem-rras"
subnet_wan_name="subnet-wan"
subnet_lan_name="subnet-lan"
vnet_onprem_prefix="192.168.1.0/24" # Deve ser o onprem_address_prefix do script 03
subnet_wan_prefix="192.168.1.0/27" # Exemplo: 192.168.1.0/27
subnet_lan_prefix="192.168.1.32/27" # Exemplo: 192.168.1.32/27
vm_onprem_name="vm-onprem-rras"
vm_onprem_user="azureuser"
vm_onprem_image="Win2019Datacenter" # Ou Win2022Datacenter

# 1. Criar Grupo de Recursos para a VM local
echo "Criando o Grupo de Recursos para RRAS: $rg_onprem_name..."
az group create --name $rg_onprem_name --location $location

# 2. Criar VNet para a VM local
echo "Criando a VNet para RRAS: $vnet_onprem_name..."
az network vnet create \
    --resource-group $rg_onprem_name \
    --name $vnet_onprem_name \
    --address-prefix $vnet_onprem_prefix \
    --location $location

# 3. Criar Subnets para WAN e LAN
echo "Criando subnet WAN: $subnet_wan_name..."
az network vnet subnet create \
    --resource-group $rg_onprem_name \
    --vnet-name $vnet_onprem_name \
    --name $subnet_wan_name \
    --address-prefix $subnet_wan_prefix

echo "Criando subnet LAN: $subnet_lan_name..."
az network vnet subnet create \
    --resource-group $rg_onprem_name \
    --vnet-name $vnet_onprem_name \
    --name $subnet_lan_name \
    --address-prefix $subnet_lan_prefix

# 4. Criar IP Público para a NIC WAN
echo "Criando IP Público para a NIC WAN..."
az network public-ip create \
    --resource-group $rg_onprem_name \
    --name "${vm_onprem_name}-pip" \
    --location $location \
    --allocation-method Static \
    --sku Standard # Use Standard para produção, Basic para testes simples

# 5. Criar NIC WAN
echo "Criando NIC WAN..."
az network nic create \
    --resource-group $rg_onprem_name \
    --name "${vm_onprem_name}-nic-wan" \
    --vnet-name $vnet_onprem_name \
    --subnet $subnet_wan_name \
    --public-ip-address "${vm_onprem_name}-pip" \
    --network-security-group "" # NSG pode ser configurado separadamente

# 6. Criar NIC LAN
echo "Criando NIC LAN..."
az network nic create \
    --resource-group $rg_onprem_name \
    --name "${vm_onprem_name}-nic-lan" \
    --vnet-name $vnet_onprem_name \
    --subnet $subnet_lan_name \
    --network-security-group "" # NSG pode ser configurado separadamente

# 7. Criar VM Windows Server com as duas NICs
echo "Criando VM Windows Server: $vm_onprem_name..."
az vm create \
    --resource-group $rg_onprem_name \
    --name $vm_onprem_name \
    --image $vm_onprem_image \
    --admin-username $vm_onprem_user \
    --admin-password "SuaSenhaSegura123!" # <<<<< SUBSTITUA POR UMA SENHA FORTE
    --nics "${vm_onprem_name}-nic-wan" "${vm_onprem_name}-nic-lan" \
    --location $location \
    --size Standard_B2s \
    --output none

# Obter o IP público da VM (este será o onprem_public_ip)
echo "Obtendo o IP público da VM (este será o onprem_public_ip para o Azure LNG):"
az network public-ip show -g $rg_onprem_name -n "${vm_onprem_name}-pip" --query ipAddress -o tsv
```

### 2. Conectar-se à VM e Configurar Interfaces de Rede

1.  Conecte-se à sua VM Windows Server via RDP.
2.  Dentro da VM, abra o "Network and Sharing Center" (ou "Central de Rede e Compartilhamento").
3.  Renomeie as interfaces de rede para facilitar a identificação:
    *   A NIC conectada à `subnet-wan` (com o IP público) para `WAN`.
    *   A NIC conectada à `subnet-lan` para `LAN`.
4.  Configure os endereços IP estáticos para as interfaces `WAN` e `LAN` dentro da VM, se necessário, de acordo com os prefixos das subnets.

### 3. Instalar o Serviço de Roteamento e Acesso Remoto (RRAS)

1.  Abra o **Server Manager**.
2.  Clique em **Add Roles and Features** (Adicionar Funções e Recursos).
3.  Clique em **Next** (Avançar) até chegar à tela **Server Roles** (Funções do Servidor).
4.  Selecione **Network Policy and Access Services** (Serviços de Acesso e Políticas de Rede).
5.  Na janela de recursos, selecione **Routing** (Roteamento) e **DirectAccess and VPN (RAS)** (DirectAccess e VPN (RAS)).
6.  Clique em **Next** (Avançar) e **Install** (Instalar).

### 4. Configurar o RRAS para VPN Site-to-Site

1.  Após a instalação, abra o **Routing and Remote Access** (Roteamento e Acesso Remoto) no Server Manager (Tools > Routing and Remote Access).
2.  No console, clique com o botão direito no nome do servidor e selecione **Configure and Enable Routing and Remote Access** (Configurar e Habilitar Roteamento e Acesso Remoto).
3.  No assistente, clique em **Next** (Avançar).
4.  Selecione **Custom Configuration** (Configuração Personalizada) e clique em **Next**.
5.  Marque as opções **VPN access** (Acesso VPN) e **LAN routing** (Roteamento LAN). Clique em **Next**.
6.  Clique em **Finish** (Concluir) e depois em **Start service** (Iniciar serviço).

### 5. Criar uma Interface de Demanda (Demand-Dial Interface) para a Conexão VPN

1.  No console do RRAS, expanda o nome do servidor, depois **Network Interfaces** (Interfaces de Rede).
2.  Clique com o botão direito em **Network Interfaces** e selecione **New Demand-Dial Interface** (Nova Interface de Demanda).
3.  No assistente, clique em **Next**.
4.  Dê um nome à interface, por exemplo, `Azure-S2S-VPN`. Clique em **Next**.
5.  Selecione **Connect using virtual private networking (VPN)** (Conectar usando rede privada virtual (VPN)). Clique em **Next**.
6.  Selecione **IKEv2** como o tipo de VPN. Clique em **Next**.
7.  No campo **Host name or IP address**, insira o **endereço IP público do seu Azure VPN Gateway**. Clique em **Next**.
    *   **Guia**: Você pode obter este IP executando no seu terminal local:
        ```bash
        az network public-ip show -g rg-vpn-s2s -n vnet-s2s-gw-pip --query ipAddress -o tsv
        ```
8.  Clique em **Next** para "Protocols and Security".
9.  Clique em **Next** para "Dial-out Credentials".
10. Clique em **Finish**.

### 6. Configurar Propriedades da Interface de Demanda

1.  No console do RRAS, clique com o botão direito na interface `Azure-S2S-VPN` que você acabou de criar e selecione **Properties** (Propriedades).
2.  Vá para a aba **Security** (Segurança).
3.  Selecione **Use pre-shared key for authentication** (Usar chave pré-compartilhada para autenticação).
4.  No campo **Key**, insira a **chave compartilhada** que você definiu no script `04-vpn-connection.azcli` (ex: `SuaChaveSecreta123!`).
5.  Vá para a aba **Networking** (Rede).
6.  Certifique-se de que o **Type of VPN** (Tipo de VPN) está como **IKEv2**.
7.  Vá para a aba **IPv4**.
8.  Clique em **Static routes** (Rotas estáticas) e depois em **Add** (Adicionar).
9.  Adicione uma rota para a VNet do Azure:
    *   **Destination**: O prefixo de rede da sua VNet do Azure (ex: `10.20.0.0`).
    *   **Network mask**: A máscara de rede correspondente (ex: `255.255.0.0` para `/16`).
    *   **Metric**: `1`.
    *   **Guia**: O prefixo da sua VNet Azure é `10.20.0.0/16` no nosso exemplo.
10. Clique em **OK** em todas as janelas para salvar as configurações.

### 7. Configurar Firewall do Windows na VM

É crucial configurar o Firewall do Windows para permitir o tráfego VPN.

1.  Abra o **Windows Defender Firewall with Advanced Security** (Firewall do Windows com Segurança Avançada).
2.  Crie regras de entrada (Inbound Rules) para permitir o tráfego IPsec:
    *   **UDP Port 500** (IKE)
    *   **UDP Port 4500** (NAT-T para IPsec)
    *   **Protocolo IP 50** (ESP)
    *   **Protocolo IP 51** (AH)
3.  Alternativamente, para fins de teste, você pode desativar temporariamente o firewall, mas **NÃO FAÇA ISSO EM PRODUÇÃO**.

### 8. Conectar a Interface de Demanda

1.  No console do RRAS, clique com o botão direito na interface `Azure-S2S-VPN` e selecione **Connect** (Conectar).
2.  A conexão deve tentar ser estabelecida.

### 9. Verificar o Status da Conexão

*   No console do RRAS, o status da interface `Azure-S2S-VPN` deve mudar para `Connected` (Conectado).
*   Você também pode verificar o status da conexão no portal do Azure para o seu Azure VPN Gateway.

## Próximos Passos

*   Crie uma VM de teste na `vnet-s2s` do Azure e tente fazer ping ou RDP para uma VM na `subnet-lan` da sua VM RRAS.
*   Crie uma VM de teste na `subnet-lan` da sua VM RRAS e tente fazer ping ou RDP para uma VM na `vnet-s2s` do Azure.

---

**Lembre-se**: Esta é uma simulação. Em um ambiente de produção, você configuraria um dispositivo VPN físico ou virtual (como um firewall de borda) em sua rede local. As configurações de IPsec (IKE/ESP) devem ser compatíveis entre o Azure VPN Gateway e o dispositivo local.
