#!/bin/bash -x

. PARAMETERS

commandseparator() {
	echo -e "\n"
	echo -e "---\n"
	echo -e "\n"
}

# prepare

sudo apt-get -y purge exim4*
commandseparator
sudo apt-get -y update
commandseparator
sudo apt-get -y install git-core
commandseparator
sudo apt-get -y install libterm-readline-gnu-perl
commandseparator

# install digitalonecan monitoring

sudo curl -sSL https://agent.digitalocean.com/install.sh | sh

# install docker

sudo apt-get -y remove docker docker-engine docker.io
commandseparator
sudo apt-get -y update
commandseparator
sudo apt-get install -y apt-transport-https ca-certificates wget software-properties-common
commandseparator
wget https://download.docker.com/linux/debian/gpg 
commandseparator
sudo apt-key add gpg
commandseparator
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee -a /etc/apt/sources.list.d/docker.list
commandseparator
sudo apt-get -y update
commandseparator
sudo apt-cache policy docker-ce
commandseparator
sudo apt-get -y install docker-ce
commandseparator
sudo systemctl enable docker
commandseparator
sudo systemctl start docker
commandseparator
sudo docker run hello-world
commandseparator

# install docker-compose

apt-get -y install curl
commandseparator
curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
commandseparator
sudo chmod +x /usr/local/bin/docker-compose
commandseparator
ln -s /usr/local/bin/docker-compose /bin/docker-compose
commandseparator

# get container image

docker pull hardware/mailserver:1.1-stable
commandseparator

# open ports

echo -e "open ports"
commandseparator

sudo systemctl stop docker
commandseparator
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent
commandseparator
sudo iptables -A INPUT -p tcp --dport 25 --jump ACCEPT
commandseparator
sudo iptables -A INPUT -p tcp --dport 143 --jump ACCEPT
commandseparator
sudo iptables -A INPUT -p tcp --dport 587 --jump ACCEPT
commandseparator
sudo iptables -A INPUT -p tcp --dport 993 --jump ACCEPT
commandseparator
sudo iptables-save 
commandseparator
sudo service netfilter-persistent start
commandseparator
sudo systemctl start docker
commandseparator

# replace placeholders on docker-compose.yml file
envsubst < "docker-compose.yml.tpl" > "docker-compose.yml"

# up stack

apt-get -y install telnet
commandseparator
docker-compose up -d
commandseparator

# certificates installation
# --verbose 

certbot_staging_arg=

if [ "$staging_certs" = "true" ];
then
   certbot_staging_arg="--staging"
fi   

docker-compose stop nginx
commandseparator
docker run -it --rm \
  -v /mnt/docker/nginx/certs:/etc/letsencrypt \
  -p 80:80 -p 443:443 \
  xataz/letsencrypt \
    certonly --standalone \
    --non-interactive \
    "$certbot_staging_arg" \
    --rsa-key-size 4096 \
    --agree-tos \
    -m "$postfix_admin_email@$postfix_admin_domain" \
    -d "$mail_server_host.$postfix_admin_domain" 
commandseparator

# replace placeholders on postfixadmin.conf and place file on it`s right location
envsubst < "postfixadmin.conf" > "/mnt/docker/nginx/sites-enabled/postfixadmin.conf"

docker-compose up -d
commandseparator

# DKIM verification

dkim_record_file="/mnt/docker/mail/dkim/$mail_server_host.$postfix_admin_domain/public.key"

echo "waiting for dkim file to be populated"
while [ ! -f "$dkim_record_file" ]
do
  sleep 3
  echo "."
done
commandseparator

echo "waiting for dkim file to be populated"
while [ ! -s "$dkim_record_file" ]
do
  echo "."
  sleep 1
done
cat "$dkim_record_file"
commandseparator

cat "$dkim_record_file" > DKIM.record 
commandseparator

rm -rf PARAMETERS

# automate postfixadmin setup
# https://mail.lindyhopcentral.com/setup.php
