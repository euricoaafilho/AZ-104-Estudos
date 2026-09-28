# Simulação de Dispositivo VPN Local (On-Premises) com StrongSwan

Este documento fornece um guia para configurar uma máquina virtual Linux (Ubuntu) no Azure para simular um dispositivo VPN local (on-premises) usando o StrongSwan. Esta VM atuará como o gateway VPN do seu lado "local", estabelecendo a conexão Site-to-Site com o Azure VPN Gateway.

## Pré-requisitos

*   Uma VM Linux (Ubuntu 20.04 LTS ou superior recomendado) no Azure.
    *   **Importante**: Esta VM deve ter um **endereço IP público** e estar em uma VNet e Subnet **diferente** da VNet `vnet-s2s` que criamos para o Azure VPN Gateway.
    *   O IP público desta VM será o `onprem_public_ip` que você usou no script `03-local-network-gateway.azcli`.
    *   A VNet/Subnet desta VM representará sua rede local e seu prefixo de endereço será o `onprem_address_prefix` usado no script `03-local-network-gateway.azcli`.
*   Acesso SSH à VM Linux.
*   Permissões de administrador (sudo) na VM.

## Passos de Configuração

### 1. Criar a VM Linux (Simulação On-Premises)

Se você ainda não tem uma VM Linux para simular o ambiente local, crie uma no Azure.

**Exemplo de criação de VM (usando Azure CLI):**

```bash
# Variáveis para a VM local simulada
rg_onprem_name="rg-onprem-sim"
location="eastus" # Mesma região ou próxima
vnet_onprem_name="vnet-onprem"
subnet_onprem_name="subnet-onprem"
vnet_onprem_prefix="192.168.1.0/24" # Deve ser o onprem_address_prefix do script 03
subnet_onprem_prefix="192.168.1.0/24"
vm_onprem_name="vm-onprem-gw"
vm_onprem_user="azureuser"
vm_onprem_image="UbuntuLTS"

# Criar Grupo de Recursos para a VM local
az group create --name $rg_onprem_name --location $location

# Criar VNet para a VM local
az network vnet create \
    --resource-group $rg_onprem_name \
    --name $vnet_onprem_name \
    --address-prefix $vnet_onprem_prefix \
    --location $location

# Criar Subnet para a VM local
az network vnet subnet create \
    --resource-group $rg_onprem_name \
    --vnet-name $vnet_onprem_name \
    --name $subnet_onprem_name \
    --address-prefix $subnet_onprem_prefix

# Criar VM Linux (com IP público)
az vm create \
    --resource-group $rg_onprem_name \
    --name $vm_onprem_name \
    --image $vm_onprem_image \
    --admin-username $vm_onprem_user \
    --generate-ssh-keys \
    --vnet $vnet_onprem_name \
    --subnet $subnet_onprem_name \
    --public-ip-sku Basic \
    --output none

# Obter o IP público da VM (este será o onprem_public_ip)
az vm show -d -g $rg_onprem_name -n $vm_onprem_name --query publicIps -o tsv
```

### 2. Conectar-se à VM e Instalar StrongSwan

Conecte-se à sua VM Linux via SSH e execute os seguintes comandos:

```bash
# Atualizar pacotes
sudo apt update && sudo apt upgrade -y

# Instalar StrongSwan
sudo apt install strongswan -y

# Habilitar encaminhamento IP (IP Forwarding)
sudo nano /etc/sysctl.conf
# Adicione ou descomente a linha:
# net.ipv4.ip_forward = 1
# Salve e saia (Ctrl+X, Y, Enter)

# Aplicar as mudanças
sudo sysctl -p

# Desabilitar o firewall UFW (ou configurar regras para permitir IPsec)
sudo ufw disable
# Em um ambiente de produção, você configuraria regras UFW para permitir o tráfego IPsec (UDP 500, UDP 4500).
```

### 3. Configurar StrongSwan (`/etc/ipsec.conf`)

Edite o arquivo de configuração principal do StrongSwan:

```bash
sudo nano /etc/ipsec.conf
```

Apague o conteúdo existente e cole o seguinte, **substituindo os placeholders**:

```ini
config setup
    charondebug="all"
    strictcrlpolicy=no
    uniqueids=yes

conn azure-s2s
    authby=secret
    left=%any                                   # IP público da VM local (StrongSwan) - %any para IP dinâmico
    leftid=<IP_PUBLICO_DA_VM_LOCAL>             # <<<<< SUBSTITUA PELO IP PÚBLICO DA SUA VM LOCAL
    leftsubnet=<PREFIXO_REDE_LOCAL>             # <<<<< SUBSTITUA PELO PREFIXO DA SUA REDE LOCAL (ex: 192.168.1.0/24)
    right=<IP_PUBLICO_DO_AZURE_VPN_GATEWAY>     # <<<<< SUBSTITUA PELO IP PÚBLICO DO SEU AZURE VPN GATEWAY
    rightsubnet=<PREFIXO_VNET_AZURE>            # <<<<< SUBSTITUA PELO PREFIXO DA SUA VNET AZURE (ex: 10.20.0.0/16)
    ike=aes256-sha256-modp1024!
    esp=aes256-sha256!
    keyexchange=ikev2
    ikelifetime=28800s
    lifetime=3600s
    dpddelay=10s
    dpdtimeout=30s
    dpdaction=restart
    auto=start
    keyingtries=%forever
    type=tunnel
    compress=no
    rekey=yes
    forceencaps=yes
    mobike=no
    # Para Azure VPN Gateway, use o ikev2 nat-t
    # Se tiver problemas, tente ikev1 com nat-t
    # ikev2=yes
    # nat_traversal=yes
```

**Explicação dos Placeholders:**

*   `<IP_PUBLICO_DA_VM_LOCAL>`: O endereço IP público da sua VM Linux (o mesmo `onprem_public_ip` do script `03-local-network-gateway.azcli`).
*   `<PREFIXO_REDE_LOCAL>`: O espaço de endereço da VNet onde sua VM Linux está (o mesmo `onprem_address_prefix` do script `03-local-network-gateway.azcli`).
*   `<IP_PUBLICO_DO_AZURE_VPN_GATEWAY>`: O endereço IP público do Azure VPN Gateway. Você pode obtê-lo após a criação do gateway, usando `az network public-ip show -g rg-vpn-s2s -n vnet-s2s-gw-pip --query ipAddress -o tsv`.
*   `<PREFIXO_VNET_AZURE>`: O espaço de endereço da VNet do Azure (`vnet-s2s`, que é `10.20.0.0/16` no nosso exemplo).

### 4. Configurar a Chave Pré-Compartilhada (`/etc/ipsec.secrets`)

Edite o arquivo de segredos do StrongSwan:

```bash
sudo nano /etc/ipsec.secrets
```

Apague o conteúdo existente e cole a seguinte linha, **substituindo os placeholders**:
