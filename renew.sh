#!/usr/bin/env bash
# preparation:
# git clone https://github.com/letsencrypt/letsencrypt.git /root/letsencrypt
# git clone https://github.com/Eun/test.bi.git --branch daemon /etc/test.bi
# useradd le -d /etc/test.bi -s /bin/bash
# touch /etc/apache2/sites-enabled/test.bi.conf
# chmod 0664 /etc/apache2/sites-enabled/test.bi.conf
# chown -hR root:le /etc/apache2/sites-enabled/test.bi.conf
# chown -hR le:le /etc/test.bi/
# mkdir -p /etc/letsencrypt/live/
# mkdir -p /etc/letsencrypt/archive/
# chown -hR root:le /etc/letsencrypt/live/
# chown -hR root:le /etc/letsencrypt/archive/
# chmod -R 2750 /etc/letsencrypt/live/
# chmod -R 2750 /etc/letsencrypt/archive/
# ## Add to sudoers:
# ## le ALL=(root) NOPASSWD: /root/letsencrypt/letsencrypt-auto, /etc/init.d/apache2 restart
# ##

LE_DOMAINS='-d test.bi'
AP_DOMAINS='ServerName test.bi'
FU_DOMAINS='    test.bi'
while read -r line || [[ -n "$line" ]]; do
        LE_DOMAINS="$LE_DOMAINS -d $line.test.bi"
        AP_DOMAINS="$AP_DOMAINS"$'\n'"ServerAlias $line.test.bi"
        FU_DOMAINS="$FU_DOMAINS"$'\n'"    $line.test.bi"
done < "hosts.txt"


echo "Clearing config"
echo > /etc/apache2/sites-enabled/test.bi.conf

if [ -f "/etc/letsencrypt/live/test.bi/privkey.pem" ]; then
echo "Creating https-site"
cat <<EOF >> /etc/apache2/sites-enabled/test.bi.conf
<VirtualHost *:443>
    DocumentRoot /var/www/html/test.bi
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/test.bi/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/test.bi/privkey.pem
$AP_DOMAINS
</VirtualHost>
EOF
fi

echo "Creating http-site"
cat <<EOF >> /etc/apache2/sites-enabled/test.bi.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/test.bi
$AP_DOMAINS
</VirtualHost>
EOF

sudo /etc/init.d/apache2 restart
sudo /root/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/html/test.bi/ --email root@test.bi --agree-tos --rsa-key-size 4096 --force-renewal $LE_DOMAINS

if [ $? -ne 0 ]; then
        echo "Error"
        exit
fi


if [ -f "/etc/letsencrypt/live/test.bi/privkey.pem" ]; then
echo "Creating https-site"
cat <<EOF >> /etc/apache2/sites-enabled/test.bi.conf
<VirtualHost *:443>
    DocumentRoot /var/www/html/test.bi
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/test.bi/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/test.bi/privkey.pem
$AP_DOMAINS
</VirtualHost>
EOF
fi

echo "Creating http-site"
cat <<EOF >> /etc/apache2/sites-enabled/test.bi.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/test.bi
$AP_DOMAINS
</VirtualHost>
EOF


sudo /etc/init.d/apache2 restart

if [ ! -d "certs" ]; then
        git clone https://github.com/Eun/test.bi.git certs
fi
cp /etc/letsencrypt/live/test.bi/* certs/
cat certs/fullchain.pem certs/privkey.pem > certs/fullchain_privkey.pem
cd certs
git config user.name test.bi
git config user.email daemon@test.bi
openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out fullchain.pfx  -passout pass:
ENDDATE=$(openssl x509 -enddate -noout -in cert.pem)
ENDDATE="${ENDDATE/notAfter=/}"

cat <<EOF > README.MD
test.bi :bee:
=======
**test.bi** is a reserved domain for your projects.  
It comes with a SSL-Certificate that you can use in your environment.  

> Current certificate is valid until **$ENDDATE**.  
> Certificate will be updated every 7 days.  

**Usefull cases**  
1. You need a development hostname.  
2. You are developing an application that needs HTTPS, or other SSL connection to your server.  
3. You are developing a [ServiceWorker](https://www.w3.org/TR/service-workers/).  
4. many more  

Security note
----------------
> Since the **private key is public**, and anyone could possibly read your communication, make sure you **do not use the certificate in production or with sensitive data**.

Usage
-----
    $ git clone https://github.com/Eun/test.bi.git /etc/test.bi

**Apache**

    # Enable ssl
    $ a2enmod ssl

    # Add to your sites-enabled/000-default.conf
    <VirtualHost *:443>
        DocumentRoot /var/www/html
        SSLEngine on
        SSLCertificateFile /etc/test.bi/fullchain.pem
        SSLCertificateKeyFile /etc/test.bi/privkey.pem
    </VirtualHost>
------
**Nginx**

    # Add to your sites-enabled/default
    server
    {
        listen 443 ssl;
        ssl_certificate /etc/test.bi/fullchain.pem;
        ssl_certificate_key /etc/test.bi/privkey.pem;
        root /var/www/html;
    }
------
**Lighttpd**

    # Enable ssl
    $ lighttpd-enable-mod ssl

    # Add to your conf-enabled/10-ssl.conf
    \$SERVER["socket"] == ":443" {
        ssl.engine    = "enable"
        ssl.pemfile   = "/etc/test.bi/fullchain_privkey.pem"
    }
------
**HAProxy**

    frontend www-https
        bind :443 ssl crt /etc/test.bi/fullchain_privkey.pem
        default_backend www-backend


Hosts included
--------------
$FU_DOMAINS
EOF

git add .
git commit --allow-empty-message --message ""
git push -u origin master
