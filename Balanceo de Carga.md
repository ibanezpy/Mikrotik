# Configuración de balanceo de carga MIKROTIK
Configuración de dos ISP para realizar el balanceo de carga en la LAN, todos los paquetes son marcados para identificar porque que WAN ha salido.

El esquema que se utilizo fue el siguiente.

INTERNET_1 = 172.27.15.100/20   (DATAPAR)  
INTERNET_2 = 192.168.222.10/24  (CELULAR)  
LAN_IBANEZ = 192.168.200.1/24

El INTERNET_2 era proveidor por mi MIKROTIK, esto lo realize para tener una conexión de internet distina a DATAPAR. En este ejemplos estabamos usando los IPS DATAPAR y CLARO.

```
/interface ethernet set [ find default-name=ether1 ] name=INTERNET_1
/interface ethernet set [ find default-name=ether2 ] disabled=yes name=INTERNET_2
/interface ethernet set [ find default-name=ether5 ] name=LAN_IBANEZ
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/ip pool add name=dhcp_pool0 ranges=192.168.200.2-192.168.200.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=LAN_IBANEZ name=dhcp1
/tool user-manager customer set admin access=own-routers,own-users,own-profiles,own-limits,config-payment-gw
/ip address add address=192.168.200.1/24 interface=LAN_IBANEZ network=192.168.200.0
/ip address add address=172.27.15.100/20 interface=INTERNET_1 network=172.27.0.0
/ip address add address=192.168.222.10/24 interface=INTERNET_2 network=192.168.222.0
/ip dhcp-server network add address=192.168.200.0/24 gateway=192.168.200.1
/ip dns set servers=8.8.8.8
/ip firewall mangle add action=mark-connection chain=input in-interface=INTERNET_1 new-connection-mark=INTERNET_1_conn
/ip firewall mangle add action=mark-connection chain=input in-interface=INTERNET_2 new-connection-mark=INTERNET_2_conn
/ip firewall mangle add action=mark-routing chain=output connection-mark=INTERNET_1_conn new-routing-mark=to_INTERNET_1
/ip firewall mangle add action=mark-routing chain=output connection-mark=INTERNET_2_conn new-routing-mark=to_INTERNET_2
/ip firewall mangle add action=accept chain=prerouting dst-address=172.27.15.0/24 in-interface=LAN_IBANEZ
/ip firewall mangle add action=accept chain=prerouting dst-address=192.168.222.0/24 in-interface=LAN_IBANEZ
/ip firewall mangle add action=mark-connection chain=prerouting dst-address-type=!local in-interface=LAN_IBANEZ new-connection-mark=INTERNET_1_conn passthrough=yes per-connection-classifier=both-addresses:2/0
/ip firewall mangle add action=mark-connection chain=prerouting dst-address-type=!local in-interface=LAN_IBANEZ new-connection-mark=INTERNET_2_conn passthrough=yes per-connection-classifier=both-addresses:2/1
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=INTERNET_1_conn in-interface=LAN_IBANEZ new-routing-mark=to_INTERNET_1
/ip firewall mangle add action=mark-routing chain=prerouting connection-mark=INTERNET_2_conn in-interface=LAN_IBANEZ new-routing-mark=to_INTERNET_2
/ip firewall nat add action=masquerade chain=srcnat out-interface=INTERNET_1
/ip firewall nat add action=masquerade chain=srcnat out-interface=INTERNET_2
/ip route add check-gateway=ping distance=1 gateway=172.27.0.1 routing-mark=to_INTERNET_1
/ip route add check-gateway=ping distance=1 gateway=192.168.222.1 routing-mark=to_INTERNET_2
/ip route add check-gateway=ping distance=1 gateway=172.27.0.1
/ip route add check-gateway=ping distance=2 gateway=192.168.222.1
/ip socks access add action=deny
/system clock set time-zone-name=America/Asuncion
/system identity set name=RO_IBANEZ_DATAPAR
/system scheduler add disabled=yes interval=30s name=BAJAR_INTERNET_2 on-event=CHECK_INTERNET_2 policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
/system script add dont-require-permissions=yes name=CHECK_INTERNET_2 owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":if ([/interface get [/interface find name=\"INTERNET_2\"] running] = true) do={\r\
    \n\t/log info \"INTERNET_2 is running\"\r\
    \n\t:if ([/ping 192.168.222.1 interface=INTERNET_2 count=3] = 0) do={\r\
    \n\t\t:log info \"Enable interface INTERNET_2\"\r\
    \n\t\t[/interface disable INTERNET_2]\r\
    \n\t}\r\
    \n} else={\r\
    \n\t/log info \"INTERNET_2 is not running\"\r\
    \n\t:log info \"Enable interface INTERNET_2\"\r\
    \n\t[/interface enable INTERNET_2]\r\
    \n\t\t:if ([/ping 192.168.222.1 interface=INTERNET_2 count=10] = 0) do={\r\
    \n\t\t:log info \"Enable interface INTERNET_2\"\r\
    \n\t\t[/interface disable INTERNET_2]\r\
    \n\t}\r\
    \n}"

```