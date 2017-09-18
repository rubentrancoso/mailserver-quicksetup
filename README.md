# Quick setup a mailserver in ~10 minutes
## [hardware/mailserver](https://github.com/hardware/mailserver) + DigitalOcean + CloudFlare

A script to automate all steps neded to install https://github.com/hardware/mailserver (a simple and full-featured mail server using Docker) on a digitalocean droplet.

After preparation it will perform all automated tasks in around 10 minutes.

After doing a first install you will see how easy it is.

At the momment it just do not cover some few steps that I will be working on to be solved.

## How to use it

### Preparation

- have a private key in your ~/.ssh/ folder. e.g. id_smtp
- create a droplet on digital ocean using the private key
- give a tag to this droplet

- git clone https://github.com/rubentrancoso/mailserver-quicksetup.git
- cd mailserver-quicksetup
- change PARAMETERS file accordingly

### Installation (10min)

- ./install
- do a ssh on the remote host
- ./remote_install.sh

### Post-intallation (to be automated)

- configure postfix admin

### Unable to be automated

- ask digitalocean to open port 25

## Missing steps

1. Automatically setup cloudflare records.

   - A mail ip address
   - MX domain.tld main.domain.tld
   - TXT DMARC...
   - TXT v=spf1...
   - TXT mail_domainkey v=DKIM...
   
2. Silently setup postfix admin with password suplied in [PARAMETERS](PARAMETERS) (currently you will need to follow a manual step to enter de generated token to the container).

3. Accept aditional domains list in PARAMETERS file and open ADD_DOMAINS docker-compose.yml option:
```
- ADD_DOMAINS=aa.tld, www.bb.tld...   # Add additional domains separated by commas (needed for dkim keys etc.)
```

4. Create a basic droplet with the suplied tag when the droplet tag was not found.

5. Fix a version.

