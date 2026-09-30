# Tabelas de rotas e rotas definidas pelo usuário (UDR)

## Objetivo

Compreender como o Azure determina o caminho do tráfego de rede e como uma tabela de rotas com rotas definidas pelo usuário (UDR) pode alterar esse caminho. Este exercício é conceitual: nenhum recurso será criado ou alterado no Azure.

## Conceitos

Cada subnet de uma rede virtual do Azure recebe rotas do sistema. Essas rotas permitem a comunicação dentro da rede virtual, com redes conectadas por peering e com a Internet, conforme o destino e as configurações aplicáveis.

Uma tabela de rotas pode conter rotas definidas pelo usuário. Cada rota especifica um prefixo de endereço de destino e um tipo de próximo salto. A tabela precisa ser associada a uma subnet para que suas rotas se apliquem ao tráfego originado nela.

Uma UDR controla o caminho de encaminhamento; ela não cria conectividade por si só. O próximo salto deve existir e estar configurado para encaminhar o tráfego. NSGs e outros controles de rede continuam sendo aplicados.

## Como o Azure escolhe uma rota

O Azure seleciona a rota aplicável com o prefixo mais específico para o endereço de destino. Por exemplo, uma rota para `10.20.1.0/24` é mais específica do que outra para `10.20.0.0/16`.

Quando há rotas para o mesmo prefixo, a prioridade geral é:

1. Rota definida pelo usuário (UDR)
2. Rota aprendida por BGP
3. Rota do sistema

A escolha do caminho também depende do tipo de próximo salto e da configuração dos recursos envolvidos.

## Tipos comuns de próximo salto

- `Virtual network`: encaminha o tráfego dentro da rede virtual.
- `Virtual network peering`: encaminha o tráfego para uma rede virtual pareada, quando aplicável.
- `Internet`: encaminha o tráfego para a Internet.
- `Virtual appliance`: encaminha o tráfego para um dispositivo virtual de rede (NVA), como um firewall ou roteador.
- `Virtual network gateway`: encaminha o tráfego por um gateway de rede virtual.
- `None`: descarta o tráfego destinado ao prefixo da rota.

Os tipos disponíveis e o comportamento efetivo dependem do cenário e da configuração dos recursos do Azure.

## Exemplo conceitual com as VNets do laboratório

O laboratório possui:

- `vnet-az104-lab`: `10.10.0.0/16`
- `vnet-az104-peer`: `10.20.0.0/16`

As VNets têm peering estabelecido. Conceitualmente, uma rota para um destino na faixa `10.20.0.0/16` pode usar o peering como caminho de rede, desde que as configurações e as rotas efetivas permitam esse tráfego.

Para inspecionar o tráfego de uma subnet por meio de um NVA, seria necessário criar e configurar esse dispositivo e, em seguida, definir uma rota cujo próximo salto fosse `Virtual appliance`. Apenas criar essa rota não seria suficiente: o NVA precisaria estar disponível e configurado para encaminhar o tráfego.

Nenhuma UDR ou NVA será criada neste exercício.

## Associação e escopo

Uma tabela de rotas é associada a uma subnet. As rotas definidas nela se aplicam ao tráfego encaminhado a partir dessa subnet. A associação não substitui o peering, os gateways, os NSGs ou a configuração do próximo salto.

Antes de alterar uma tabela em um ambiente existente, é importante revisar as rotas efetivas da interface de rede e considerar como a alteração pode afetar a conectividade.

## Limitações deste exercício

Este documento registra conceitos e um cenário hipotético. Nenhuma tabela de rotas foi criada, associada ou testada no Azure. Portanto, não houve validação de conectividade nem alteração nas VNets do laboratório.

Um teste prático poderá ser feito posteriormente, após revisar os custos e decidir quais recursos serão necessários. Um NVA ou máquinas virtuais usados como próximos saltos podem gerar custos.

## Resumo

- Rotas determinam como o tráfego é encaminhado para um destino.
- UDRs personalizam o caminho e são aplicadas por associação a uma subnet.
- O Azure escolhe primeiro a rota com o prefixo mais específico.
- Para o mesmo prefixo, UDR tem precedência sobre rota BGP e rota do sistema.
- Uma rota não substitui nem configura o próximo salto; os recursos necessários precisam existir e estar preparados.