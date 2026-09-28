# Projeto: Configuração de VPN Point-to-Site (P2S) com Azure AD Authentication

## Visão Geral

Este projeto detalha a configuração de uma conexão VPN Point-to-Site (P2S) no Azure, utilizando autenticação via Azure Active Directory (Azure AD). A VPN P2S permite que usuários individuais se conectem de forma segura a uma Rede Virtual (VNet) do Azure a partir de qualquer local, como se estivessem diretamente conectados à rede corporativa.

O objetivo é criar uma solução de acesso remoto segura e escalável, integrando a autenticação de usuários com o Azure AD para gerenciamento centralizado de identidades e acessos.

## Conteúdo do Projeto

Este diretório contém os scripts e a documentação para os seguintes passos:

1.  **Criação da Infraestrutura de Rede**: Grupo de Recursos, Rede Virtual (VNet) e Subnet para o code VPN Gateway.
2.  **Configuração do VPN Gateway**: Criação e configuração do Virtual Network Gateway do tipo VPN.
3.  **Integração com Azure Active Directory**: Registro de aplicativo no Azure AD para autenticação P2S.
4.  **Configuração do Cliente VPN**: Geração e instalação do perfil de cliente VPN.
5.  **Testes de Conectividade**: Verificação da conexão VPN e acesso a recursos na VNet.

## Pré-requisitos

Antes de iniciar, certifique-se de ter o seguinte:

*   **Assinatura Azure Ativa**: Uma assinatura do Microsoft Azure com permissões para criar recursos.
*   **Azure CLI Instalado**: A ferramenta de linha de comando do Azure instalada e configurada em sua máquina local.
*   **Azure PowerShell Instalado**: O módulo Azure PowerShell instalado (será usado para algumas etapas específicas, como geração de certificados).
*   **Visual Studio Code (VS Code)**: Para edição dos scripts e do `README.md`.
*   **Permissões no Azure AD**: Permissões para registrar aplicativos no seu Azure Active Directory.
*   **Conhecimento Básico de Redes**: Familiaridade com conceitos de redes (IP, sub-redes, VPNs).

## Estrutura de Arquivos

*   `README.md`: Este arquivo, descrevendo o projeto.
*   `01-network-infra.azcli`: Script para criar o Grupo de Recursos, VNet e Subnet.
*   `02-vpn-gateway.azcli`: Script para criar o VPN Gateway.
*   `03-aad-integration.azcli`: Script para configurar a integração com Azure AD.
*   `04-client-config.ps1`: Script PowerShell para gerar e configurar o cliente VPN.
*   `05-cleanup.azcli`: Script para remover todos os recursos criados.

## Instruções de Execução

Siga os passos abaixo para configurar a VPN Point-to-Site com autenticação Azure AD.

**Importante**: Certifique-se de estar logado no Azure CLI (`az login`) e no Azure PowerShell (`Connect-AzAccount`) com uma conta que tenha as permissões necessárias para criar e gerenciar recursos no Azure e no Azure AD.

1.  **Criar a Infraestrutura de Rede (Grupo de Recursos, VNet, Subnets)**
    *   Abra um terminal (PowerShell ou Bash) na pasta `04-Networking/VPN-PointToSite`.
    *   Execute o script:
        ```bash
        azcli 01-network-infra.azcli
        ```
    *   Este script criará o Grupo de Recursos, a VNet e as subnets necessárias.

2.  **Criar o VPN Gateway**
    *   No mesmo terminal, execute o script:
        ```bash
        azcli 02-vpn-gateway.azcli
        ```
    *   **Atenção**: A criação do VPN Gateway pode levar de 30 a 45 minutos. O script usará `--no-wait`, então ele retornará imediatamente.
    *   **Monitore o status**: Antes de prosseguir para o próximo passo, verifique se o VPN Gateway está totalmente provisionado. Você pode usar o comando:
        ```bash
        az network vnet-gateway show -g rg-vpn-p2s -n vnet-p2s-gw -o table
        ```
        Aguarde até que o `ProvisioningState` esteja como `Succeeded`.

3.  **Configurar a Integração com Azure AD**
    *   **Certifique-se de que o VPN Gateway está provisionado (Passo 2 concluído).**
    *   No mesmo terminal, execute o script:
        ```bash
        azcli 03-aad-integration.azcli
        ```
    *   Este script criará o App Registration no Azure AD e configurará o VPN Gateway para usar a autenticação Azure AD.

4.  **Baixar o Pacote de Configuração do Cliente VPN**
    *   Abra um terminal **PowerShell** na pasta `04-Networking/VPN-PointToSite`.
    *   Execute o script:
        ```powershell
        .\04-client-config.ps1
        ```
    *   Este script baixará um arquivo ZIP contendo o instalador do cliente VPN e o perfil de conexão para a pasta `.\VPNClientConfiguration`.
    *   Siga as instruções de instalação e importação do perfil fornecidas pelo script.

5.  **Testar a Conectividade VPN**
    *   Após instalar o cliente VPN e importar o perfil, conecte-se usando suas credenciais do Azure AD.
    *   Verifique se você consegue acessar recursos dentro da `vnet-p2s` (por exemplo, se você tiver uma VM na `VMsSubnet`).

6.  **Limpeza dos Recursos (Opcional, mas recomendado)**
    *   Quando terminar seus estudos e testes, para evitar custos, execute o script de limpeza.
    *   Abra um terminal (PowerShell ou Bash) na pasta `04-Networking/VPN-PointToSite`.
    *   Execute o script:
        ```bash
        azcli 05-cleanup.azcli
        ```
    *   Este script removerá o Grupo de Recursos e o App Registration do Azure AD.
