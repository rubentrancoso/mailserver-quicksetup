CLOUDFLARE_ENDPOINT="https://api.cloudflare.com/client/v4"

log(){ 
   echo -e "$1" >&2
} 

cf_isusable() {
   log "testing if cloudflare is configured..."

    result=`curl -X GET "$CLOUDFLARE_ENDPOINT/user" \
       -H "X-Auth-Email: $cloudflare_email" \
       -H "X-Auth-Key: $cloudflare_token" \
       -H "Content-Type: application/json"`
   result=`echo -e "$result" | jq '.success'`
   echo $result	
}

cf_get_zone_identifier() {
	zone=$1
    log "getting zone identifier for $zone..."

    result=`curl -X GET "$CLOUDFLARE_ENDPOINT/zones?name=$zone" \
       -H "X-Auth-Email: $cloudflare_email" \
       -H "X-Auth-Key: $cloudflare_token" \
       -H "Content-Type: application/json"`
   result=`echo -e "$result" | jq '.result[] | .id'`
   result=`removequotesfromstr $result`
   echo "$result"	
}

removequotesfromstr(){
   value=$1
   temp="${value%\"}"
   temp="${temp#\"}"
   echo "$temp"
}

cf_list_zones() {
   log "getting zones list..."

    result=`curl -X GET "$CLOUDFLARE_ENDPOINT/zones" \
       -H "X-Auth-Email: $cloudflare_email" \
       -H "X-Auth-Key: $cloudflare_token" \
       -H "Content-Type: application/json"`
   result=`echo -e "$result" | jq -r '.result[] | .name'`
   echo "$result"	
}

cf_get_record_identifier() { 
   zone_id=$1
   rtype=$2
   name=$3

   log "getting dns record identifier for $zone type[$rtype] name[$name]..."

   result=`curl -X GET "$CLOUDFLARE_ENDPOINT/zones/$zone_id/dns_records" \
      -H "X-Auth-Email: $cloudflare_email" \
      -H "X-Auth-Key: $cloudflare_token" \
      -H "Content-Type: application/json"`

   result=`echo "$result" | jq -r ".result[] | select(.type == \"$rtype\" ) | select(.name == \"$name\") | .id"`
   echo "$result"
}

cf_count_record() { 
   zone_id=$1
   rtype=$2
   name=$3

   log "counting dns record $zone type[$rtype] name[$name]..."

   result=`curl -X GET "$CLOUDFLARE_ENDPOINT/zones/$zone_id/dns_records" \
      -H "X-Auth-Email: $cloudflare_email" \
      -H "X-Auth-Key: $cloudflare_token" \
      -H "Content-Type: application/json"`

   result=`echo "$result" | jq -r ".result[] | select(.type == \"$rtype\" ) | select(.name == \"$name\") | .id" | wc -l`
   echo "$result"
}

cf_remove_record() { 
   zone_id=$1
   record_id=$2

   log "removing dns record $record_id from $zone_id..."

   result=`curl -X DELETE "$CLOUDFLARE_ENDPOINT/zones/$zone_id/dns_records/$record_id" \
      -H "X-Auth-Email: $cloudflare_email" \
      -H "X-Auth-Key: $cloudflare_token" \
      -H "Content-Type: application/json"`
}


cf_update_record_by_id() { 
   zone_id=$1
   record_id=$2
   rtype=$3
   name=$4
   value=$5

   log "updating dns record $record_id from $zone_id..."

   result=`curl -X PUT "$CLOUDFLARE_ENDPOINT/zones/$zone_id/dns_records/$record_id" \
      -H "X-Auth-Email: $cloudflare_email" \
      -H "X-Auth-Key: $cloudflare_token" \
      -H "Content-Type: application/json" \
      -d "{\"type\":\"$rtype\",\"name\":\"$name\",\"content\":\"$value\"}"`
}

cf_create_record() { 
   zone_id=$1
   rtype=$2
   name=$3
   value=$4

   log "creating dns record $zone type[$rtype] name[$name] value[$value]..."

   result=`curl -X POST "$CLOUDFLARE_ENDPOINT/zones/$zone_id/dns_records" \
      -H "X-Auth-Email: $cloudflare_email" \
      -H "X-Auth-Key: $cloudflare_token" \
      -H "Content-Type: application/json" \
      -d "{\"type\":\"$rtype\",\"name\":\"$name\",\"content\":\"$value\"}"`
}

cf_remove_duplicate_record() { 
   zone_id=$1
   rtype=$2
   name=$3

   log "removing duplicate dns record $zone type[$rtype] name[$name]..."

   identifier_list=`cf_get_record_identifier "$zone_id" "$rtype" "$name"`   
   reminder=`echo -n "$identifier_list" | tr '\n' ' ' | cut -d' ' -f1`
   to_remove_list=`echo -n "$identifier_list" | tr '\n' ' ' | cut -d' ' -f2-`
   
   if [ "$to_remove_list" = "$reminder" ];
   then
      to_remove_list=""	
   fi
   
   for identifier in $to_remove_list
   do
      cf_remove_record "$zone_id" "$identifier"
   done	   
   echo "$reminder"
}

cf_update_record() {
   zone=$1
   rtype=$2
   name=$3
   value=$4
   zone_id=`cf_get_zone_identifier "$zone"`
   
   reminder=`cf_remove_duplicate_record "$zone_id" "$rtype" "$name"`
   if [ "$reminder" = "" ];
   then
      cf_create_record "$zone_id" "$rtype" "$name" "$value"
   else
      cf_update_record_by_id "$zone_id" "$reminder" "$rtype" "$name" "$value"
   fi
}


