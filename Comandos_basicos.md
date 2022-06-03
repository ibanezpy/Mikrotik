

### Comando para cambiar el nombre de router
/system identity set name=RO_IBANEZ

### Bloquear socket del router
/ip socks access add action=deny

### Se define el bridge_lan y se asignan las interfaces que van a funcionan como LAN
/interface bridge add fast-forward=no name=bridge_lan  
/interface bridge port add bridge=bridge_lan hw=no interface=ether2  
/interface bridge port add bridge=bridge_lan hw=no interface=ether3  
/interface bridge port add bridge=bridge_lan hw=no interface=ether4  
/interface bridge port add bridge=bridge_lan hw=no interface=ether5

### Crear las listas para asignar las interfaces WAN/LAN
/interface list add name=Externas  
/interface list add name=Internas
  
### Asignación de las interfaces a las listas definidas
/interface list member add interface=ether1 list=Externas  
/interface list member add interface=bridge_lan list=Internas

### Asingación de las IPS a las interfaces
/ip address add address=192.168.200.1/24 interface=bridge_lan network=192.168.200.0  
/ip address add address=172.27.15.100/20 interface=ether1 network=172.27.0.0

### Agregar el default GW del router
/ip route add distance=1 gateway=172.27.0.1

### Definición del DNS
/ip dns set allow-remote-requests=yes cache-size=4096KiB servers=172.27.1.60,172.27.1.62

### Definición rango IP para la asignación DHCP
/ip pool add name=dhcp_pool_lan ranges=192.168.200.100-192.168.200.199

### Asignación del DHCP a la Interface bridge
/ip dhcp-server add address-pool=dhcp_pool_lan disabled=no interface=bridge_lan lease-time=12h name=dhcp_lan

### Asignación de RED, DNS y GW
/ip dhcp-server network add address=192.168.200.0/24 dns-server=192.168.200.254 domain=ibanez.lan gateway=192.168.200.1 ntp-server=192.168.200.1

### Definición de los accesos al MIKROTIK
/ip firewall address-list add address=10.0.0.0/8 list=RFC1918  
/ip firewall address-list add address=172.16.0.0/12 list=RFC1918  
/ip firewall address-list add address=192.168.0.0/16 list=RFC1918  
/ip firewall address-list add address=10.1.1.0/24 list=vpn_sucursal  
/ip firewall address-list add address=172.27.0.0/20 list=SOPORTE_REMOTO

### Realizar los masquerade y que salgan a traves de la WAN

/ip firewall nat add action=masquerade chain=srcnat dst-address-list=!RFC1918 out-interface=ether1 src-address-list=RFC1918  
/ip firewall nat add action=masquerade chain=srcnat dst-address-type=!local log-prefix="NAT interno" src-address-list=RFC1918


### Acceso por medio de PORT_KNOCK
Esta regla lo que realiza es crear de manera temporal una excepción en el firewalld permitiendo conectarnos a traves de internet por un perido de 8 horas y luego la regla se borra automáticamente.

###### Pasos que realizar
1. telnet <IP> 666 (tiene una duración de 20 segundos)
2. telnet <IP> 888 (tiene una duración de 20 segundos)
3. telent <IP> 777 (tiene una duración de 8 horas)


```
/ip firewall filter add action=add-src-to-address-list address-list=PORT_KNOCK_J1 address-list-timeout=20s chain=port_knock dst-address-type=local dst-port=666 protocol=tcp src-address-list=!PORT_KNOCK_J1  
/ip firewall filter add action=add-src-to-address-list address-list=PORT_KNOCK_J2 address-list-timeout=20s chain=port_knock dst-address-type=local dst-port=888 protocol=tcp src-address-list=PORT_KNOCK_J1  
/ip firewall filter add action=add-src-to-address-list address-list=SOPORTE_REMOTO address-list-timeout=8h chain=port_knock dst-address-type=local dst-port=777 protocol=tcp src-address-list=PORT_KNOCK_J2  
/ip firewall filter add action=jump chain=input comment="Port knocking para SOPORTE_REMOTO - Secuencia 666, 888, 777" connection-state=new dst-address-type=local dst-port=666,888,777 jump-target=port_knock protocol=tcp place-before=1
```
### Politicas de INPUT 
/ip firewall filter add action=drop chain=input comment="Descartar consultas DNS Externas" dst-address-type=local dst-port=53 in-interface-list=Externas protocol=udp  
/ip firewall filter add action=accept chain=input comment="Related, Established" connection-state=established,related  
/ip firewall filter add action=accept chain=input comment=ACK+PSH protocol=tcp tcp-flags=psh,ack  
/ip firewall filter add action=drop chain=input comment=Invalid connection-state=invalid

### Blacklist por intentos fallidos de SSH
/ip firewall filter add action=reject chain=input comment=Blacklisted connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp reject-with=icmp-admin-prohibited src-address-list=sshbf_blacklist  
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_blacklist address-list-timeout=12h chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp src-address-list=sshbf_stage3  
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_stage3 address-list-timeout=5m chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp src-address-list=sshbf_stage2  
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_stage2 address-list-timeout=10m chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp src-address-list=sshbf_stage1  
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_stage1 address-list-timeout=5m chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp

### Reglas de acceso externo al router
/ip firewall filter add action=accept chain=input comment="Redes Internas" in-interface-list=Internas  
/ip firewall filter add action=accept chain=input comment="Permitir servicios vulnerables desde address list SOPORTE_REMOTO" in-interface-list=Externas protocol=tcp dst-port=8291,22,443,80 src-address-list=SOPORTE_REMOTO  
/ip firewall filter add action=accept chain=input comment="Permitir desde VPN" src-address-list=vpn_sucursal  
/ip firewall filter add action=accept chain=input comment="Broadcast interno" dst-address-type=broadcast in-interface-list=!Externas  
/ip firewall filter add action=accept chain=input comment=ICMP protocol=icmp  
/ip firewall filter add action=accept chain=input protocol=udp port=33434-33534 comment="Permitir traceroute UDP"  
/ip firewall filter add action=accept chain=input comment="Servicios TCP Externos" dst-address-type=local dst-port=1460,4443 in-interface-list=Externas protocol=tcp  
/ip firewall filter add action=accept chain=input comment="Servicios UDP Externos" dst-address-type=local dst-port=161 in-interface-list=Externas protocol=udp  

### Politicas de FORWARD
/ip firewall filter add action=accept chain=forward connection-state=established,related  
/ip firewall filter add action=accept chain=forward comment=Redirecciones connection-nat-state=dstnat in-interface-list=Externas  
/ip firewall filter add action=accept chain=forward connection-state=new in-interface-list=Internas  
/ip firewall filter add action=accept chain=forward in-interface=all-ppp  

### Bloqueo general de todos los puertos INPUT y FORWARD
/ip firewall filter add action=drop chain=input comment="Politica Final" log-prefix="INPUT: politica final"  
/ip firewall filter add action=drop chain=forward log-prefix="FWD: Politica Final"  

### Bloqueo de consultas DNS externas
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=udp src-address-list=!RFC1918  
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=tcp src-address-list=!RFC1918

### Deshabilitar los servicios MKTIK

/ip service set telnet disabled=yes port=23  
/ip service set ftp disabled=yes port=21  
/ip service set www disabled=yes port=80  
/ip service set ssh disabled=no port=22  
/ip service set www-ssl disabled=yes port=443  
/ip service set api disabled=yes port=8728  
/ip service set api-ssl disabled=yes port=8729  
/ip service set winbox disabled=no port=8291

### Cambiar hora y fecha del MKTIK
/system clock set time-zone-name=America/Asuncion
/system ntp client set enabled=yes primary-ntp=5.103.139.163 secondary-ntp=129.6.15.28
/system ntp server set broadcast=yes enabled=yes

### Backup automatico que se ejecuta a las 12:59:59
```
/system scheduler add interval=1d name=upgrade_routeros_diario on-event="/system package update \r\
    \ncheck-for-updates once\r\
    \n:delay 20s;\r\
    \n:if ( [get status] = \"New version is available\") do={ install }" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=aug/03/2018 start-time=00:59:59
```

### Backup manual que es almacenado en los files
/export terse file=[/system identity get name]  
/system backup save dont-encrypt=yes name=[/system identity get name]  
/system backup save name=([/system identity get name]."_ENC")

### Limita ancho de banda a 512K desde el 100 all 199 (por defecto está deshabilitado)
/system script add name=queue owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":for e from=100 to=199 do={\r\
   \n  /queue simple add disabled=yes max-limit=512k/512k target=\"192.168.200.\$e\"\r\
   \n}"
   
   
### NAT a IP Internas

```
/ip firewall nat add chain=dstnat dst-address=172.27.15.100 dst-port=65500 protocol=tcp action=dst-nat to-addresses=192.168.200.120 to-ports=22

```