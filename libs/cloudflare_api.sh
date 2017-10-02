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







