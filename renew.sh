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
RSA_SIZES=(2048)
LE_DOMAINS='-d test.bi'
AP_DOMAINS='ServerName test.bi'
FU_DOMAINS='    test.bi'
while read -r line || [[ -n "$line" ]]; do
        LE_DOMAINS="$LE_DOMAINS -d $line.test.bi"
        AP_DOMAINS="$AP_DOMAINS"$'\n'"ServerAlias $line.test.bi"
        FU_DOMAINS="$FU_DOMAINS"$'\n'"    $line.test.bi"
done < "hosts.txt"

if [ ! -d "certs" ]; then
        git clone https://github.com/Eun/test.bi.git certs
fi

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



for RSA_SIZE in ${RSA_SIZES[*]}
do
	echo "Creating $RSA_SIZE cert"
	sudo /root/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/html/test.bi/ --email root@test.bi --agree-tos --rsa-key-size $RSA_SIZE --force-renewal $LE_DOMAINS

	if [ $? -ne 0 ]; then
        	echo "Error"
	        exit
	fi

	if [ ! -d "certs/$RSA_SIZE" ]; then
		mkdir certs/$RSA_SIZE
	fi

	cp /etc/letsencrypt/live/test.bi/* certs/$RSA_SIZE/
	cat /etc/letsencrypt/live/test.bi/fullchain.pem /etc/letsencrypt/live/test.bi/privkey.pem > certs/$RSA_SIZE/fullchain_privkey.pem
	openssl pkcs12 -export -in /etc/letsencrypt/live/test.bi/fullchain.pem -inkey /etc/letsencrypt/live/test.bi/privkey.pem -out certs/$RSA_SIZE/fullchain.pfx  -passout pass:
	ENDDATE=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/test.bi/cert.pem)
	ENDDATE="${ENDDATE/notAfter=/}"
	eval "echo \"$(cat README$RSA_SIZE.md.tpl)\"" > certs/$RSA_SIZE/README.md
done

# create 4096 cert
echo "Creating 4096 cert"
sudo /root/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/html/test.bi/ --email root@test.bi --agree-tos --rsa-key-size 4096 --force-renewal $LE_DOMAINS
if [ $? -ne 0 ]; then
       	echo "Error"
        exit
fi
cp /etc/letsencrypt/live/test.bi/* certs/
cat /etc/letsencrypt/live/test.bi/fullchain.pem /etc/letsencrypt/live/test.bi/privkey.pem > certs/fullchain_privkey.pem
openssl pkcs12 -export -in /etc/letsencrypt/live/test.bi/fullchain.pem -inkey /etc/letsencrypt/live/test.bi/privkey.pem -out certs/fullchain.pfx  -passout pass:
ENDDATE=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/test.bi/cert.pem)
ENDDATE="${ENDDATE/notAfter=/}"
eval "echo \"$(cat README4096.md.tpl)\"" > certs/README.md

##
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
done

echo "Creating http-site"
cat <<EOF >> /etc/apache2/sites-enabled/test.bi.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/test.bi
$AP_DOMAINS
</VirtualHost>
EOF


sudo /etc/init.d/apache2 restart

cd certs
git config user.name test.bi
git config user.email daemon@test.bi
git add .
git commit --allow-empty-message --message ""
git push -u origin master
