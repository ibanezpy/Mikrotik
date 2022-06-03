# Configurando Mikrotik con seguridad y OpenVPN

## Primero nos encargaremos de habilitar la navegación del router

Con el codigo de abajo realizamos las siguentes configuraciones

*  Configurar bridge
*  DHCP Client para la WAN
*  Configurar lista Intera y Externa
*  Configuracion de PortNock
*  Configuración de Wifi
*  Configuración de acceso protegido la router

```
/interface bridge add fast-forward=no name=bridge_lan
/interface list add name=Externas
/interface list add name=Internas
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/interface wireless security-profiles add authentication-types=wpa2-psk eap-methods="" mode=dynamic-keys name=ibanezpass supplicant-identity="" wpa2-pre-shared-key=Ibanez.2021
/interface wireless set [ find default-name=wlan1 ] country=paraguay disabled=no mode=ap-bridge security-profile=ibanezpass ssid=IbanezMK
/ip pool add name=dhcp_pool0 ranges=192.168.200.2-192.168.200.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=bridge_lan name=dhcp1
/interface bridge port add bridge=bridge_lan hw=no interface=ether2
/interface bridge port add bridge=bridge_lan hw=no interface=ether3
/interface bridge port add bridge=bridge_lan hw=no interface=ether4
/interface bridge port add bridge=bridge_lan hw=no interface=ether5
/interface bridge port add bridge=bridge_lan interface=wlan1
/interface list member add interface=ether1 list=Externas
/interface list member add interface=bridge_lan list=Internas
/ip address add address=192.168.200.1/24 interface=bridge_lan network=192.168.200.0
/ip dhcp-client add disabled=no interface=ether1
/ip dhcp-server network add address=192.168.200.0/24 gateway=192.168.200.1
/ip dns set allow-remote-requests=yes
/ip firewall address-list add address=10.0.0.0/8 list=RFC1918
/ip firewall address-list add address=172.16.0.0/12 list=RFC1918
/ip firewall address-list add address=192.168.0.0/16 list=RFC1918
/ip firewall address-list add address=10.1.1.0/24 list=vpn_sucursal
/ip firewall address-list add address=170.238.19.32/27 list=SOPORTE_REMOTO
/ip firewall address-list add address=172.27.0.0/20 list=SOPORTE_REMOTO
/ip firewall filter add action=accept chain=input comment=VPN dst-port=1194 protocol=tcp
/ip firewall filter add action=add-src-to-address-list address-list=PORT_KNOCK_J1 address-list-timeout=20s chain=port_knock dst-address-type=local dst-port=666 protocol=tcp src-address-list=!PORT_KNOCK_J1
/ip firewall filter add action=add-src-to-address-list address-list=PORT_KNOCK_J2 address-list-timeout=20s chain=port_knock dst-address-type=local dst-port=888 protocol=tcp src-address-list=PORT_KNOCK_J1
/ip firewall filter add action=add-src-to-address-list address-list=SOPORTE_REMOTO address-list-timeout=8h chain=port_knock dst-address-type=local dst-port=777 protocol=tcp src-address-list=PORT_KNOCK_J2
/ip firewall filter add action=jump chain=input comment="Port knocking para SOPORTE_REMOTO - Secuencia 666, 888, 777" connection-state=new dst-address-type=local dst-port=666,888,777 jump-target=port_knock protocol=tcp
/ip firewall filter add action=drop chain=input comment="Descartar consultas DNS Externas" dst-address-type=local dst-port=53 in-interface-list=Externas protocol=udp
/ip firewall filter add action=accept chain=input comment="Related, Established" connection-state=established,related
/ip firewall filter add action=accept chain=input comment=ACK+PSH protocol=tcp tcp-flags=psh,ack
/ip firewall filter add action=drop chain=input comment=Invalid connection-state=invalid
/ip firewall filter add action=reject chain=input comment=Blacklisted connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp reject-with=icmp-admin-prohibited src-address-list=sshbf_blacklist
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_blacklist address-list-timeout=12h chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp src-address-list=sshbf_stage3
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_stage3 address-list-timeout=5m chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp src-address-list=sshbf_stage2
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_stage2 address-list-timeout=10m chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp src-address-list=sshbf_stage1
/ip firewall filter add action=add-src-to-address-list address-list=sshbf_stage1 address-list-timeout=5m chain=input connection-state=new dst-address-type=local dst-port=22 in-interface-list=Externas protocol=tcp
/ip firewall filter add action=accept chain=input comment="Redes Internas" in-interface-list=Internas
/ip firewall filter add action=accept chain=input comment="Permitir servicios vulnerables desde address list SOPORTE_REMOTO" dst-port=8291,22,443,80 in-interface-list=Externas protocol=tcp src-address-list=SOPORTE_REMOTO
/ip firewall filter add action=accept chain=input comment="Permitir desde VPN" src-address-list=vpn_sucursal
/ip firewall filter add action=accept chain=input comment="Broadcast interno" dst-address-type=broadcast in-interface-list=!Externas
/ip firewall filter add action=accept chain=input comment=ICMP protocol=icmp
/ip firewall filter add action=accept chain=input comment="Permitir traceroute UDP" port=33434-33534 protocol=udp
/ip firewall filter add action=accept chain=input comment="Servicios TCP Externos" dst-address-type=local dst-port=1460,4443 in-interface-list=Externas protocol=tcp
/ip firewall filter add action=accept chain=input comment="Servicios UDP Externos" dst-address-type=local dst-port=161 in-interface-list=Externas protocol=udp
/ip firewall filter add action=accept chain=forward connection-state=established,related
/ip firewall filter add action=accept chain=forward comment=Redirecciones connection-nat-state=dstnat in-interface-list=Externas
/ip firewall filter add action=accept chain=forward connection-state=new in-interface-list=Internas
/ip firewall filter add action=accept chain=forward in-interface=all-ppp
/ip firewall filter add action=drop chain=input comment="Politica Final" log-prefix="INPUT: politica final"
/ip firewall filter add action=drop chain=forward log-prefix="FWD: Politica Final"
/ip firewall nat add action=masquerade chain=srcnat dst-address-list=!RFC1918 out-interface=ether1 src-address-list=RFC1918
/ip firewall nat add action=masquerade chain=srcnat dst-address-type=!local log-prefix="Nat interno" src-address-list=RFC1918
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=udp src-address-list=!RFC1918
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=tcp src-address-list=!RFC1918
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip socks access add action=deny
/system clock set time-zone-name=America/Asuncion
/system identity set name=RO_IBANEZ
/system ntp client set enabled=yes primary-ntp=5.103.139.163 secondary-ntp=129.6.15.28
```

## Configurando la OpenVPN
Es muy importante realizar primero la configuración de arriba ya que ahora procederemos a generar y exportar los certificados para la utilización de la OpenVPN. Los certificados tienen una valides de 10 años.

```
/certificate add name=CA country="PY" state="ALTO PARANA" locality="CDE" organization="DATAPAR" unit="TI" common-name="CA" key-size=1024 days-valid=365000 key-usage=crl-sign,key-cert-sign
/certificate sign CA name="CA"
/certificate add name=SERVER country="PY" state="ALTO PARANA" locality="CDE" organization="DATPAR" unit="TI" common-name="SERVER" key-size=1024 days-valid=365000 key-usage=digital-signature,key-encipherment,tls-server
/certificate sign SERVER ca="CA" name="SERVER"
/certificate add name=CLIENT country="PY" state="ALTO PARANA" locality="CDE" organization="DATAPAR" unit="TI" common-name="CLIENT" key-size=1024 days-valid=365000 key-usage=tls-client
/certificate sign CLIENT ca="CA" name="CLIENT"
/certificate export-certificate CA export-passphrase=""
/certificate export-certificate CLIENT export-passphrase=datapar-py
/ip pool add name=ovpn ranges=10.70.70.50-10.70.70.100
/ppp profile add dns-server=10.70.70.1 local-address=ovpn name=open_vpn remote-address=ovpn use-compression=no use-encryption=required
/interface ovpn-server server set certificate=SERVER cipher=blowfish128,aes128,aes192,aes256 default-profile=open_vpn enabled=yes require-client-certificate=yes
/ip dhcp-server network add address=10.70.70.0/24 comment=vpn dns-server=10.70.70.1 gateway=10.70.70.1 netmask=24
/ppp secret add name=ibanez password=datapar profile=open_vpn service=ovpn
```

Listo, ya podemos bajar los certificados y utilizarlos.


## Archivo de configuración del OpenVPN para windows

El archivo OVPN es el encargado de realizar el marcado y utilizar los certificados.

```
proto tcp-client

remote 172.27.10.80 1194

dev tun
nobind

persist-key


tls-client
ca CA.crt
cert CLIENT.crt
key CLIENT.key

ping 10
verb 3

cipher AES-256-CBC

auth SHA1

pull
auth-user-pass auth.cfg
route 192.168.200.0 255.255.255.0 vpn_gateway
```

Configuración de OpenVPN con contraseñas en el certificado.


El archivo auth.cfg es el encargado de almacenar el usuario y contraseña del OpenVPN.

El archivo pass.txt es el encargado de almacenar la contraseña del certificado, ejemplo: datapar-py.

```
proto tcp-client

remote 170.233.219.33 1194

dev tun
nobind

persist-key


tls-client
ca CA.crt
cert CLIENT.crt
key CLIENT.key

ping 10
verb 3

cipher AES-256-CBC

auth SHA1

pull
askpass pass.txt
auth-user-pass auth-yagaurete.cfg
```

Creamos el archivo pass.txt con la contraseña del certificado, ejemplo: datapar-py

Saludos.