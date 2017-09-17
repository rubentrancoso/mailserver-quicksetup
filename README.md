# mailserver-quicksetup

A script to automate all steps neded to intall https://github.com/hardware/mailserver on a digitalocean droplet
At the momment it just not cover some few steps that I will be working with
After doing a first install you will see how easy it is.

## How to use it

- have a private key in your ~/.ssh/ folder. e.g. id_smtp
- create a droplet on digital ocean using the private key
- give a tag to this droplet

- git clone https://github.com/rubentrancoso/mailserver-quicksetup.git
- cd mailserver-quicksetup
- change PARAMETERS file accordingly
- ./install

- do a ssh on the remote host
- ./remote_install.sh
- configure postfix admin
- ask digitalocean to open port 25

## Missing steps

1. xataz/docker-letsencrypt image needs to be changed so the certificate creation will not prompt for user
2. automatically setup cloudflare records

   - A mail ip address
   - MX domain.tld main.domain.tld
   - TXT DMARC...
   - TXT v=spf1...
   - TXT mail_domainkey v=DKIM...
   
3. silently setup postfix admin with password suplied in PARAMETERS (currently you will need to follow a manual step do enter de generated token to the container)
