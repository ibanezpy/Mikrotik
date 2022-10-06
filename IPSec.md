## CONFIGURACION DE IPSEC EN MIKROTIK

Para este laboratorio utilizamos dos MIKROTIKS. 

IBANEZ_R1
* WAN = 172.27.15.150/20
* LAN = 192.168.100.1/24

IBANEZ_R2
* WAN = 172.27.15.100/20
* LAN = 192.168.50.1/24

## Pequeño resumen de los pasos a realizar.

0 Tener configurado la WAN y LAN de ambos routers.

1 Configurar nuestro PEER
 - Definir address destino
 - Definir local address.
 - No es necesario tocar el puerto

2 Configurar la Identity
 - Definimos la contraseña para establecer la VPN.

3 Definir el policy
 - Definimos el tunel, origen y destino de las LAN's.

4 Habilitar Firewall-NAT la comunicacion entre las LAN's.
 - Habilitamos que funcionen las redes entre si.


Esta configuracion es en capa 3 (en el router), abajo se puede observar el codigo para colocar en el ROUTER 1 y ROUTER 2.

```
#BACKUP DE AMBOS ROUTERS ANTES DE TOCAR (EN CASO DE SER NECESARIO)
/export terse file=[/system identity get name]
/system backup save name=([/system identity get name]."_ENC")
/system backup save dont-encrypt=yes name=[/system identity get name]

#CONFIGURACION DEL ROUTER 1
/interface wireless set [ find default-name=wlan1 ] ssid=MikroTik
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/ip ipsec peer add address=172.27.15.100/32 local-address=172.27.15.150 name=A_R2
/ip pool add name=dhcp_pool0 ranges=192.168.100.2-192.168.100.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=ether3 name=dhcp1
/ip address add address=172.27.15.150/20 interface=ether1 network=172.27.0.0
/ip address add address=192.168.100.1/24 interface=ether3 network=192.168.100.0
/ip dhcp-server network add address=192.168.100.0/24 gateway=192.168.100.1
/ip dns set allow-remote-requests=yes servers=8.8.8.8
/ip firewall nat add action=accept chain=srcnat dst-address=192.168.50.0/24 src-address=192.168.100.0/24
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1
/ip ipsec identity add peer=A_R2 secret=Ibanez_2019
/ip ipsec policy add dst-address=192.168.50.0/24 peer=A_R2 sa-dst-address=172.27.15.100 sa-src-address=172.27.15.150 src-address=192.168.100.0/24 tunnel=yes
/ip route add distance=1 gateway=172.27.0.1
/system clock set time-zone-name=America/Asuncion
/system identity set name=IBANEZ_R1
/system ntp client set enabled=yes

#CONFIGURACION DEL ROUTER 2
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/ip ipsec peer add address=172.27.15.150/32 local-address=172.27.15.100 name=A_R1
/ip pool add name=dhcp_pool0 ranges=192.168.50.2-192.168.50.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=ether3 name=dhcp1
/tool user-manager customer set admin access=own-routers,own-users,own-profiles,own-limits,config-payment-gw
/ip address add address=172.27.15.100/20 interface=ether1 network=172.27.0.0
/ip address add address=192.168.50.1/24 interface=ether3 network=192.168.50.0
/ip dhcp-server network add address=192.168.50.0/24 gateway=192.168.50.1
/ip dns set allow-remote-requests=yes servers=8.8.8.8
/ip firewall nat add action=accept chain=srcnat dst-address=192.168.100.0/24 src-address=192.168.50.0/24
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether1
/ip ipsec identity add peer=A_R1 secret=Ibanez_2019
/ip ipsec policy add dst-address=192.168.100.0/24 peer=A_R1 sa-dst-address=172.27.15.150 sa-src-address=172.27.15.100 src-address=192.168.50.0/24 tunnel=yes
/ip ipsec policy set 1 disabled=yes
/ip route add distance=1 gateway=172.27.0.1
/system clock set time-zone-name=America/Asuncion
/system identity set name=IBANEZ_R2
/system lcd set contrast=0 enabled=no port=parallel type=24x4
/system lcd page set time disabled=yes display-time=5s
/system lcd page set resources disabled=yes display-time=5s
/system lcd page set uptime disabled=yes display-time=5s
/system lcd page set packets disabled=yes display-time=5s
/system lcd page set bits disabled=yes display-time=5s
/system lcd page set version disabled=yes display-time=5s
/system lcd page set identity disabled=yes display-time=5s
/system lcd page set ether1 disabled=yes display-time=5s
/system lcd page set ether2 disabled=yes display-time=5s
/system lcd page set ether3 disabled=yes display-time=5s
/system lcd page set ether4 disabled=yes display-time=5s
/system lcd page set ether5 disabled=yes display-time=5s
/system ntp client set enabled=yes
/tool user-manager database set db-path=user-manager
```

Listo ya tenemos completamente configurado la VPN y ambas LAN's se van a poder comunicar.

