# mailserver-quicksetup

A script to automate all steps neded to install https://github.com/hardware/mailserver on a digitalocean droplet

After preparation it will perform all automated tasks in arroud 10 minutes

At the momment it just not cover some few steps that I will be working with

After doing a first install you will see how easy it is.

## How to use it

### Preparation

- have a private key in your ~/.ssh/ folder. e.g. id_smtp
- create a droplet on digital ocean using the private key
- give a tag to this droplet

- git clone https://github.com/rubentrancoso/mailserver-quicksetup.git
- cd mailserver-quicksetup
- change PARAMETERS file accordingly

### Installation

- ./install
- do a ssh on the remote host
- ./remote_install.sh

### Post-intallation (to be automated)

- configure postfix admin

### Unable to be automated

- ask digitalocean to open port 25

## Missing steps

1. automatically setup cloudflare records

   - A mail ip address
   - MX domain.tld main.domain.tld
   - TXT DMARC...
   - TXT v=spf1...
   - TXT mail_domainkey v=DKIM...
   
2. silently setup postfix admin with password suplied in [PARAMETERS](PARAMETERS) (currently you will need to follow a manual step do enter de generated token to the container)
