sudo mkdir /var/lib/rundeck/.postgresql
sudo mv -t /var/lib/rundeck/.postgresql ~/rundeck.crt ~/rundeck.key
sudo mv /var/lib/rundeck/.postgresql/rundeck.key /var/lib/rundeck/.postgresql/postgresql.key
sudo mv /var/lib/rundeck/.postgresql/rundeck.crt /var/lib/rundeck/.postgresql/postgresql.crt
sudo chown -R rundeck:rundeck /var/lib/rundeck/.postgresql/
sudo chmod 0600 /var/lib/rundeck/.postgresql/*
export PGSSLKEY=/var/lib/rundeck/.postgresql/postgresql.key
export PGSSLCERT=/var/lib/rundeck/.postgresql/postgresql.crt
sudo -u rundeck openssl pkcs8 -topk8 -inform PEM -outform DER -in /var/lib/rundeck/.postgresql/postgresql.key -out /var/lib/rundeck/.postgresql/postgresql.pk8 -nocrypt
sudo -u rundeck openssl x509 -in /var/lib/rundeck/.postgresql/postgresql.crt -out /var/lib/rundeck/.postgresql/postgresql.der -outform der
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/jre/
sudo keytool -keystore $JAVA_HOME/lib/security/cacerts -alias postgresql -import -file server.crt.der