# Quick setup a mailserver in ~10 minutes
## [hardware/mailserver](https://github.com/hardware/mailserver) (github project) + DigitalOcean + CloudFlare
### a simple and full-featured mail server using Docker

What`s it?

```
A script to automate all steps neded to install 
https://github.com/hardware/mailserver 
"a simple and full-featured mail server using Docker" 
on a digitalocean droplet.
```
After preparation it will perform all automated tasks in around 10 minutes.

After doing a first install you will see how easy it is.

For this server template, Webmail and Authoritative DNS was removed.

At the momment it just do not cover some few steps that I will be working on to be solved.

## How to use it

### Preparation

- have a key pair in your ~/.ssh/ folder. e.g. id_smtp and id_smtp.pub
- generate a token from your digitalocean account to be used on api access by the install script
- git clone https://github.com/rubentrancoso/mailserver-quicksetup.git
- cd mailserver-quicksetup
- change [PARAMETERS](PARAMETERS) file accordingly

```
export digitalocean_token=51ed08c5ca1ccc69572c330ec035cf7e0c69c723dd563ca077b51d2cbf6ba066
export digitalocen_droplet_tag=sandbox_machine
export postfix_admin_domain=example.com
export postfix_admin_email=admin
export mail_server_host=mail
export docker_compose_password=123456
export staging_certs=false
export private_key=id_smtp.pub
export additional_domains=aa.tld, www.bb.tld...
```

### Installation (10min)
```
# ./install (will create a droplet if it do not exists or rebuild an existing one)
```

do a ssh on the remote host

```
# ./remote_install.sh
```
### Post-intallation (to be automated)

- configure postfix admin

### Unable to be automated

- ask digitalocean to open port 25

## Missing steps

1. Automatically setup cloudflare records (or at least give the records as text).

   - A mail ip address
   - MX domain.tld main.domain.tld
   - TXT DMARC...
   - TXT v=spf1...
   - TXT mail_domainkey v=DKIM...
   
2. Silently setup postfix admin with password suplied in [PARAMETERS](PARAMETERS) (currently you will need to follow a manual step to enter de generated token to the container).

3. Fix a version.

4. Is certificate renew already automated?

