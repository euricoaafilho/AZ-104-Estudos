# Projeto: VPN Site-to-Site (S2S) no Azure

Este projeto demonstra a configuração de uma conexão VPN Site-to-Site (S2S) no Azure, conectando uma Rede Virtual (VNet) do Azure a uma rede local simulada. Uma VPN S2S é ideal para conectar redes on-premises a redes virtuais do Azure, permitindo que recursos em ambas as redes se comuniquem de forma segura.

## Estrutura do Projeto

A pasta `VPN-SiteToSite` contém os seguintes arquivos:

*   `01-azure-network-infra.azcli`: Script para criar o Grupo de Recursos, a VNet e a `GatewaySubnet` no Azure.
*   `02-azure-vpn-gateway.azcli`: Script para criar o Virtual Network Gateway (VPN Gateway) no Azure.
*   `03-local-network-gateway.azcli`: Script para criar o Local Network Gateway no Azure, que representa o dispositivo VPN e o espaço de endereço da sua rede local.
*   `04-vpn-connection.azcli`: Script para criar a conexão VPN entre o Azure VPN Gateway e o Local Network Gateway.
*   `05-simulate-onprem.md`: Documentação detalhada para simular um dispositivo VPN local usando uma VM Linux com **StrongSwan**.
*   `05-simulate-onprem-rras.md`: Documentação detalhada para simular um dispositivo VPN local usando uma VM Windows Server com **RRAS (Routing and Remote Access Service)**.
*   `06-cleanup.azcli`: Script para remover todos os recursos criados por este projeto no Azure.
*   `README.md`: Este arquivo, descrevendo o projeto e os passos.

## Visão Geral da Solução

A VPN Site-to-Site conecta duas redes distintas (Azure VNet e rede local) através de um túnel IPsec/IKE criptografado. No Azure, isso é feito através de um Virtual Network Gateway e um Local Network Gateway.

### Componentes Principais

*   **Azure Virtual Network (VNet)**: A rede no Azure onde seus recursos estarão.
*   **GatewaySubnet**: Uma sub-rede dedicada dentro da VNet para o Azure VPN Gateway.
*   **Azure Virtual Network Gateway (VPN Gateway)**: O ponto de extremidade da VPN no lado do Azure.
*   **Local Network Gateway (LNG)**: Um objeto no Azure que representa o dispositivo VPN e o espaço de endereço da sua rede local.
*   **Conexão VPN**: O túnel IPsec/IKE que conecta o VPN Gateway ao LNG.
*   **Dispositivo VPN Local (Simulado)**: Uma VM (Linux com StrongSwan ou Windows Server com RRAS) que atua como o gateway VPN na sua rede local simulada.

## Passos para Configuração

Siga os passos abaixo para configurar a VPN Site-to-Site:

1.  **Crie a Infraestrutura de Rede do Azure**:
    *   Execute o script `01-azure-network-infra.azcli`. Este script criará o Grupo de Recursos, a VNet e a `GatewaySubnet`.

2.  **Crie o Azure VPN Gateway**:
    *   Execute o script `02-azure-vpn-gateway.azcli`. Este processo pode levar de 30 a 45 minutos. Você pode continuar com os próximos passos enquanto o gateway é provisionado.

3.  **Crie o Local Network Gateway**:
    *   **Antes de executar**: Edite o script `03-local-network-gateway.azcli` e substitua os placeholders `onprem_public_ip` e `onprem_address_prefix` pelos valores que você usará para sua rede local simulada.
    *   Execute o script `03-local-network-gateway.azcli`.

4.  **Crie a Conexão VPN**:
    *   **Antes de executar**: Edite o script `04-vpn-connection.azcli` e substitua o placeholder `shared_key` por uma chave secreta forte.
    *   Execute o script `04-vpn-connection.azcli`.

5.  **Simule o Dispositivo VPN Local**:
    *   Escolha uma das opções abaixo para simular seu ambiente on-premises:
        *   **Opção A: Linux com StrongSwan**: Siga as instruções detalhadas no arquivo `05-simulate-onprem.md`.
        *   **Opção B: Windows Server com RRAS**: Siga as instruções detalhadas no arquivo `05-simulate-onprem-rras.md`.
    *   **Importante**: Certifique-se de que o IP público e o prefixo de rede configurados no seu dispositivo local simulado (StrongSwan ou RRAS) correspondam aos valores usados no `03-local-network-gateway.azcli` e que a chave compartilhada seja a mesma do `04-vpn-connection.azcli`.

6.  **Teste a Conectividade**:
    *   Após a configuração de ambos os lados (Azure e local simulado), verifique o status da conexão no portal do Azure e no seu dispositivo local.
    *   Crie VMs de teste em ambas as redes (Azure VNet e VNet local simulada) e tente pingar ou estabelecer conexões RDP/SSH entre elas.

7.  **Limpeza dos Recursos**:
    *   Quando terminar seus estudos e testes, execute o script `06-cleanup.azcli` para remover todos os recursos criados e evitar custos desnecessários.

## Considerações Importantes

*   **Endereçamento IP**: Garanta que não haja sobreposição de endereços IP entre sua VNet do Azure e sua rede local simulada.
*   **Chave Compartilhada**: A chave pré-compartilhada deve ser idêntica em ambos os lados da conexão VPN.
*   **Firewall**: Certifique-se de que os firewalls (tanto no Azure quanto no dispositivo local simulado) permitam o tráfego IPsec (UDP 500, UDP 4500, ESP, AH).
*   **SKU do VPN Gateway**: Para VPNs Site-to-Site, o SKU `Basic` tem limitações. `VpnGw1` ou superior é recomendado.