### System info:
```
$ uname -a
Linux kobi-rd-1 3.10.0-1062.12.1.el7.x86_64 #(Azure VM)

$ cat /etc/redhat-release
Red Hat Enterprise Linux Server release 7.7 (Maipo)
```
### Installation:
```
sudo yum install -y java-1.8.0
sudo rpm -Uvh https://repo.rundeck.org/latest.rpm
sudo yum install -y rundeck
sudo service rundeckd start
```
### Configuring keys for ssl:
```
$ keytool -importkeystore -destkeystore keystore -srckeystore rundeck.p12 -srcstoretype pkcs12
$ ls $(pwd) #(/home/rundeck)
rd_certs.tar      rundeck-ca.crt  rundeck-chain.pem  rundeck-inter.pem   rundeck-server.pem keystore       rundec-key.pem  rundeck-ca.pem  rundeck-inter.crt  rundeck-server.crt  rundeck.p12         truststore

$ cp keystore /etc/rundeck/ssl && cp keystore /etc/rundeck/ssl/truststore
$ ll /etc/rundeck/ssl
total 12
-rw-rw-r--. 1 rundeck rundeck 2732 Mar 31 07:50 keystore
-rw-r-----. 1 rundeck rundeck  161 Mar 31 07:52 ssl.properties
-rw-rw-r--. 1 rundeck rundeck 2732 Mar 31 07:51 truststore
```

### Config files: ###
```
$ vim /etc/rundeck/framework.properties
framework.server.name = server-dns.com
framework.server.hostname = server-dns.com
framework.server.port = 4443
framework.server.url = https://server-dns.com
framework.rundeck.url = https://server-dns.com
:wq

$ vim /etc/rundeck/rundeck-config.properties
grails.serverURL=https://server-dns.com:4443
:wq

$vim /etc/sysconfig/rundeckd
export RUNDECK_WITH_SSL=true
export RDECK_HTTPS_PORT=4443
:wq
$ source /etc/sysconfig/rundeckd

$ vim /etc/rundeck/ssl/ssl.properties
keystore=/etc/rundeck/ssl/keystore
keystore.password=secretpw
key.password=secretpw
truststore=/etc/rundeck/ssl/truststore
truststore.password=secretpw
```

### Run the server ###
```
$ sudo systemctl restart rundeckd && tail -f /var/log/rundeck/service.log
Session terminated, killing shell...[2020-04-01 15:59:19.400]  INFO BootStrap --- [      Thread-20] Rundeck Shutdown detected
 ...killed.

Configuring Spring Security Core ...
... finished configuring Spring Security Core

[2020-04-01 16:00:24.877]  INFO BootStrap --- [           main] Starting Rundeck 3.2.4-20200318 (2020-03-18) ...
[2020-04-01 16:00:24.883]  INFO BootStrap --- [           main] using rdeck.base config property: /var/lib/rundeck
[2020-04-01 16:00:24.899]  INFO BootStrap --- [           main] loaded configuration: /etc/rundeck/framework.properties
[2020-04-01 16:00:25.011]  INFO BootStrap --- [           main] RSS feeds disabled
[2020-04-01 16:00:25.011]  INFO BootStrap --- [           main] Using jaas authentication
[2020-04-01 16:00:25.018]  INFO BootStrap --- [           main] Preauthentication is disabled
[2020-04-01 16:00:25.209]  INFO BootStrap --- [           main] Rundeck is ACTIVE: executions can be run.
[2020-04-01 16:00:25.298]  WARN BootStrap --- [           main] [Development Mode] Usage of H2 database is recommended only for development and testing
[2020-04-01 16:00:25.787]  INFO BootStrap --- [           main] Rundeck startup finished in 1278ms
[2020-04-01 16:00:26.179]  WARN SslContextFactory --- [           main] No supported ciphers from [SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384, SSL_ECDHE_RSA_WITH_AES_256_CBC_SHA384, SSL_RSA_WITH_AES_256_CBC_SHA256, SSL_ECDH_ECDSA_WITH_AES_256_CBC_SHA384, SSL_ECDH_RSA_WITH_AES_256_CBC_SHA384, SSL_DHE_RSA_WITH_AES_256_CBC_SHA256, SSL_DHE_DSS_WITH_AES_256_CBC_SHA256, SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA, SSL_ECDHE_RSA_WITH_AES_256_CBC_SHA, SSL_RSA_WITH_AES_256_CBC_SHA, SSL_ECDH_ECDSA_WITH_AES_256_CBC_SHA, SSL_ECDH_RSA_WITH_AES_256_CBC_SHA, SSL_DHE_RSA_WITH_AES_256_CBC_SHA, SSL_DHE_DSS_WITH_AES_256_CBC_SHA, SSL_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256, SSL_ECDHE_RSA_WITH_AES_128_CBC_SHA256, SSL_RSA_WITH_AES_128_CBC_SHA256, SSL_ECDH_ECDSA_WITH_AES_128_CBC_SHA256, SSL_ECDH_RSA_WITH_AES_128_CBC_SHA256, SSL_DHE_RSA_WITH_AES_128_CBC_SHA256, SSL_DHE_DSS_WITH_AES_128_CBC_SHA256, SSL_ECDHE_ECDSA_WITH_AES_128_CBC_SHA, SSL_ECDHE_RSA_WITH_AES_128_CBC_SHA, SSL_RSA_WITH_AES_128_CBC_SHA, SSL_ECDH_ECDSA_WITH_AES_128_CBC_SHA, SSL_ECDH_RSA_WITH_AES_128_CBC_SHA, SSL_DHE_RSA_WITH_AES_128_CBC_SHA, SSL_DHE_DSS_WITH_AES_128_CBC_SHA, SSL_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, SSL_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256, SSL_ECDHE_RSA_WITH_AES_256_GCM_SHA384, SSL_RSA_WITH_AES_256_GCM_SHA384, SSL_ECDH_ECDSA_WITH_AES_256_GCM_SHA384, SSL_ECDH_RSA_WITH_AES_256_GCM_SHA384, SSL_DHE_DSS_WITH_AES_256_GCM_SHA384, SSL_DHE_RSA_WITH_AES_256_GCM_SHA384, SSL_ECDHE_RSA_WITH_AES_128_GCM_SHA256, SSL_RSA_WITH_AES_128_GCM_SHA256, SSL_ECDH_ECDSA_WITH_AES_128_GCM_SHA256, SSL_ECDH_RSA_WITH_AES_128_GCM_SHA256, SSL_DHE_RSA_WITH_AES_128_GCM_SHA256, SSL_DHE_DSS_WITH_AES_128_GCM_SHA256]
Grails application running at https://localhost:4443 in environment: production
^C

$ curl https://localhost:4443
curl: (35) Peer reports it experienced an internal error.
```



