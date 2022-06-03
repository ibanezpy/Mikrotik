## Configuración de SSTP
### Configuración de certificados MK
```
/certificate add name=CA country="PY" state="ITAPUA" locality="ENCARNACION" organization="GARIBALDI" unit="TI" common-name="CA" key-size=2048 days-valid=365000 key-usage=crl-sign,key-cert-sign
/certificate sign CA ca-crl-host=<IP PUBLICO> name="CA"

/certificate add name=server country="PY" state="ITAPUA" locality="ENCARNACION" organization="GARIBALDI" unit="TI" common-name="server" key-size=2048 days-valid=365000 key-usage=digital-signature,key-encipherment,tls-server
/certificate sign server ca="CA" name="server"

/certificate add name=client country="PY" state="ITAPUA" locality="ENCARNACION" organization="GARIBALDI" unit="TI" common-name="client" key-size=2048 days-valid=365000 key-usage=tls-client
/certificate sign client ca="CA" name="client"
```

### Configuracioin de DHCP para VPN
```
/ip pool add name=Pool-VPN ranges=10.76.76.10-10.76.76.20
/ppp profile add dns-server=10.76.76.1 local-address=10.76.76.1 name=SSTP01 remote-address=Pool-VPN use-encryption=required
```

### Configurar perfil de VPN y creación de usuario
```
/interface sstp-server server set authentication=mschap2 certificate=server default-profile=SSTP01 enabled=yes force-aes=yes pfs=yes tls-version=only-1.2
/ppp secret add name=<USUARIO> password=<CONTRASEÑA> profile=SSTP01 service=sstp
```