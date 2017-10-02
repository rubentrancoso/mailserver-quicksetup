#!/bin/bash -x
reset
clear

. PARAMETERS
. libs/common.sh
. libs/digitalocean_api.sh
. libs/cloudflare_api.sh

# install jq to parse json responses
installjq
# install resty to make rest calls from bash
getresty

# given a tag get the vm_id from digital ocean
vm_id=`do_getvmidfromtag "$digitalocen_droplet_tag"`

# if vm was not found exit
if [ -z "$vm_id" ];
then
   log "no vm found. creating droplet..."
   # create a droplet with the given tag
   key_id=`do_getkeyidbyname "$private_key"`
   vm_id=`do_createdroplet "$digitalocen_droplet_tag" "$mail_server_host.$postfix_admin_domain" "$key_id"`
else
   log "found vm $vm_id."
   # give the machine the right name 
   do_renamedroplet "$vm_id" "$mail_server_host.$postfix_admin_domain"

   # 'format and reinstall' image to the vm
   do_rebuildimage "$vm_id"   
fi

# wait machine to be rebuilt and be available
# the problem here is that even if the machine is available
# that does mean that it`s already acessible
# so we check for the machine every 5 seconds
do_waitmachinetobeready "$vm_id"

# ask for the ip address so we can access the machine using ssh
ip_address=`do_getvmipaddressfromid "$vm_id"`
echo "export server_ip=$ip_address" > IP_ADDRESS

# delete the machine from knowhosts so we can add the new finger print for the newly 
# created vm
removemachinefromknownhosts "$ip_address"

# wait until port 22 answer with ssh handshake
waitforssh "$ip_address" 

# copy installation files to the remote host

# the docker-compose file
log "copying docker-compose to remote host..."
result=`scp -o "StrictHostKeyChecking no" -i "~/.ssh/$private_key" remote/docker-compose.yml root@$ip_address:~/docker-compose.yml.tpl`

# copy postfixadmin.conf file to the remote host
log "copying postfixadmin.conf file to remote host..."
result=`scp -o "StrictHostKeyChecking no" -i "~/.ssh/$private_key" remote/postfixadmin.conf root@$ip_address:~/postfixadmin.conf`

# copy the installation script
log "copying remote_install.sh to remote host..."
result=`scp -o "StrictHostKeyChecking no" -i "~/.ssh/$private_key" remote/remote_install.sh root@$ip_address:~/remote_install.sh`
# make the installation script runnable
result=`ssh -i "~/.ssh/$private_key" root@$ip_address chmod +x /root/remote_install.sh`

# copy PARAMETERS file to the remote host
log "copying PARAMETERS file to remote host..."
result=`scp -o "StrictHostKeyChecking no" -i "~/.ssh/$private_key" PARAMETERS root@$ip_address:~/PARAMETERS`

# copy IP_ADDRESS to the remote host
log "copying IP_ADDRESS to remote host..."
result=`scp -o "StrictHostKeyChecking no" -i "~/.ssh/$private_key" IP_ADDRESS root@$ip_address:~/IP_ADDRESS`

# copy libs/apis to the remote host
log "copying libs/apis to remote host..."
result=`scp -o "StrictHostKeyChecking no" -i "~/.ssh/$private_key" -r libs root@$ip_address:~/libs`

log "preparing to run remote script on first login"
ssh -i "~/.ssh/$private_key" root@$ip_address 'echo -e "~/remote_install.sh\nmv ~/remote_install.sh ~/remote_install.sh.done" >> ~/.bashrc'

rm -rf IP_ADDRESS
rm -rf resty

echo -e "\n#########################################"

if [ "$cloudflare_enabled" = "true" ];
then
   echo -e "will update the ip address on cloudflare zone using cloudflare_api (reminder)"
else
   echo -e "you server ip address is: "$ip_address"\n"
   echo -e "fix/review your dns records before continue.\n"
fi

read -n1 -r -p "Going to second stage. Press any key to continue..." key

echo -e "-----------------------"
echo -e "entering remote host..."
echo -e "where you can run ./remote_install.sh"
ssh -i "~/.ssh/$private_key" root@$ip_address

