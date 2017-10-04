# Quick setup a mailserver in ~10 minutes
## [hardware/mailserver](https://github.com/hardware/mailserver) (github project) + DigitalOcean + CloudFlare
### A simple and full-featured mail server using Docker

What's it?

```
A script to automate all steps neded to install 
https://github.com/hardware/mailserver 
"a simple and full-featured mail server using Docker" 
on a digitalocean droplet.
```
After preparation it will perform all automated tasks in around 10 minutes.

After doing a first install you will see how easy it is.

For this server template, Webmail and Authoritative DNS was removed.

### Status from current version

October-3-2017
- All the installation process is working and the final server was tested.

## How to use it

### Preparation

- have a key pair in your ~/.ssh/ folder. e.g. id_smtp and id_smtp.pub
- have a cloudflare zone for the domain that will be used for this email server (optional)
- generate a token from your digitalocean account to be used on api access by the install script
- get cloudflare token from your cloudflare account to be used on api access by the install script (optional)
- git clone https://github.com/rubentrancoso/mailserver-quicksetup.git
- cd mailserver-quicksetup
- change [PARAMETERS](PARAMETERS) file accordingly

```
export digitalocean_token=51ed08c5ca1ccc69572c330ec035cf7e0c69c723dd563ca077b51d2cbf6ba066
export digitalocen_droplet_tag=sandbox_machine
export cloudflare_enabled=true
export cloudflare_token=ALxfPq8QMn37aRHPcsPUgNfTxU9sRrxVs58w12
export cloudflare_email=youremail@domain.tld
export postfix_admin_domain=example.com
export postfix_admin_email=admin
export mail_server_host=mail
export docker_compose_password=123456
export staging_certs=false
export private_key=id_smtp
export additional_domains=aa.tld, www.bb.tld...
```

### Installation (10min)
first part runs from a mac and uses brew (should be changed to run from another platforms)
```
# ./install (will create a droplet if it does not exists or rebuild an existing one)
```
folow the next 2 prompts.

done.

### Unable to be automated

- ask digitalocean to open port 25

## Missing steps (and TODOs)

1. Enter de generated token to the container.

2. Is certificate renew already automated?

3. Check why port 80 is not redirecting to ssl on postfixadmin

4. generate keys automatically (optional)
