# Network Security Group (NSG)

## Objetivo

Criar um grupo de segurança de rede, associá-lo a uma sub-rede e configurar uma regra personalizada de entrada no Azure.

## Recursos do laboratório

- Assinatura: `Azure subscription 1`
- Grupo de recursos: `rg-az104-lab`
- Região: `West US 2`
- VNet: `vnet-az104-lab` (`10.10.0.0/16`)
- Sub-rede: `snet-az104-app` (`10.10.1.0/24`)
- NSG: `nsg-az104-app`

## Etapas realizadas

1. Criado o NSG `nsg-az104-app` no grupo de recursos `rg-az104-lab`.
2. Associado o NSG à sub-rede `snet-az104-app`.
3. Criada a regra personalizada de entrada `Deny-SSH-Inbound`.

## Regra personalizada

| Propriedade | Valor |
|---|---|
| Nome | `Deny-SSH-Inbound` |
| Prioridade | `300` |
| Origem | Any |
| Porta de origem | `*` |
| Destino | Any |
| Serviço/porta de destino | SSH / TCP 22 |
| Ação | Negar |

A regra nega tráfego TCP de entrada destinado à porta 22 para recursos na sub-rede associada ao NSG. Como a origem está configurada como `Any`, a regra é ampla. Ela foi criada para fins didáticos; em um ambiente real, regras devem refletir os requisitos de conectividade e o princípio do menor privilégio. Não foi criada uma VM, portanto o tráfego não foi testado.

## Observação sobre prioridades

As regras personalizadas são avaliadas por prioridade em ordem crescente: números menores são avaliados primeiro. Como a regra `Deny-SSH-Inbound` tem prioridade `300`, ela é avaliada antes das regras padrão para o tráfego correspondente.