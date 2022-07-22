<ol>
<li class="has-line-data" data-line-start="0" data-line-end="1">Установите Bitwarden плагин для браузера. Зарегистрируйтесь и сохраните несколько паролей. - готово ![Screenshot](https://github.com/v-breus/devops-netology-20/blob/main/%D0%AD%D0%BB%D0%B5%D0%BC%D0%B5%D0%BD%D1%82%D1%8B%20%D0%B1%D0%B5%D0%B7%D0%BE%D0%BF%D0%B0%D1%81%D0%BD%D0%BE%D1%81%D1%82%D0%B8%20%D0%B8%D0%BD%D1%84%D0%BE%D1%80%D0%BC%D0%B0%D1%86%D0%B8%D0%BE%D0%BD%D0%BD%D1%8B%D1%85%20%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC/%D1%80%D0%B8%D1%81.1.png)</li>
</ol>
<ol start="2">
<li class="has-line-data" data-line-start="4" data-line-end="5">Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP. - готово, см. рис.2</li>
</ol>
<ol start="3">
<li class="has-line-data" data-line-start="8" data-line-end="38">
<p class="has-line-data" data-line-start="8" data-line-end="22">Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.<br>
a) apt install php -y # ставлю веб-сервер<br>
b) a2enmod ssl # включаю SSL<br>
c) mkdir -p /var/logs<br>
mkdir -p /var/www/sites/devops20.breus<br>
mkdir -p /var/www/certs/devops20.breus # создаю каталоги под сайт, сертификат и логи<br>
d) cat &lt;&lt; EOF &gt; /etc/apache2/sites-available/devops20.breus.conf<br>
&lt;VirtualHost *:80&gt;<br>
DocumentRoot /var/www/sites/devops20.breus<br>
ServerName devops20.breus<br>
ServerAlias www.devops20.breus<br>
ErrorLog /var/logs/site-error.log<br>
&lt;/VirtualHost&gt;<br>
EOF # создал конфигурационный файл /etc/apache2/sites-available/devops20.breus.conf</p>
<p class="has-line-data" data-line-start="23" data-line-end="37">cat &lt;&lt; EOF &gt; /etc/apache2/sites-available/devops20.breus.ssl.conf<br>
&lt;IfModule ssl_module&gt;<br>
&lt;VirtualHost *:443&gt;<br>
DocumentRoot /var/www/sites/devops20.breus<br>
ServerName devops20.breus<br>
ServerAlias www.devops20.breus<br>
ErrorLog /var/logs/site-error.log<br>
SSLEngine on<br>
SSLOptions +StrictRequire<br>
SSLCertificateFile /var/www/certs/devops20.breus/cert.pem<br>
SSLCertificateKeyFile /var/www/certs/devops20.breus/privkey.pem<br>
&lt;/VirtualHost&gt;<br>
&lt;/IfModule&gt;<br>
EOF # создал конфигурационный файл /etc/apache2/sites-available/devops20.breus.ssl.conf</p>
</li>
</ol>
<p class="has-line-data" data-line-start="38" data-line-end="42">e) ln -s /etc/apache2/sites-available/devops20.breus.conf /etc/apache2/sites-enabled/devops20.breus.conf<br>
ln -s /etc/apache2/sites-available/devops20.breus.ssl.conf /etc/apache2/sites-enabled/devops20.breus.ssl.conf # создал симлинки на файлы /etc/apache2/sites-available/devops20.breus.conf и /etc/apache2/sites-available/devops20.breus.ssl.conf в каталоге /etc/apache2/sites-enabled<br>
f) apt install -y openssl<br>
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /var/www/certs/devops20.breus/privkey.pem -out /var/www/certs/devops20.breus/cert.pem # генерирую сертификат</p>
<p class="has-line-data" data-line-start="43" data-line-end="44">g) echo “&lt;h1&gt;Homework site&lt;/h1&gt;” &gt; /var/www/sites/devops20.breus/index.php &amp;&amp; service apache2 restart # создаю индексный файл и перезапускаю веб-сервер</p>
<p class="has-line-data" data-line-start="45" data-line-end="46">После добавления записи в локальный hosts браузер открывает созданный сайт - рис.3</p>
<ol start="4">
<li class="has-line-data" data-line-start="49" data-line-end="51">а) git clone --depth 1 <a href="https://github.com/drwetter/testssl.sh.git">https://github.com/drwetter/testssl.sh.git</a> # скачиваю скрипт для тестирования<br>
b) ./testssl.sh -U --sneaky <a href="https://yandex.ru">https://yandex.ru</a> # проверяю сайт на наличие уязвимостей. Результат на рис.4</li>
</ol>
<ol start="5">
<li class="has-line-data" data-line-start="53" data-line-end="56">ssh-keygen # генерирую ключи<br>
ssh-copy-id USER@IP # копирую их на другой сервер<br>
ssh USER@IP # захожу по ключу. Результат на рис. 5</li>
</ol>
<ol start="6">
<li class="has-line-data" data-line-start="58" data-line-end="67">mv /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/renamed.key # переименовываю ключ<br>
sudo -s<br>
cat &lt;&lt; EOF &gt; /etc/ssh/ssh_config<br>
Host centos<br>
HostName 192.168.42.213<br>
IdentityFile /home/vagrant/.ssh/renamed.key<br>
User vagrant<br>
EOF # сопоставляю имя с IP-адресом, добавляя эти строки в конфиг /etc/ssh/ssh_config<br>
ssh centos # логинюсь, результат на рис. 6</li>
</ol>
<ol start="7">
<li class="has-line-data" data-line-start="69" data-line-end="71">tcpdump -i eth1 -c 100 -w /home/vagrant/log.pcap # собрал лог<br>
tshark -r /home/vagrant/log.pcap # прочитал его, см. рис.7</li>
</ol>