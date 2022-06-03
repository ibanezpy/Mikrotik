# Configuración de PCE en MIKROTIK

El el codigo de abajo se configuro el mikrotik de la siguiente manera. Se utilizo mi celular para que sea el proveedor de internet del mikrotik por medio de su interface wireless.

Al interface WAN viene a ser la interface wireless del MIKROTIK y las demas interfaces LAN.

El celular utilizado es un SONY con el SSID: ibanez.


```
/interface bridge add name=bridge1
/interface wireless set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-Ce country=paraguay disabled=no ssid=Ibanez wireless-protocol=nv2-nstreme-802.11
/interface list add name=WAN
/interface list add name=LAN
/interface wireless security-profiles set [ find default=yes ] authentication-types=wpa-psk,wpa2-psk group-ciphers=tkip,aes-ccm mode=dynamic-keys supplicant-identity=MikroTik unicast-ciphers=tkip,aes-ccm wpa-pre-shared-key=ibanez182 wpa2-pre-shared-key=ibanez182
/ip hotspot profile set [ find default=yes ] html-directory=flash/hotspot
/ip pool add name=dhcp ranges=192.168.222.100-192.168.222.254
/ip pool add name=dhcp_pool1 ranges=192.168.222.2-192.168.222.254
/ip dhcp-server add address-pool=dhcp_pool1 disabled=no interface=bridge1 name=dhcp1
/interface bridge port add bridge=bridge1 interface=ether1
/interface bridge port add bridge=bridge1 interface=ether2
/interface bridge port add bridge=bridge1 interface=ether3
/interface bridge port add bridge=bridge1 interface=ether4
/interface bridge port add bridge=bridge1 interface=ether5
/interface list member add interface=wlan1 list=WAN
/interface list member add list=LAN
/interface list member add interface=bridge1 list=LAN
/ip address add address=192.168.222.1/24 interface=ether1 network=192.168.222.0
/ip dhcp-client add dhcp-options=hostname,clientid disabled=no interface=wlan1
/ip dhcp-server network add address=192.168.222.0/24 dns-server=8.8.8.8 gateway=192.168.222.1
/ip firewall nat add action=masquerade chain=srcnat out-interface=wlan1
/system clock set time-zone-name=America/Asuncion
/system identity set name=Ibanez_Wifi
```