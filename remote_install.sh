#!/bin/bash -x
reset
clear

. PARAMETERS
. IP_ADDRESS
. cloudflare_api

log(){
   echo -e "$1" >&2
}

commandseparator() {
	echo -e "\n"
	echo -e "---\n"
	echo -e "\n"
}

getresty(){
   log "getting resty..."
   curl -sL https://raw.githubusercontent.com/micha/resty/master/resty > resty
   . resty
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

# install curl

apt-get -y install curl
commandseparator
getresty
commandseparator

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

curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
commandseparator
sudo chmod +x /usr/local/bin/docker-compose
commandseparator
ln -s /usr/local/bin/docker-compose /bin/docker-compose
commandseparator

# install digitalonecan monitoring

sudo curl -sSL https://agent.digitalocean.com/install.sh | sh
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

echo "waiting for dkim files to be created"
while [ ! -f "$dkim_record_file" ]
do
  sleep 3
  echo -n "."
done
echo -e "\n"
commandseparator

echo "waiting for dkim files to be populated"
while [ ! -s "$dkim_record_file" ]
do
  echo -n "."
  sleep 1
done
echo -e "\n"
commandseparator

# list all DKIM files
echo "DKIM files installed"
cd /mnt/docker/mail/dkim/
for entry in *; do   echo "$entry"; done
commandseparator
cd -
commandseparator

cat "$dkim_record_file"
commandseparator

cat "$dkim_record_file" > DKIM.record 
commandseparator

curl --insecure -X POST --data "form=setuppw&setup_password=$docker_compose_password&setup_password2=$docker_compose_password&submit=Generate+password+hash" "https://$mail_server_host.$postfix_admin_domain/setup.php" > response.html
postfix_token=`cat response.html | sed -rn "s/.*\['setup_password'\] = '(.*)';<\/pre><\/div>/\1/p"`
commandseparator

echo -e "your token is: $postfix_token"
echo -e "copy it to the prompt..."

docker exec -ti postfixadmin setup

curl --insecure -X POST --data "form=createadmin&setup_password=$docker_compose_password&username=$postfix_admin_email@$postfix_admin_domain&password=$docker_compose_password&password2=$docker_compose_password&submit=Add+Admin" "https://$mail_server_host.$postfix_admin_domain/setup.php" > response.html
cat response.html | sed -rn 's/.*(The admin .*@.* has been added)\!.*/\1/p'
commandseparator

rm -rf PARAMETERS
rm -rf response.html

# populate cloudflare

update_dns_record

# make digitalocean & cloudflare optional

echo -e "open postfixadmin at https://$mail_server_host.$postfix_admin_domain to finish installation"
echo -e "login with $postfix_admin_email@$postfix_admin_domain/$docker_compose_password"




