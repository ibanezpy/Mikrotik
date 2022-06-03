# jun/03/2022 11:11:59 by RouterOS 6.49.6
# software id = 78UJ-8M2V
#
# model = 951Ui-2HnD
# serial number = 8157073FED88
/interface bridge add name=bridge_lan
/interface list add name=Externas
/interface list add name=Internas
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/interface wireless security-profiles add authentication-types=wpa2-psk eap-methods="" management-protection=allowed mode=dynamic-keys name=profile1 supplicant-identity="" wpa2-pre-shared-key=Datapar.2021
/interface wireless set [ find default-name=wlan1 ] antenna-gain=0 band=2ghz-b/g/n country=no_country_set disabled=no frequency-mode=manual-txpower mode=ap-bridge security-profile=profile1 ssid=Ibanez_LAR wds-default-bridge=bridge_lan wds-mode=dynamic wireless-protocol=802.11
/ip pool add name=dhcp_pool0 ranges=192.168.4.100-192.168.4.199
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=bridge_lan name=dhcp1
/interface bridge port add bridge=bridge_lan interface=ether3
/interface bridge port add bridge=bridge_lan interface=ether4
/interface bridge port add bridge=bridge_lan interface=ether5
/interface bridge port add bridge=bridge_lan interface=wlan1
/interface list member add interface=ether1 list=Externas
/interface list member add interface=bridge_lan list=Internas
/interface list member add interface=ether2 list=Externas
/ip address add address=192.168.4.69/24 interface=bridge_lan network=192.168.4.0
/ip dhcp-client add add-default-route=no disabled=no interface=ether2 use-peer-dns=no use-peer-ntp=no
/ip dhcp-client add add-default-route=no disabled=no interface=ether1 use-peer-dns=no use-peer-ntp=no
/ip dhcp-server network add address=192.168.4.0/24 gateway=192.168.4.69
/ip dns set allow-remote-requests=yes servers=8.8.8.8,9.9.9.9,201.217.1.230,200.85.32.2,186.16.16.16,186.17.17.17
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
/ip firewall mangle add action=mark-connection chain=prerouting comment="Marca de conexiones" in-interface=ether1 new-connection-mark=ether1_conn
/ip firewall mangle add action=mark-connection chain=prerouting in-interface=ether2 new-connection-mark=ether2_conn
/ip firewall mangle add action=mark-routing chain=output comment=Salida connection-mark=ether1_conn new-routing-mark=to_ether1
/ip firewall mangle add action=mark-routing chain=output connection-mark=ether2_conn new-routing-mark=to_ether2
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=bridge_lan new-connection-mark=ether1_conn passthrough=yes per-connection-classifier=both-addresses:2/0
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=bridge_lan new-connection-mark=ether2_conn passthrough=yes per-connection-classifier=both-addresses:2/1
/ip firewall nat add action=masquerade chain=srcnat comment="Wan 1" out-interface=ether1
/ip firewall nat add action=masquerade chain=srcnat comment="Wan 2" out-interface=ether2
/ip firewall nat add action=masquerade chain=srcnat dst-address-list=!RFC1918 out-interface-list=Externas src-address-list=RFC1918
/ip firewall nat add action=masquerade chain=srcnat dst-address-type=!local log-prefix="Nat interno" src-address-list=RFC1918
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=udp src-address-list=!RFC1918
/ip firewall raw add action=drop chain=prerouting dst-address-type=local dst-port=53 in-interface-list=Externas protocol=tcp src-address-list=!RFC1918
/ip firewall service-port set sip disabled=yes
/ip route add check-gateway=ping comment="Ruteo wan 1" distance=1 gateway=172.27.0.1 routing-mark=to_ether1
/ip route add check-gateway=ping comment="Ruteo wan 2" distance=1 gateway=192.168.100.1 routing-mark=to_ether2
/ip route add check-gateway=ping comment="Wan 1" distance=1 gateway=172.27.0.1
/ip route add check-gateway=ping comment="Wan 2" distance=2 gateway=192.168.100.1
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www port=8069
/ip service set ssh port=2269
/ip service set api disabled=yes
/ip service set winbox port=8269
/ip service set api-ssl disabled=yes
/ip ssh set allow-none-crypto=yes forwarding-enabled=remote
/system clock set time-zone-name=America/Asuncion
/system identity set name=IBANEZ_CENTRAL
/system script add dont-require-permissions=no name=Mario owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":beep frequency=660 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=510 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=770 length=100ms;\r\
    \n:delay 550ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 575ms;\r\
    \n\r\
    \n:beep frequency=510 length=100ms;\r\
    \n:delay 450ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 400ms;\r\
    \n:beep frequency=320 length=100ms;\r\
    \n:delay 500ms;\r\
    \n:beep frequency=440 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=480 length=80ms;\r\
    \n:delay 330ms;\r\
    \n:beep frequency=450 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 200ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 200ms;\r\
    \n:beep frequency=760 length=50ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=860 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=700 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=760 length=50ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=520 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=580 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=480 length=80ms;\r\
    \n:delay 500ms;\r\
    \n\r\
    \n:beep frequency=510 length=100ms;\r\
    \n:delay 450ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 400ms;\r\
    \n:beep frequency=320 length=100ms;\r\
    \n:delay 500ms;\r\
    \n:beep frequency=440 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=480 length=80ms;\r\
    \n:delay 330ms;\r\
    \n:beep frequency=450 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 200ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 200ms;\r\
    \n:beep frequency=760 length=50ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=860 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=700 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=760 length=50ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=520 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=580 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=480 length=80ms;\r\
    \n:delay 500ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=760 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=720 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=680 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=620 length=150ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=650 length=150ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=570 length=100ms;\r\
    \n:delay 220ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=760 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=720 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=680 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=620 length=150ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=650 length=200ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=1020 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=1020 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=1020 length=80ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=760 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=720 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=680 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=620 length=150ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=650 length=150ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=570 length=100ms;\r\
    \n:delay 420ms;\r\
    \n\r\
    \n:beep frequency=585 length=100ms;\r\
    \n:delay 450ms;\r\
    \n\r\
    \n:beep frequency=550 length=100ms;\r\
    \n:delay 420ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 360ms;\r\
    \n\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=760 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=720 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=680 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=620 length=150ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=650 length=150ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=570 length=100ms;\r\
    \n:delay 220ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=760 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=720 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=680 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=620 length=150ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=650 length=200ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=1020 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=1020 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=1020 length=80ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=760 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=720 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=680 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=620 length=150ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=650 length=150ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=430 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=570 length=100ms;\r\
    \n:delay 420ms;\r\
    \n\r\
    \n:beep frequency=585 length=100ms;\r\
    \n:delay 450ms;\r\
    \n\r\
    \n:beep frequency=550 length=100ms;\r\
    \n:delay 420ms;\r\
    \n\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 360ms;\r\
    \n\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=100ms;\r\
    \n:delay 300ms;\r\
    \n\r\
    \n:beep frequency=500 length=60ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=60ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=580 length=80ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=430 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=380 length=80ms;\r\
    \n:delay 600ms;\r\
    \n\r\
    \n:beep frequency=500 length=60ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=60ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=580 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 550ms;\r\
    \n\r\
    \n:beep frequency=870 length=80ms;\r\
    \n:delay 325ms;\r\
    \n:beep frequency=760 length=80ms;\r\
    \n:delay 600ms;\r\
    \n\r\
    \n:beep frequency=500 length=60ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=500 length=60ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=580 length=80ms;\r\
    \n:delay 350ms;\r\
    \n:beep frequency=660 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=500 length=80ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=430 length=80ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=380 length=80ms;\r\
    \n:delay 600ms;\r\
    \n\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=510 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=770 length=100ms;\r\
    \n:delay 550ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 575ms;"
/system script add dont-require-permissions=no name=Samba owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=659 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=880 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=880 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=988 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=784 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=988 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=1319 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=1175 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1319 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1480 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=1175 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=988 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=988 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=988 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=880 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=784 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=880 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=988 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1568 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1175 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1319 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1480 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1175 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=1800ms; \r\
    \n:delay 1810ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=659 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=880 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=880 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=988 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=784 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=988 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=1319 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=1175 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1319 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1480 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=1175 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=988 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=988 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=988 length=300ms; \r\
    \n:delay 310ms; \r\
    \n:beep frequency=880 length=600ms; \r\
    \n:delay 610ms; \r\
    \n:beep frequency=784 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=880 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=988 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=784 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=659 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1568 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1175 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1319 length=225ms; \r\
    \n:delay 235ms; \r\
    \n:beep frequency=1480 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1175 length=450ms; \r\
    \n:delay 460ms; \r\
    \n:beep frequency=1319 length=1200ms; \r\
    \n:delay 1210ms;"
