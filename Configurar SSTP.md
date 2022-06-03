# CONFIGURACION DE SSTP EN MIKROTIK
Este tipo de configuracion para VPN es muy utilizado en ambientes windows porque es un protocolo desarrollado por ellos. Lo bueno que tiene esta VPN es que se arma utilizando certificados y el puerto https (por lo general habilitado en todos los firewallds).

La creacion de los certificados los realizo de forma manual, solo necesita el certificado CA y SERVER.  
Ambos certificados deben de estar en modo trust.  

A continuacion los comandos para crear el DHCP y PPP para el servicio SSTP.  

```
/ip address add address=200.1.200.2/30 interface=ether1 network=200.1.200.0
/ip address add address=192.168.20.1/24 interface=ether4 network=192.168.20.0

/ip pool add name=Pool-VPN ranges=10.75.75.10-10.75.75.20
/ppp profile add dns-server=10.75.75.1 local-address=10.75.75.1 name=SSTP01 remote-address=Pool-VPN use-encryption=required use-ipv6=default

/interface sstp-server server set authentication=mschap2 certificate=SERVER default-profile=SSTP01 enabled=yes force-aes=yes pfs=yes tls-version=only-1.2

/ip firewall filter add action=accept chain=forward
/ip firewall filter add action=accept chain=input

/ppp secret add name=ibanez password=ibanez profile=SSTP01 service=sstp
```

### Configuracion en clientes WINDOWS

Esta parte es muy sencilla, solo se debe de importa el certificado en la entidad root. Una vez importado el certifiacado agregamos una nueva red VPN apuntando al Servidor VPN e ingresando nuestro usuario y contraseña.

### Configuracion en clientes MIKROTIK

Se debe de configurar el SSTP Client ubicado en la pestaña de PPP. NO es necesario importa el certificado, solo se necesita apuntar al servidor VPN para agremas su usuario y contraseña.

Debemos de hacer un masquarade y definir una ruta por defecto a travez de la interface PPP que se nos habilita una vez conectada la VPN.