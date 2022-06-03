## BALANCEO DE CARGA CON PCC EN MIKROTIK

Script para realizar balanceo de carga con dos o más enlaces de internet utilizando PCC.

Configuración de dos ISP para realizar el balanceo de carga en la LAN, todos los paquetes son marcados para identificar porque que WAN ha salido.

El esquema que se utilizo fue el siguiente.

ISP1 = 172.27.15.100/20 (DATAPAR)  
ISP2 = 192.168.60.1/30 (ROUTER EXTRA)  
LAN = 10.10.70.1/24

El INTERNET_2 era proveidor por mi MIKROTIK, se conecta a la red de DATAPAR y dicho router entrega el segmento de red 192.168.60.0/30 a traves de la LAN.


```
/interface ethernet set [ find default-name=ether1 ] name=ISP1
/interface ethernet set [ find default-name=ether2 ] name=ISP2
/interface ethernet set [ find default-name=ether3 ] name=LAN

/ip pool add name=dhcp_pool0 ranges=10.10.70.2-10.10.70.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=LAN name=dhcp1
/ip address add address=172.27.15.100/20 interface=ISP1 network=172.27.0.0
/ip address add address=192.168.60.2/30 interface=ISP2 network=192.168.60.0
/ip address add address=10.10.70.1/24 interface=LAN network=10.10.70.0
/ip dhcp-server network add address=10.10.70.0/24 gateway=10.10.70.1
/ip dns set allow-remote-requests=yes servers=8.8.8.8

/ip firewall mangle add action=accept chain=prerouting dst-address=172.27.0.0/20 in-interface=LAN
/ip firewall mangle add action=accept chain=prerouting dst-address=192.168.60.0/30 in-interface=LAN
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark in-interface=ISP1 new-connection-mark=ISP1_conn
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark in-interface=ISP2 new-connection-mark=ISP2_conn
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=LAN new-connection-mark=ISP1_conn per-connection-classifier=both-addresses:2/0
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=LAN new-connection-mark=ISP2_conn per-connection-classifier=both-addresses:2/1
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=ISP1_conn in-interface=LAN new-routing-mark=to_ISP1
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=ISP2_conn in-interface=LAN new-routing-mark=to_ISP2
/ip firewall mangle add action=mark-routing chain=output connection-mark=ISP1_conn new-routing-mark=to_ISP1
/ip firewall mangle add action=mark-routing chain=output connection-mark=ISP2_conn new-routing-mark=to_ISP2
/ip firewall nat add action=masquerade chain=srcnat out-interface=ISP1
/ip firewall nat add action=masquerade chain=srcnat out-interface=ISP2

/ip route add check-gateway=ping distance=1 gateway=172.27.0.1 routing-mark=to_ISP1
/ip route add check-gateway=ping distance=1 gateway=192.168.60.1 routing-mark=to_ISP2
/ip route add check-gateway=ping distance=1 gateway=172.27.0.1
/ip route add check-gateway=ping distance=2 gateway=192.168.60.1

/system clock set time-zone-name=America/Asuncion
```