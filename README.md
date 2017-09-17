# mailserver-quicksetup

a script to automate all steps neded to intall https://github.com/hardware/mailserver on a digitalocean droplet

## Missing steps

1. xataz/docker-letsencrypt image needs to be changed so the certificate creation will not prompt for user
2. automatically setup cloudflare records

   - A mail ip address
   - MX domain.tld main.domain.tld
   - TXT DMARC...
   - TXT v=spf1...
   - TXT mail_domainkey v=DKIM...
   
