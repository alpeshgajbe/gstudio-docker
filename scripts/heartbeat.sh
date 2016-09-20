#!/bin/bash
{

    mkdir -p /data/heartbeats/
    
    echo -e "Info-msg : hostname of server (hostname). \n"      
    hostname  

    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : School server name (from server settings). \n"      
    more /home/docker/code/gstudio/gnowsys-ndf/gnowsys_ndf/server_settings.py  

    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : internal ip addresses of the system (ip address). \n"      
    intfs=($(ifconfig -a | sed 's/[ \t].*//;/^\(\)$/d'));
    ips=($(ifconfig -a | awk '/inet addr/{print substr($2,6)}'));
    for (( a=0; a<${#ips[@]}; a++ ));
    do
	if [[ ${intfs[$a]} != "lo" ]]; then
	    echo "${intfs[$a]}- ${ips[$a]}"  ;
	fi
    done

    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : external ip addresses of the system (public ip address). \n"      
    ips_pub=$(wget http://ipecho.net/plain -O - -q ; echo)
    echo "$ips_pub"  
    
    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : RAM details (free -h). \n"      
    free -h  
    
    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : HDD details (df -h). \n"      
    df -h  
    
    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : uptime (uptime). \n"      
    uptime

    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    echo -e "Info-msg : current process (uptime). \n"      
    ps aux

    echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    # echo -e "Info-msg : docker images (docker images). \n"      
    # docker images

    # echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    # echo -e "Info-msg : docker all containers (docker ps -a). \n"      
    # docker ps -a

    # echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      

    # echo -e "Info-msg : docker running containers (docker ps). \n"      
    # docker ps
    
    # echo -e " \n\n------------------------------------------------------------------------------------ \n\n"      
}    
