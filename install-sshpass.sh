#installing sshpass 
printf "\n ****** Downloading the rpm to $PWD  *******"
sudo wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo rpm -ivh epel-release-6-8.noarch.rpm

printf "\n ****** installing sshpass  *******"
sudo yum --enablerepo=epel -y install sshpass
printf "\n\n **** sshpass installed ******\n\n"

exit 0 # avoid shutdowns
