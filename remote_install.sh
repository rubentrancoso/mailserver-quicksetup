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

# install docler

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

docker-compose stop nginx
commandseparator
docker run -it --rm \
  -v /mnt/docker/nginx/certs:/etc/letsencrypt \
  -p 80:80 -p 443:443 \
  xataz/letsencrypt \
    certonly --standalone \
    --rsa-key-size 4096 \
    --agree-tos \
    -m "$postix_admin_email@$postix_admin_domain" \
    -d "$mail_server_host.$postix_admin_domain" 
commandseparator

docker-compose up -d
commandseparator

# copiar o DKIM para o DNS

cat "/mnt/docker/main/dkim/$mail_server_host.$postix_admin_domain/plublic.key" > DKIM.record 
commandseparator

rm -rf PARAMETERS
