/interface bridge add name=bridge1
/interface ethernet set [ find default-name=ether1 ] comment="Entrada Internet" name="eth1 COPACO"
/interface ethernet set [ find default-name=ether2 ] name="eth2 TIGO"
/interface ethernet set [ find default-name=ether5 ] comment="Salida LAN" name="eth5 LAN"
/interface pppoe-client add disabled=no interface="eth1 COPACO" name=pppoe-out1 password=<pass> user=<user>
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/interface wireless security-profiles add authentication-types=wpa2-psk eap-methods="" management-protection=allowed mode=dynamic-keys name=profile1 supplicant-identity="" wpa2-pre-shared-key=rosenrot
/interface wireless set [ find default-name=wlan1 ] antenna-gain=0 band=2ghz-b/g/n country=no_country_set disabled=no frequency-mode=manual-txpower mode=ap-bridge security-profile=profile1 ssid="WiFi" wds-default-bridge=bridge1 wds-mode=dynamic wireless-protocol=802.11
/ip pool add name=dhcp_pool0 ranges=192.168.4.100-192.168.4.199
/ip dhcp-server add address-pool=dhcp_pool0 disabled=no interface=bridge1 name=dhcp1
/interface bridge port add bridge=bridge1 interface="eth5 LAN"
/interface bridge port add bridge=bridge1 interface=wlan1
/interface bridge port add bridge=bridge1 interface=ether3
/ip address add address=192.168.4.69/24 interface="eth5 LAN" network=192.168.4.0
/ip address add address=<ip/mask> disabled=yes interface="eth2 TIGO" network=<red>
/ip address add address=<ip/mask> interface="eth2 TIGO" network=<red>
/ip dhcp-client add add-default-route=no dhcp-options=hostname,clientid,clientid_duid disabled=no interface="eth2 TIGO"
/ip dhcp-server network add address=192.168.4.0/24 gateway=192.168.4.69
/ip dns set servers=8.8.8.8,9.9.9.9,201.217.1.230,200.85.32.2,186.16.16.16,186.17.17.17
/ip firewall mangle add action=mark-connection chain=prerouting comment="Marca de conexiones" in-interface=pppoe-out1 new-connection-mark=ether1_conn
/ip firewall mangle add action=mark-connection chain=prerouting in-interface="eth2 TIGO" new-connection-mark=ether2_conn
/ip firewall mangle add action=mark-routing chain=output comment=Salida connection-mark=ether1_conn new-routing-mark=to_ether1
/ip firewall mangle add action=mark-routing chain=output connection-mark=ether2_conn new-routing-mark=to_ether2
/ip firewall mangle add action=mark-connection chain=prerouting comment="Wan(1) de 5 megas" connection-mark=no-mark dst-address-type=!local in-interface=bridge1 new-connection-mark=ether1_conn passthrough=yes per-connection-classifier=both-addresses:4/0
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=bridge1 new-connection-mark=ether1_conn passthrough=yes per-connection-classifier=both-addresses:4/1
/ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface=bridge1 new-connection-mark=ether1_conn passthrough=yes per-connection-classifier=both-addresses:4/2
/ip firewall mangle add action=mark-connection chain=prerouting comment="Wan(2) 2 megas" connection-mark=no-mark dst-address-type=!local in-interface=bridge1 new-connection-mark=ether2_conn passthrough=yes per-connection-classifier=both-addresses:4/3
/ip firewall nat add action=masquerade chain=srcnat comment="Wan 1" out-interface=pppoe-out1
/ip firewall nat add action=masquerade chain=srcnat comment="Wan 2" out-interface="eth2 TIGO"
/ip firewall nat add action=dst-nat chain=dstnat comment="NAT DE COPACO" dst-address=<ip> dst-port=<port> protocol=tcp to-addresses=<ip> to-ports=<port>
/ip firewall nat add action=dst-nat chain=dstnat comment="NAT DE TIGO" dst-port=<port> in-interface="eth2 TIGO" protocol=tcp to-addresses=<ip> to-ports=<port>
/ip firewall nat add action=dst-nat chain=dstnat dst-port=<port> in-interface="eth2 TIGO" protocol=tcp to-addresses=<ip> to-ports=<port>
/ip firewall nat add action=dst-nat chain=dstnat dst-address=<ip> dst-port=<port> protocol=tcp to-addresses=<ip> to-ports=<port>
/ip firewall nat add action=dst-nat chain=dstnat dst-port=<port> in-interface="eth2 TIGO" protocol=tcp to-addresses=<ip> to-ports=<port>
/ip firewall nat add action=masquerade chain=srcnat out-interface=ether4
/ip firewall service-port set sip disabled=yes
/ip route add check-gateway=ping comment="Ruteo wan 1" distance=1 gateway=pppoe-out1 routing-mark=to_ether1
/ip route add check-gateway=ping comment="Ruteo wan 2" distance=1 gateway=<gateway> routing-mark=to_ether2
/ip route add disabled=yes distance=3 gateway=<gateway> routing-mark=to_ether4
/ip route add check-gateway=ping comment="Wan 1" distance=1 gateway=pppoe-out1
/ip route add check-gateway=ping comment="Wan 2 -- Desconectado cable de red" disabled=yes distance=2 gateway=<gateway>
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www port=8069
/ip service set ssh port=2269
/ip service set api disabled=yes
/ip service set winbox port=8269
/ip service set api-ssl disabled=yes
/ip ssh set allow-none-crypto=yes forwarding-enabled=remote
/system clock set time-zone-name=America/Asuncion
/system identity set name="MikroTik Ibanez"
