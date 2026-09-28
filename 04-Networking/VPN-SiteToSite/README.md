# Projeto: Configuração de VPN Site-to-Site (S2S) com Azure

## Visão Geral

Este projeto detalha a configuração de uma conexão VPN Site-to-Site (S2S) no Azure. Uma VPN S2S permite conectar sua rede local (on-premises) a uma Rede Virtual (VNet) do Azure, criando uma extensão segura da sua infraestrutura de rede para a nuvem.

O objetivo é estabelecer uma conectividade segura e confiável entre um ambiente local simulado e o Azure, permitindo que recursos em ambas as redes se comuniquem como se estivessem na mesma rede.

## Conteúdo do Projeto

Este diretório conterá os scripts e a documentação para os seguintes passos:

1.  **Criação da Infraestrutura de Rede no Azure**: Grupo de Recursos, Rede Virtual (VNet) e Subnet para o VPN Gateway.
2.  **Configuração do VPN Gateway no Azure**: Criação e configuração do Virtual Network Gateway do tipo VPN.
3.  **Configuração da Rede Local (Local Network Gateway)**: Representação da sua rede on-premises no Azure.
4.  **Criação da Conexão VPN**: Estabelecimento do túnel VPN entre o Azure VPN Gateway e o Local Network Gateway.
5.  **Simulação de Dispositivo Local (Opcional)**: Instruções para simular um dispositivo VPN local (ex: usando uma VM Linux com StrongSwan).
6.  **Testes de Conectividade**: Verificação da comunicação entre recursos no Azure e na rede local simulada.
7.  **Limpeza de Recursos**: Script para remover todos os recursos criados.

## Pré-requisitos

Antes de iniciar, certifique-se de ter o seguinte:

*   **Assinatura Azure Ativa**: Uma assinatura do Microsoft Azure com permissões para criar recursos.
*   **Azure CLI Instalado**: A ferramenta de linha de comando do Azure instalada e configurada em sua máquina local.
*   **Azure PowerShell Instalado**: O módulo Azure PowerShell instalado (pode ser útil para algumas verificações).
*   **Visual Studio Code (VS Code)**: Para edição dos scripts e do `README.md`.
*   **Conhecimento Básico de Redes**: Familiaridade com conceitos de redes (IP, sub-redes, VPNs, roteamento).
*   **Ambiente para Simulação Local**: Um ambiente onde você possa simular uma rede local (pode ser uma VM em seu próprio computador ou no Azure, com acesso à internet).

## Estrutura de Arquivos

*   `README.md`: Este arquivo, descrevendo o projeto.
*   `01-azure-network-infra.azcli`: Script para criar o Grupo de Recursos, VNet e Subnet no Azure.
*   `02-azure-vpn-gateway.azcli`: Script para criar o VPN Gateway no Azure.
*   `03-local-network-gateway.azcli`: Script para criar o Local Network Gateway no Azure.
*   `04-vpn-connection.azcli`: Script para criar a conexão VPN entre o Azure e o local.
*   `05-simulate-onprem.md`: Documentação para simular o dispositivo VPN local (ex: StrongSwan).
*   `06-cleanup.azcli`: Script para remover todos os recursos criados.