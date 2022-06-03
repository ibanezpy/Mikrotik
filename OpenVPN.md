# CONFIGURACION DE OPENVPN SERVER MIKROTIK
En la linea de abajo creamos los certificados que van a ser utilizados para el servidor y el cliente de la OpenVPN.

### Generate and sign the certificates:
```
/certificate add name=CA country="PY" state="ALTO PARANA" locality="CDE" organization="DATAPAR" unit="TI" common-name="CA" key-size=4096 days-valid=365000 key-usage=crl-sign,key-cert-sign
/certificate sign CA name="CA"

/certificate add name=SERVER country="PY" state="ALTO PARANA" locality="CDE" organization="DATPAR" unit="TI" common-name="SERVER" key-size=4096 days-valid=365000 key-usage=digital-signature,key-encipherment,tls-server
sign SERVER ca="CA" name="SERVER"

/certificate add name=CLIENT country="PY" state="ALTO PARANA" locality="CDE" organization="DATAPAR" unit="TI" common-name="CLIENT" key-size=4096 days-valid=365000 key-usage=tls-client
/certificate sign CLIENT ca="CA" name="CLIENT"
```

### Export and download the certificates and key:

Exportamos las llaves que vamos a instalar luego en nuestro sistema operativo o router, las llaves podes descargarlo en *FILES*.

```
/certificate export-certificate CA export-passphrase=""
/certificate export-certificate CLIENT export-passphrase=datapar-py
```

### Set the OVPN server on the router:

Configuramos las IP, interfaces, nateos, etc por donde van a funcionar la OpenVPN.

```
/ip pool add name=ovpn ranges=10.70.70.50-10.70.70.60
/ip dhcp-server network add address=10.70.70.0/24 comment=vpn dns-server=10.70.70.1 gateway=10.70.70.1 netmask=24

/ppp profile add dns-server=10.70.70.1 local-address=ovpn name=open_vpn remote-address=ovpn use-compression=no use-encryption=required
/interface ovpn-server server set certificate=SERVER cipher=blowfish128,aes128,aes192,aes256 default-profile=open_vpn enabled=yes require-client-certificate=yes

/ppp secret add name=ibanez password=datapar profile=open_vpn service=ovpn

/ip firewall filter add action=accept chain=input comment=VPN dst-port=1194 protocol=tcp

```

# CONFIGURAMOS EL CLIENTE OPENVPN
En esta parte vamos a tratar de como se conecta al OpenVPN server mediante un clientes windows (una pc norma) y como se configura un router Mikrotik para que toda la red interna salga a traves de la OpenVPN.

## Configuración de OpenVPN Client Windows

Debemos de descargar los certificados:
1. ca.crt
2. client.crt
3. client.key

Una vez descargado los certificados los debemos de colocar el la carpeta donde tenemos instalado el OpenVPN *C:\Program Files\OpenVPN\config* (es para mi caso). 

Luego debemos de crear dos archivos más dentro de la misma carpeta donde hemos puesto los certificados.
1. cliente.ovpn (en la linea de abajo se puede observar lo que debe ir dentro de esté archivo). 
```
client
dev tun
proto tcp-client
remote 200.1.200.1 -- IP del Servidor OpenVPN
port 1194 -- Puerto del servidor OpenVPN, por default es 1194
nobind
persist-key
persist-tun
tls-client
remote-cert-tls server
#Colocamos los tres certificados generados por el OPENVPN
ca ca.crt
cert client1.crt
key client1.key
verb 4
mute 10
cipher AES-256-CBC
auth SHA1
#colocamos nuestro usuario y contrasena
auth-user-pass auth.cfg
auth-nocache
redirect-gateway def1
```
2. auth.cfg (debemos de colocar nuestro usuario y contraseña que fueron creados en el servidor OpenVPN
```
ibanez
datapar
```

Obs: Este paso no es necesario pero es importante saberlo.  
En el windows del cliente OPENVPN, esto realizamos para que no pieda la contrasena del certificado (es opcional)
"C:\Program Files\OpenVPN\bin\openssl.exe" rsa -in client1.key -out client1.key

## CONFIGURACION DE OPENVPN CLIENT EN MIKROTIK

Podemos de configurar un OpenVPN client en el mismo mikrotik, si utilizamos está opción se va a comportar de la siguiente manera (todos los usuarios de la red que estén debajo de dicho mikrotik van a poder llegar la la red del OpenVPN Server). Es una alternativa de IPSec y SSTP.

```
/interface ovpn-client add certificate=client.crt_0 cipher=aes256 connect-to=200.1.200.2 mac-address=02:BD:5A:A6:69:76 name=ovpn-out1 password=datapar user=ibanez
/ip firewall nat add action=masquerade chain=srcnat dst-address=192.168.20.0/24 out-interface=ovpn-out1
/ip route add distance=1 dst-address=192.168.20.0/24 gateway=ovpn-out1
```