/interface bridge add name=bridge_lan
/interface ethernet set [ find default-name=ether1 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
/interface ethernet set [ find default-name=ether2 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
/interface ethernet set [ find default-name=ether3 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
/interface ethernet set [ find default-name=ether4 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
/interface ethernet set [ find default-name=ether5 ] advertise=10M-half,10M-full,100M-half,100M-full,1000M-half,1000M-full
/interface list add name=Externas
/interface list add name=Internas
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/interface wireless security-profiles add authentication-types=wpa-psk,wpa2-psk eap-methods="" mode=dynamic-keys name=ibanez supplicant-identity="" wpa-pre-shared-key=<password_wifi> wpa2-pre-shared-key=<password_wifi>
/interface wireless set [ find default-name=wlan1 ] antenna-gain=0 country=peru disabled=no frequency-mode=manual-txpower mode=ap-bridge security-profile=ibanez ssid=IGT station-roaming=enabled
/ip pool add name=dhcp_pool0 ranges=192.168.0.70-192.168.0.254
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=bridge_lan name=dhcp1
/snmp community set [ find default=yes ] addresses=0.0.0.0/0
/user group set full policy=local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon,dude,tikapp
/interface bridge port add bridge=bridge_lan interface=ether3
/interface bridge port add bridge=bridge_lan interface=ether4
/interface bridge port add bridge=bridge_lan interface=ether5
/interface bridge port add bridge=bridge_lan interface=ether2
/interface bridge port add bridge=bridge_lan interface=wlan1
/interface list member add interface=ether1 list=Externas
/interface list member add interface=bridge_lan list=Internas
/ip address add address=192.168.0.1/24 interface=bridge_lan network=192.168.0.0
/ip address add address=<ip/mask> disabled=yes interface=ether1 network=<segmento de red>
/ip dhcp-client add disabled=no interface=ether1
/ip dhcp-server network add address=192.168.0.0/24 gateway=192.168.0.1
/ip dns set allow-remote-requests=yes servers=8.8.8.8
/ip firewall address-list add address=10.0.0.0/8 list=RFC1918
/ip firewall address-list add address=172.16.0.0/12 list=RFC1918
/ip firewall address-list add address=192.168.0.0/16 list=RFC1918
/ip firewall address-list add address=10.1.1.0/24 list=vpn_sucursal
/ip firewall address-list add address=<IP público/mask> list=SOPORTE_REMOTO
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
/ip firewall nat add action=masquerade chain=srcnat dst-address-type=!local log-prefix="NAT interno" src-address-list=RFC1918
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=udp src-address-list=!RFC1918
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=tcp src-address-list=!RFC1918
/ip route add distance=1 gateway=<gateway>
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/system clock set time-zone-name=America/Asuncion
/system identity set name=RO_IBANEZ
