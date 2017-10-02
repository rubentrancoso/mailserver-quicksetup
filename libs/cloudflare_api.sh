CLOUDFLARE_ENDPOINT="https://api.cloudflare.com/client/v4"

cf_isusable() {
   log "testing if cloudflare is configured..."

    result=`curl -X GET "$CLOUDFLARE_ENDPOINT/user" \
       -H "X-Auth-Email: $cloudflare_email" \
       -H "X-Auth-Key: $cloudflare_token" \
       -H "Content-Type: application/json"`
   result=`echo -e "$result" | jq '.success'`
   echo $result	
}

cf_list_zones() {
   log "getting zones list..."

    result=`curl -X GET "$CLOUDFLARE_ENDPOINT/zones" \
       -H "X-Auth-Email: $cloudflare_email" \
       -H "X-Auth-Key: $cloudflare_token" \
       -H "Content-Type: application/json"`
   result=`echo -e "$result" | jq '.result[] | .name'`
   echo $result	
}



update_dns_record() { 
   echo -e "update dns record...(placeholder)"
}

isjqinstalled(){
   log "verifying if jq is installed..."
   if type jq >/dev/null 2>&1;
   then
      log "jq already installed."
      echo 0
   else
      log "jq installation not found."
      echo 1
   fi
}





