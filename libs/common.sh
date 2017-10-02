
commandseparator() {
	echo -e "\n"
	echo -e "---\n"
	echo -e "\n"
}

log(){
   echo -e "$1" >&2
}

# return true or false accorfing that jq is installed or not
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

installcommand() {
   OS=`uname` 
   if [ "$OS" = "Linux" ]
   then
      sudo yum -y install $1
   fi
   if [ "$OS" = "Darwin" ]
   then
      brew install $1	
   fi
}

installjq(){
   # 0 - sucess / 1 - error (not found)
   if [ $(isjqinstalled) = 1 ]
   then
      log "installing jq..."
      installcommand jq
   fi
}

getresty(){
   log "getting resty..."
   curl -sL https://raw.githubusercontent.com/micha/resty/master/resty > resty
   . resty
}

removequotesfromstr(){
   value=$1
   temp="${value%\"}"
   temp="${temp#\"}"
   echo "$temp"
}

waitforssh(){
   log "waiting for ssh..."
   ip=$1


   while :
   do
      if [[ $(nc -w 5 "$ip" 22 <<< "\0" ) =~ "OpenSSH" ]] ; then
         result="open ssh is running"
      fi
      if [ "$result" = "open ssh is running" ];
      then
         return
      fi     
      sleep 5
   done
}

removemachinefromknownhosts(){
   log "remove machine from known hosts..."
   ip_address=`removequotesfromstr "$ip_address"`
   log `pwd`
   ssh-keygen -R "$ip_address"
   # sed -i '' '^$ip_address/d' ~/.ssh/known_hosts
   echo "~/.ssh/known_hosts"
   cat ~/.ssh/known_hosts
   echo "----------------"
}

fixssh(){
   eval "$(ssh-agent)"
   ssh-add -K "~/.ssh/$private_key"
}






