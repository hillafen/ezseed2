#!/bin/bash
#su $user -c 'screen -dmS rtorrent rtorrent' lancer
###
#Vérification du root
if [ "$(id -u)" != "0" ]; then
        echo "This bash script needs a root account" 1>&2
        exit 1
fi
###

##Building tools##
apt-get -y install libncurses5-dev libxmlrpc-c3-dev libcurl3-dev automake libncurses5 libcppunit-dev libtool pkg-config

##Rutorrent tools##
apt-get -y php5-cli unrar unzip ffmpeg curl php5-curl mediainfo nginx php5-fpm subversion

#Téléchargement + déplacement de rutorrent (web)
#rutorrent
#wget http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz
#tar -xzf rutorrent-3.6.tar.gz 
#mv rutorrent/ /var/www
#rm rutorrent-3.6.tar.gz

#plugins
#wget http://dl.bintray.com/novik65/generic/plugins-3.6.tar.gz
#tar -xzf plugins-3.6.tar.gz
#mv ./plugins/* /var/www/rutorrent/plugins/
#rm -R ./plugins

svn checkout http://rutorrent.googlecode.com/svn/trunk/rutorrent/
svn checkout http://rutorrent.googlecode.com/svn/trunk/plugins/
mv ./plugins/* ./rutorrent/plugins/
mv rutorrent/ /var/www

#clone rtorrent et libtorrent
git clone https://github.com/rakshasa/rtorrent/
git clone https://github.com/rakshasa/libtorrent/
#compilation libtorrent
cd libtorrent
./autogen.sh
./configure
make
make install

#compilation rtorrent
cd ../rtorrent
./autogen.sh
./configure --with-xmlrpc-c
make
make install

#back to script root
cd ../

rm -R rtorrent libtorrent

#Ajout de la config nginx
cat ./nginx.conf > /etc/nginx/nginx.conf

#Création des dossiers
mkdir /usr/local/nginx
touch /usr/local/nginx/rutorrent_passwd

#Certificat ssl
openssl req -new -x509 -days 365 -nodes -out /usr/local/nginx/rutorrent.pem -keyout /usr/local/nginx/rutorrent.key -subj '/CN=rutorrent/O=EzSeed/C=FR'

#ajout de l'environnement
echo "include /usr/local/bin" >> /etc/ld.so.conf
ldconfig

#Ajout de la config dans php-fpm.conf
echo "
[www]
listen = /etc/phpcgi/php-cgi.socket
user = www-data
group = www-data
pm.max_children = 4096
pm.start_servers = 4
pm.min_spare_servers = 4
pm.max_spare_servers = 128
pm.max_requests = 4096
" >> /etc/php5/fpm/php-fpm.conf

mkdir /etc/phpcgi

service php5-fpm restart
service nginx restart