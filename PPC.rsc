/interface ethernet set [ find default-name=ether1 ] name=ether1-WAN1
/interface ethernet set [ find default-name=ether2 ] name=ether2-WAN2
/interface ethernet set [ find default-name=ether3 ] name=ether3-LAN
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/ip pool add name=dhcp_pool0 ranges=192.168.50.2-192.168.50.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=ether3-LAN name=dhcp1
/ip address add address=192.168.21.2/24 interface=ether1-WAN1 network=192.168.21.0
/ip address add address=192.168.22.2/24 interface=ether2-WAN2 network=192.168.22.0
/ip address add address=192.168.50.1/24 interface=ether3-LAN network=192.168.50.0
/ip dhcp-client add disabled=no interface=ether1-WAN1
/ip dhcp-server network add address=192.168.50.0/24 gateway=192.168.50.1
/ip dns set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4
/ip firewall mangle add action=accept chain=prerouting comment="MARCADO DE SEGMENTO DE RED DE GW" dst-address=192.168.21.0/24 in-interface=ether3-LAN
/ip firewall mangle add action=accept chain=prerouting dst-address=192.168.22.0/24 in-interface=ether3-LAN
/ip firewall mangle add action=mark-connection chain=prerouting comment="MARCADO CONEXIONES ROUTER WAN" connection-mark=no-mark in-interface=ether1-WAN1 new-connection-mark=ISP1_conexion passthrough=yes
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark in-interface=ether2-WAN2 new-connection-mark=ISP2_conexion passthrough=yes
/ip firewall mangle add action=mark-connection chain=prerouting comment="MARCADO DE BALANCEO LAN" connection-mark=no-mark dst-address-type=!local in-interface=ether3-LAN new-connection-mark=ISP1_conexion passthrough=yes per-connection-classifier=both-addresses:2/0
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=ether3-LAN new-connection-mark=ISP2_conexion passthrough=yes per-connection-classifier=both-addresses:2/1
/ip firewall mangle add action=mark-routing chain=prerouting comment="RESTO DEL TRAFICO" in-interface=ether3-LAN new-routing-mark=to_ISP1 passthrough=yes
/ip firewall mangle add action=mark-routing chain=prerouting in-interface=ether3-LAN new-routing-mark=to_ISP2 passthrough=yes
/ip firewall mangle add action=mark-routing chain=prerouting comment="MARCADO DE RUTAS DE CONEXIONES" connection-mark=ISP1_conexion in-interface=ether3-LAN new-routing-mark=to_ISP1 passthrough=yes
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=ISP2_conexion in-interface=ether3-LAN new-routing-mark=to_ISP2 passthrough=yes
/ip firewall mangle add action=mark-routing chain=output comment="MARCADO DE CONEXION" connection-mark=ISP1_conexion new-routing-mark=to_ISP1 passthrough=yes
/ip firewall mangle add action=mark-routing chain=output connection-mark=ISP2_conexion new-routing-mark=to_ISP2 passthrough=yes
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1-WAN1
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether2-WAN2
/ip route add check-gateway=ping distance=1 gateway=1.1.1.1 routing-mark=to_ISP1
/ip route add check-gateway=ping distance=1 gateway=9.9.9.9 routing-mark=to_ISP2
/ip route add check-gateway=ping distance=1 gateway=1.1.1.1
/ip route add check-gateway=ping distance=2 gateway=9.9.9.9
/ip route add distance=1 dst-address=1.1.1.1/32 gateway=192.168.21.1 scope=10
/ip route add distance=1 dst-address=9.9.9.9/32 gateway=192.168.22.1 scope=10
/system identity set name=RO_IBANEZ