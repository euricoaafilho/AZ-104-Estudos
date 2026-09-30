Peering entre redes virtuais (VNet Peering)
Objetivo
Praticar a configuração de peering entre duas redes virtuais do Azure e verificar o estado da conexão no portal.

Topologia

VNet	Grupo de recursos	Região	Espaço de endereços	Sub-rede
vnet-az104-lab	rg-az104-lab	West US 2	10.10.0.0/16	snet-az104-app (10.10.1.0/24) e snet-az104-admin (10.10.2.0/24)
vnet-az104-peer	rg-az104-lab	West US 2	10.20.0.0/16	snet-az104-peer (10.20.1.0/24)

Os espaços de endereços são distintos e não se sobrepõem.

Peerings configurados


VNet local	VNet remota	Nome do peering exibido	Estado observado
vnet-az104-lab	vnet-az104-peer	peer-peer-to-az104	Connected / Totalmente Sincronizado
vnet-az104-peer	vnet-az104-lab	peer-az104-to-peer	Connected / Totalmente Sincronizado

Os nomes foram mantidos como aparecem no portal. Eles são identificadores dos peerings e não alteram a direção nem a conectividade.

Opções
O acesso à rede virtual está habilitado nos dois sentidos. O tráfego encaminhado e o uso de gateway remoto não estão habilitados.

Resultado e limitações do teste
O estado Connected e a sincronização completa confirmam que os peerings estão estabelecidos. Ainda não foi testado tráfego entre dispositivos: não há VMs nas redes para validar conectividade de ponta a ponta.

Custos
O peering pode gerar cobrança pelo tráfego transferido entre as redes. VMs e discos também podem gerar custos se forem criados para testes posteriores. Revise os preços e a estimativa na assinatura antes de adicionar recursos.


