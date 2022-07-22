1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей. - готово, см. рис.1



2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP. - готово, см. рис.2



3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.
a) apt install php -y # ставлю веб-сервер
b) a2enmod ssl # включаю SSL
c) mkdir -p /var/logs
   mkdir -p /var/www/sites/devops20.breus
   mkdir -p /var/www/certs/devops20.breus # создаю каталоги под сайт, сертификат и логи
d) cat << EOF > /etc/apache2/sites-available/devops20.breus.conf
   <VirtualHost *:80>
   DocumentRoot /var/www/sites/devops20.breus
   ServerName devops20.breus
   ServerAlias www.devops20.breus
   ErrorLog /var/logs/site-error.log
   </VirtualHost>
   EOF # создал конфигурационный файл /etc/apache2/sites-available/devops20.breus.conf

   cat << EOF > /etc/apache2/sites-available/devops20.breus.ssl.conf
   <IfModule ssl_module>
   <VirtualHost *:443>
   DocumentRoot /var/www/sites/devops20.breus
   ServerName devops20.breus
   ServerAlias www.devops20.breus
   ErrorLog /var/logs/site-error.log
   SSLEngine on
   SSLOptions +StrictRequire
   SSLCertificateFile /var/www/certs/devops20.breus/cert.pem
   SSLCertificateKeyFile /var/www/certs/devops20.breus/privkey.pem
   </VirtualHost>
   </IfModule>
   EOF # создал конфигурационный файл /etc/apache2/sites-available/devops20.breus.ssl.conf

e) ln -s /etc/apache2/sites-available/devops20.breus.conf /etc/apache2/sites-enabled/devops20.breus.conf
   ln -s /etc/apache2/sites-available/devops20.breus.ssl.conf /etc/apache2/sites-enabled/devops20.breus.ssl.conf # создал симлинки на файлы
                                                                                                                 # /etc/apache2/sites-available/devops20.breus.conf и
                                                                                                                 # /etc/apache2/sites-available/devops20.breus.ssl.conf
                                                                                                                 # в каталоге /etc/apache2/sites-enabled
f) apt install -y openssl
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /var/www/certs/devops20.breus/privkey.pem -out /var/www/certs/devops20.breus/cert.pem # генерирую сертификат

g) echo “<h1>Homework site</h1>” > /var/www/sites/devops20.breus/index.php && service apache2 restart # создаю индексный файл и перезапускаю веб-сервер

После добавления записи в локальный hosts браузер открывает созданный сайт - рис.3



4. а) git clone --depth 1 https://github.com/drwetter/testssl.sh.git # скачиваю скрипт для тестирования
   b) ./testssl.sh -U --sneaky https://yandex.ru # проверяю сайт на наличие уязвимостей. Результат на рис.4


5. ssh-keygen # генерирую ключи
   ssh-copy-id USER@IP # копирую их на другой сервер
   ssh USER@IP # захожу по ключу. Результат на рис. 5


6. mv /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/renamed.key # переименовываю ключ
   sudo -s
   cat << EOF > /etc/ssh/ssh_config
   Host centos
   HostName 192.168.42.213
   IdentityFile /home/vagrant/.ssh/renamed.key
   User vagrant
   EOF # сопоставляю имя с IP-адресом, добавляя эти строки в конфиг /etc/ssh/ssh_config
   ssh centos # логинюсь, результат на рис. 6


7. tcpdump -i eth1 -c 100 -w /home/vagrant/log.pcap # собрал лог
   tshark -r /home/vagrant/log.pcap # прочитал его, см. рис.7