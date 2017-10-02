DO_ENDPOINT="https://api.digitalocean.com/v2"

do_getvmidfromtag(){
   tag=$1
   log "looking for vm with tag \"$tag\"..."
   result=`curl -sX GET -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" "$DO_ENDPOINT/droplets?tag_name=$tag"`
   result=`echo -e "$result" | jq '.droplets[] | .id'`
   echo $result
}

do_getkeyidbyname() {
   key_name=$1
   result=`curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" "$DO_ENDPOINT/account/keys"`
   result=`echo -e "$result" | jq '.ssh_keys[] | select(.name == "'$key_name.pub'") | .id'`
   echo $result
}

do_createdroplet(){
   tag=$1
   droplet_name=$2
   sshkey_id=$3
   result=`curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" -d '{"name":"'$droplet_name'","region":"nyc1","size":"1gb","image":"debian-9-x64","ssh_keys":['$sshkey_id'],"backups":false,"ipv6":false,"user_data":null,"private_networking":null,"volumes": null,"tags":["'$tag'"]}' "$DO_ENDPOINT/droplets"`
   result=`echo -e "$result" | jq '.droplet.id'`
   echo $result
}

do_rebuildimage(){
   log "going to rebuild $1"
   vmid="$1"
   result=`curl -sX POST -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" -d '{"type":"rebuild","image":"debian-9-x64"}' "$DO_ENDPOINT/droplets/$vmid/actions"`
}

do_getvmipaddressfromid(){
   log "get ip_address from vm $1..."
   vmid="$1"
   result=`curl -sX GET -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" "$DO_ENDPOINT/droplets/$vmid"`
   result=`echo -e "$result" | jq '.droplet.networks.v4[] | .ip_address'`
   echo `removequotesfromstr "$result"`
}

do_waitmachinetobeready(){
   log "waiting machine to finish rebuild..."
   vmid="$1"
   sleep 10
   while :
   do
      result=`curl -sX GET -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" "$DO_ENDPOINT/droplets/$vmid"`
      result=`echo -e "$result" | jq '.droplet.status'`
      if [ "$result" = "off" ];
      then
         echo "-"
      else
         break
      fi     
      sleep 5
   done
}

do_renamedroplet() {
   vm_id=$1
   new_name=$2
   echo -e "\"$new_name\""
   log "changing droplet name to \"$new_name\"" 
   curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $digitalocean_token" -d '{"type":"rename","name":"'$new_name'"}' "$DO_ENDPOINT/droplets/$vm_id/actions"
}



