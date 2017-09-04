test.bi :bee:
=======
**test.bi** is a reserved domain for your projects.  
It comes with a SSL-Certificate that you can use in your environment.  

> Current certificate is valid until **Dec  3 00:03:00 2017 GMT**.  
> Certificate will be updated every 7 days.  

**Useful cases**  
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
    $SERVER[socket] == :443 {
        ssl.engine    = enable
        ssl.pemfile   = /etc/test.bi/fullchain_privkey.pem
    }
------
**HAProxy**

    frontend www-https
        bind :443 ssl crt /etc/test.bi/fullchain_privkey.pem
        default_backend www-backend


Hosts included
--------------
    test.bi
    a.test.bi
    b.test.bi
    c.test.bi
    d.test.bi
    e.test.bi
    f.test.bi
    g.test.bi
    h.test.bi
    i.test.bi
    j.test.bi
    k.test.bi
    l.test.bi
    m.test.bi
    n.test.bi
    o.test.bi
    p.test.bi
    q.test.bi
    r.test.bi
    s.test.bi
    t.test.bi
    u.test.bi
    v.test.bi
    w.test.bi
    x.test.bi
    y.test.bi
    z.test.bi
    0.test.bi
    1.test.bi
    2.test.bi
    3.test.bi
    4.test.bi
    5.test.bi
    6.test.bi
    7.test.bi
    8.test.bi
    9.test.bi
    abc.test.bi
    auth.test.bi
    bar.test.bi
    cloud.test.bi
    dns.test.bi
    foo.test.bi
    files.test.bi
    host.test.bi
    imap.test.bi
    local.test.bi
    mail.test.bi
    me.test.bi
    net.test.bi
    pop.test.bi
    pop3.test.bi
    root.test.bi
    service.test.bi
    smtp.test.bi
    storage.test.bi
    test.test.bi
    web.test.bi
    who.test.bi
    www.test.bi
    you.test.bi
    xyz.test.bi
