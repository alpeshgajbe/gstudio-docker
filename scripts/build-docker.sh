#!/bin/bash
{

#--------------------------------------------------------------------------------------------------------------#
# File name   : build-docker.sh
# File creation : gnowgi
# Description :
#               git clone
#               Build Docker-Image via docker build command (using Dockerfile)
#
# Last Modification : Mrunal M. Nachankar : Mon, 07-09-2015 12:15:AM
# Description :      
#               Logs directory check and creation
#               Prerequisites - Checking for OS version and architecture
#                               Checking type of user and permission
#                               Internet checking
#                               Checking wget package
#               Docker application / package checking and installation
#               Creating local copy of replica code via git clone or update via git pull 
#               Build Docker-Image via docker build command (using Dockerfile)
#               Verify image creation
#               Start the Docker-container via docker run command (using newly created docker image)
#               Copy host logs(pre-install logs) inside docker container 
#               Verify initialization of docker-container and display message of completion
#--------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------
# Mrunal M. Nachankar : Mon, 07-09-2015 12:15:AM : Old code
#git clone https://github.com/gnowledge/gstudio.git
#docker build -t gnowgi/gstudio .
#-----------------------------------------------------------------------


# shell 
sh_c="sh -c"


# Following variables are used to store the color codes for displaying the content on terminal
red="\033[0;91m" ;
green="\033[0;32m" ;
brown="\033[0;33m" ;
blue="\033[0;34m" ;
cyan="\033[0;36m" ;
reset="\033[0m" ;


#--------------------------------------------------------------------#
# Log file details...
#--------------------------------------------------------------------#
LOG_DIR="$(pwd)/Pre-install_Logs";
INSTALL_LOG="pre-install-$(date +%d-%b-%Y-%I-%M-%S-%p).log"; # Mrunal : Fri Aug 28 17:38:35 IST 2015 : used for redirecting Standard_output(Normal msg)
INSTALL_LOG_FILE="$LOG_DIR/$INSTALL_LOG"; # Mrunal : Fri Aug 28 17:38:35 IST 2015 : used for redirecting Standard_output(Normal msg)
# ---------------- Log files variable def ends here -----------------


#--------------------------------------------------------------------#
# Check the existence of the directory...
#   If directory is present : Display messages
#   If directory is not present : create and display messages
#--------------------------------------------------------------------#
function check_dir() {
    if [[ -d $1 ]]; then
        echo -e "Info-msg : $1 directory is already present.\n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    else
        echo -e "Caution-msg : $1 directory not present. Hence creating the same.\n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
        `mkdir -p $1`     # Mrunal : No redirections here please
        echo -e "$1 directory is now been created.\n\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
    fi
}
# ----------------- Check directory code ends here ------------------


#------------------------------------------------------------------------#
# Checking the existence of the command (passed as an argument) is here..
#------------------------------------------------------------------------#
command_existence_check() {
    command -v "$@" > /dev/null 2>&1
}
#----------- Check for existence of directory code ends here ------------

#--------------------------------------------------------------------#
# Checking for Internet is here..
#--------------------------------------------------------------------#

_INTERNET_STATUS=0;    # Mrunal : 20151229-1050 : 0 - Offline (No internet) and 1 - Online (internet available)
function internet_check() {
#ping www.google.com -c 5

    echo -e "\nWe are checking for Internet connection \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
    INT_COM=`ping www.google.com -c 5 | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) /"`  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
    echo -e "$INT_COM"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
    if [[ "$INT_COM" =~ bytes* ]]; then  # If internet connection is available
        _INT_COM=1
    else              # If no internet connection
        _INT_COM=0;
    fi
    
    echo -e "GET http://metastudio.org\n\n" | nc metastudio.org 80  > /dev/null 2>&1   # Mrunal : No redirections here please
    if [ $? -eq 0 ]; then               # If internet connection is available
        _META=1;
    else              # If no internet connection
        _META=0;
    fi
    
    echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80  > /dev/null 2>&1   # Mrunal : No redirections here please
    if [ $? -eq 0 ]; then               # If internet connection is available
        _GOOGLE=1;
    else              # If no internet connection
        _GOOGLE=0;    
    fi
    
    echo -e "ping:$_INT_COM ; meta:$_META ; google:$_GOOGLE"    | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
    if ([ "$_INT_COM" == 0 ] && [ "$_META" == 0 ] && [ "$_GOOGLE" == 0 ]); then  # If no internet connection
        echo -e "\nInternet connection failed. Please check the network connections(IP, gateway, routes or physical cables)."  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
	_TYPE=0;
	echo -e 'Type of image : \n   1. Docker-build {Building a docker image} \n   2. Docker-image-load {Loading a existing docker image}';
	read _TYPE ;
	echo -e "USER input : $_TYPE";
	
	if [[ "$_TYPE" == "" ]]; then
	    echo "No input";
	elif [[ '$_TYPE' == '1' ]]; then                                              # Docker-build
            echo -e "As internet is not available we couldn't continue installation. Try again later. Thanks."   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE}
        exit 1;
	elif [[ '$_TYPE' == '2' ]]; then                                            # Docker-build
	    echo -e "\nHence we will continue with offline installation."    | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE} 
	else
	    echo -e "\nError-msg : Something went wrong.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	fi
	_INTERNET_STATUS=0;
    else              # If internet connection is available
        echo -e "\nInternet connection Successful."    | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE} 
        echo -e "\nHence we will continue with online installation."    | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /" 2>&1 | tee -a ${INSTALL_LOG_FILE} 
	_INTERNET_STATUS=1;
    fi

}
# -------------------------- Internet code ends here ----------------------------------------


#------------------------------------------------------------------------#
# Checking the existence of the docker package is here..
#------------------------------------------------------------------------#
docker_package_install() {
get_docker_script="get_docker_script.sh"
    if [ -f $get_docker_script ]; then
	echo -e "Info-msg : Docker fetching script shell file exist. \n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    else
	echo -e "Info-msg : Docker fetching script shell file does not exist. \n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    fi

    # Checking for the interent connections
    internet_check

    if [ $_INTERNET_STATUS = 0 ]; then
	echo -e "Info-msg : No internet hence can' t check the latest code for docker fetching script. \n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    elif  [ $_INTERNET_STATUS = 1 ]; then
	sed -i ' s/^/#/' "$get_docker_script";
	wget -qO- https://get.docker.com/ >> /tmp/$get_docker_script ;
	diff_new_old= `diff $get_docker_script /tmp/$get_docker_script`
	    
	echo -e "Info-msg : No internet hence can' t check the latest code for docker fetching script. \n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    fi
}
# -------------------------- Checking the existence of the docker package code ends here ----------------------------------------


# -------------------------- Shell file code starts from here ----------------------------------------

# To check LOG directory and files (If directory is not created do create it with function)
#    Here check_dir is the function and $LOG_DIR is dirctory full path variable defined earlier

check_dir "$LOG_DIR"  # Calling check_dir function to check LOG directory existence

ls

if [[ ! -f docker-inst.lock ]]; then
echo -e "Info-msg : **Prerequisites** \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
echo -e "Info-msg : Checking for OS version and architecture.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}

# Check system os architecture (Currently {Fri Aug 28 17:38:35 IST 2015} docker only supports 64-bit platforms)
os_arch="$(uname -m)"
case "$(uname -m)" in
    *64)
        ;;
    *)
        echo -e "Error-msg: The platform you are using is not an 64-bit version. \n
                 Docker currently only supports 64-bit versions of the platforms. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
        exit 1
        ;;
esac


# checking the platform, version and architecture
lsb_dist=''
dist_version=''

if command_existence_check lsb_release; then
    lsb_dist="$(lsb_release -si)"
fi
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

if command_existence_check lsb_release; then
    dist_version="$(lsb_release --codename | cut -f2)"
fi

if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
    dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
fi
echo "dist:$lsb_dist and version:$dist_version and OS architecture:$os_arch \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}



# Print the username 
user="$(id -un 2>/dev/null || true)"
echo -e "User name : $user \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}


# Identify whether user is root or not
echo -e "\nInfo-msg : Checking type of user and permission"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
if [ "$user" != 'root' ]; then
    if command_existence_check sudo; then
    	sh_c="sudo -E sh -c"
    	echo -e "Info-msg : User($user) with sudo user. \n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    elif command_existence_check su; then
        sh_c="su -c"
        echo -e "Info-msg : User($user) with su user. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    else
	   echo -e "Error: The installer needs the ability to run few commands with root privileges.
       We are unable to find either 'sudo' or 'su' available to make this happen. \n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	   exit 1
    fi
fi

# Checking for the interent connections
internet_check  

# We are checking the wget package. If the package is not installed then install the same
echo -e "\nInfo-msg : Checking wget package. If the package is not installed then install the same "
if command_existence_check wget; then
    echo -e "\nInfo-msg : wget application is already instlled on the system. So no need to install the package. Continuing with the process.\n"   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
else
    echo -e "\nCaution-msg : wget application is not installed on the system. Hence now we will be installing the wget application.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    if _INTERNET_STATUS==1; then
	echo -e "\nCaution-msg : Installing the wget application(Online installation mode).\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	# Updating the repo
	$sh_c 'apt-get update'
	
	# Installing wget application package
	$sh_c 'sudo apt-get install wget'
    elif _INTERNET_STATUS=0; then
	echo -e "\nCaution-msg : Installing the wget application(Offline installation mode).\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	# Installing wget application package
	package_file_name="wget.deb";   # Mrunal : 20151229-1050 : 
	package_name="wget";   # Mrunal : 20151229-1050 : Name or common name of the package
	check_file $package_file_name $package_name    # Mrunal : 20151229-1050 : Check for existance of package file
	$sh_c 'dpkg -i wget.deb'   # Mrunal : 20151229-1050 : Only for Ubuntu or Debian based systems
    else
	echo -e "\nError-msg : Something went wrong.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    fi
fi


# Checking for the interent connections
internet_check

echo -e "\nInfo-msg : **Docker-Image creation** \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}

# We are checking the Docker package. If the package is not installed then install the same
echo -e "\nInfo-msg : Checking Docker package. If the package is not installed then install the same "  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
if command_existence_check docker && [ -e /var/run/docker.sock ]; then
    echo -e "\nInfo-msg : docker application is already installed on the system. So no need to install the package. Continuing with the process. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    # Current user
    echo -e "\nInfo-msg : Current Username : $(whoami) \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    # Print the version of installed docker 
    echo -e "\nInfo-msg : Checking the already installed docker application version  \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    $sh_c 'docker version'   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
else
    echo -e "\nCaution-msg : Docker application is not installed on the system. Hence now we will be installing the Docker application.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    if _INTERNET_STATUS==1; then
	echo -e "\nCaution-msg : Installing the Docker application(Online installation mode).\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	
	# Install Docker application via wget
	wget -qO- https://get.docker.com/ | sh | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	
    elif _INTERNET_STATUS==0; then
	echo -e "\nCaution-msg : Installing the Docker application(Offline installation mode).\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	
	# Install Docker application via wget
	dpkg -i docker-engine.deb | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	
    else
	echo -e "\nError-msg : Something went wrong.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	
    fi
    
    # Current user
    echo -e "\nInfo-msg : Current Username : $(whoami) \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
 
    $sh_c 'more /etc/group'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    _CUR_USER=$(whoami);
    # Adding the current user in docker group
    echo -e "\nInfo-msg : Adding $(whoami) and $_CUR_USER in docker group \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    $sh_c 'sudo usermod -aG docker $(whoami)'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}

    $sh_c "sudo usermod -aG docker $_CUR_USER"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    $sh_c 'more /etc/group'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    
    # Checking the current group of the current user
    #     echo -e "\nInfo-msg : Checking the current group of the $(whoami) : id -g \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    #     $sh_c 'id -g'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    #     # Forcefully changing group of the current user to docker group (to avoid restart)
    #     echo -e "\nInfo-msg : Forcefully changing group of the $(whoami) to docker group : newgrp docker \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
#     $sh_c 'newgrp docker '  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    #     # Checking the current group of the current user
    #     echo -e "\nInfo-msg : Checking the current group of the $(whoami) : id -g \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    #     $sh_c 'id -g'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    # Starting docker(docker-engine) service
    echo -e "\nInfo-msg : Starting docker service (docker-engine) \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    $sh_c 'sudo start docker'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    $sh_c 'sudo service docker start'  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
fi
    $sh_c 'touch docker-inst.lock'   | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    $sh_c 'echo $INSTALL_LOG > docker-inst.lock'    | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    echo -e "\nInfo-msg : Please reboot the system to take effect. And re-run this script again to continue the installation. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    exit
    
elif [[ -f docker-inst.lock ]]; then


# Checking for the interent connections
internet_check

# We are checking the gstudio repo. If the directory exists then take git pull or else take clone of online repo
echo -e "\nInfo-msg : Checking gstudio repo local directory. If the directory exists then take git pull or else take clone of online repo  \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}

# docker image and container related variables
_repo_branch="";


echo -e "\nInfo-msg : Please give branch name of online repo "  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
echo -e -n "\n${red}Branch name: ${reset}"  | tee -a ${INSTALL_LOG_FILE}
read -t 60 _repo_branch

if [ "$_repo_branch" == "" ]; then
    echo -e "\nInfo-msg : No value provided. So applying default value as replica. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    _repo_branch="replica";
fi 

git branch -r  | cut -d/ -f2- | grep -v HEAD | grep $_repo_branch > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "\nInfo-msg : Value provided is $_repo_branch. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
else
    echo -e "\nInfo-msg : Value provided is $_repo_branch. Input is invalid \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    exit
fi

if [ -d "gstudio" ]; then
    cd gstudio

    git branch -r --list | grep $_repo_branch  > /dev/null 2>&1   # Mrunal : No redirections here please
    if [ $? -eq 0 ]; then               # If internet connection is available
	echo -e "\nInfo-msg : Value is correct hence continuing the procedure. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    else
	echo -e "\nInfo-msg : No value provided. So applying default value as replica. \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
	_repo_branch="replica";
    fi	

    # Pull the gstudio code from github online repo
    echo -e "\nInfo-msg : Pull the gstudio latest code from github online repo and $_repo_branch branch as gstudio directory already exist.\n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    
    git branch --list | grep $_repo_branch  > /dev/null 2>&1   # Mrunal : No redirections here please
    if [ $? -eq 0 ]; then               # If internet connection is available
	git checkout $_repo_branch       # Switch to branch 
    else
	git checkout -b $_repo_branch    # Create and Switched to branch
    fi	
    #git pull https://github.com/gnowledge/gstudio.git
    git pull origin $_repo_branch | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    cd ..
else    
    # Clone the gstudio code from github online repo
    echo -e "\nInfo-msg : Clone the gstudio code from github online repo : $_repo_branch \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
    git clone https://github.com/gnowledge/gstudio.git -b $_repo_branch | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
fi


echo -e 'Please select the database for storing the users credentials: \n   1. sqlite \n   2. postgresql';
read _OPTION ;

# Mrunal : for applying comments for sqlite3/postgresql
bash scripts/local_settings_changes.sh $_OPTION $_repo_branch

# Mrunal : start the container
bash scripts/start-new-container.sh $_OPTION $_repo_branch

echo -e "\nInfo-msg : copy pre-install logs to docker system \n" | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
sudo docker cp ${INSTALL_LOG_FILE} $(docker inspect -f '{{.Id}}'  $(docker ps -q)):/root/DockerLogs/  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}

echo -e "\nInfo-msg : Verify the copy process and existence of the file \n"  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
sudo ls /var/lib/docker/aufs/mnt/$(docker inspect -f '{{.Id}}' $(docker ps -q --filter=image=$dock_img_name))/root/DockerLogs/  | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}


docker ps -q --filter=image=$dock_img_name  > /dev/null 2>&1   # Mrunal : No redirections here please
if [ $? -eq 0 ]; then
    # Installation completed
    echo -e "Info-msg : Installation complete successfully. Just enter your ipaddress:port in address bar of your internet browser." | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
else
    # Installation Failed
    echo -e "Caution-msg : Installation Failed. Please try again. \n" | sed -e "s/^/$(date +%Y%b%d-%I%M%S%p) $   /"  2>&1 | tee -a ${INSTALL_LOG_FILE}
fi

fi         # file checking docker-inst.lock
# ----------------------------- Shell file code ends here ------------------------------------------
}
