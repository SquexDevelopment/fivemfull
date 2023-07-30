#!/bin/bash

apt update && apt upgrade -y


apt install ca-certificates apt-transport-https lsb-release gnupg curl nano pwgen unzip -y

wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list


apt update
apt install apache2 -y
apt install php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-intl php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-readline php7.4-xml php7.4-xsl php7.4-zip php7.4-bz2 libapache2-mod-php7.4 -y
apt install mariadb-server mariadb-client -y
cd /usr/share
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O phpmyadmin.zip
unzip phpmyadmin.zip
rm phpmyadmin.zip
mv phpMyAdmin-*-all-languages phpmyadmin
chmod -R 0755 phpmyadmin
cd /root/
clear



echo -e '
Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
</Directory>

<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>
' >> /etc/apache2/conf-available/phpmyadmin.conf

a2enconf phpmyadmin
systemctl reload apache2
clear
mkdir /usr/share/phpmyadmin/tmp/
chown -R www-data:www-data /usr/share/phpmyadmin/tmp/

#MySQL Konfigurieren und User Erstellen
PASS=`pwgen -s 40 1`
mysql <<MYSQL_SCRIPT
CREATE USER 'admin'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT


ip=$(hostname -i)


touch /root/phpmyadmin-data.txt
echo -e "######### PHPMYADMIN Zugang #########" >> /root/phpmyadmin-data.txt
echo -e "Link: http://"$ip"/phpmyadmin" >> /root/phpmyadmin-data.txt
echo -e "User: admin" >> /root/phpmyadmin-data.txt
echo -e "Passwort: $PASS" >> /root/phpmyadmin-data.txt
echo -e "Guter Hoster: Hostet bei Hostzentrum https://discord.gg/pZjqQZqX98 https://host-zentrum.de/" >> /root/phpmyadmin-data.txt


echo 'Sie finden ihre PHPMYADMIN zugangsdaten in ihren FTP/SFTP zugang in /root'


apt update && apt upgrade -y

apt install xf tar -y

mkdir -p /home/FiveM/server
cd /home/FiveM/server

echo 'Geben Sie den Link zu den FiveM-Artifakten ein:'
read link
wget $link

echo 'Entpacken der FiveM-Dateien...'
tar xf fx.tar.xz
echo 'Artifacts installiert'

rm -r fx.tar.xz

echo 'Installieren von Screen...'
apt install screen -y


echo ' crontab wird installiert und eingerichtet'

(crontab -l 2>/dev/null; echo "@reboot /bin/bash /home/FiveM/server/run.sh > /home/FiveM/server/cron.log 2>&1") | crontab -

cd /home/FiveM/server && screen ./run.sh

echo 'Erfolgreich installiert! Jetzt m�ssen Sie in den Ordner cd /home/FiveM/server wechseln und die Datei run.sh ausf�hren --> ./run.sh'

echo 'Au�erdem wurde ein Crontab erfolgreich installiert. Bei einen Server neustart wird FIveM/Tx Admin automatisch Gestartet.'