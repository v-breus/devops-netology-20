#### Установите Bitwarden плагин для браузера. Зарегистрируйтесь и сохраните несколько паролей.
Готово
<img src="img\рис.1.png">

#### Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden аккаунт через Google authenticator OTP

Готово 
<img src="img\рис.2.png">

#### Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS
```source-shell
apt install php -y # ставлю веб-сервер
a2enmod ssl # включаю SSL
mkdir -p /var/logs
mkdir -p /var/www/sites/devops20.breus
mkdir -p /var/www/certs/devops20.breus # создаю каталоги под сайт, сертификат и логи
cat << EOF > /etc/apache2/sites-available/devops20.breus.conf
<VirtualHost *:80>
DocumentRoot /var/www/sites/devops20.breus
ServerName devops20.breus
ServerAlias www.devops20.breus
ErrorLog /var/logs/site-error.log
</VirtualHost>
EOF
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
EOF

ln -s /etc/apache2/sites-available/devops20.breus.conf /etc/apache2/sites-enabled/devops20.breus.conf
ln -s /etc/apache2/sites-available/devops20.breus.ssl.conf /etc/apache2/sites-enabled/devops20.breus.ssl.conf # создаю конфиги

apt install -y openssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /var/www/certs/devops20.breus/privkey.pem -out /var/www/certs/devops20.breus/cert.pem # генерирую сертификат
echo “<h1>Homework site</h1>” > /var/www/sites/devops20.breus/index.php && service apache2 restart # создаю индексный файл и перезапускаю веб-сервер
```
После добавления записи в локальный hosts браузер открывает созданный сайт
<img src="img\рис.3.png">


#### Проверьте на TLS уязвимости произвольный сайт в интернете
```source-shell
git clone --depth 1 <a href="https://github.com/drwetter/testssl.sh.git">https://github.com/drwetter/testssl.sh.git</a> # скачиваю скрипт для тестирования
./testssl.sh -U --sneaky <a href="https://yandex.ru">https://yandex.ru</a> # проверяю сайт на наличие уязвимостей.
```
Результат на рис.4
<img src="img\рис.4.png">

#### Установите на Ubuntu ssh сервер, сгенерируйте новый приватный ключ. Скопируйте свой публичный ключ на другой сервер. Подключитесь к серверу по SSH-ключу
```source-shell
ssh-keygen # генерирую ключи<br>
ssh-copy-id USER@IP # копирую их на другой сервер
ssh USER@IP # захожу по ключу
```
Результат на рис. 5
<img src="img\рис.5.png">

#### Переименуйте файлы ключей из задания 5. Настройте файл конфигурации SSH клиента, так чтобы вход на удаленный сервер осуществлялся по имени сервера
```source-shell
mv /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/renamed.key # переименовываю ключ
sudo -s
cat &lt;&lt; EOF &gt; /etc/ssh/ssh_config
Host centos
HostName 192.168.42.213
IdentityFile /home/vagrant/.ssh/renamed.key
User vagrant
EOF # сопоставляю имя с IP-адресом, добавляя эти строки в конфиг /etc/ssh/ssh_config
ssh centos # логинюсь
```
Результат на рис. 6<img src="img\рис.6.png">

#### Соберите дамп трафика утилитой tcpdump в формате pcap, 100 пакетов. Откройте файл pcap в Wireshark
```source-shell
tcpdump -i eth1 -c 100 -w /home/vagrant/log.pcap # собрал лог
tshark -r /home/vagrant/log.pcap # прочитал его
 ```
Результат - рис.7<img src="img\рис.7.png">

