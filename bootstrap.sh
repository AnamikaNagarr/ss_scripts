#!bin/bash
IP=$@
echo ${IP} > ip.txt
a=$(cat ip.txt)
IFS=$'\n' read -d '' -r -a iplist < ip.txt
echo ${iplist[@]}
for IP in ${iplist[@]}
do
  echo "IP is $IP"
  #Execute="cd /etc/yum.repos.d;ls;sudo rm -rf sensu.repo;ls;cd /sbin;sudo sed -i "s/--chef-license accept//g" srev-chef-bootstrap;cat srev-chef-bootstrap;cd;sudo rm -rf /home/ec2-user/install /etc/bootstrap/userdata /etc/chef/*;sudo /etc/init.d/ec2autorun start"
  Execute="cd /etc/yum.repos.d;ls;sudo rm -rf sensu.repo;ls;cd;sudo rm -rf /home/ec2-user/install /etc/bootstrap/userdata /etc/chef/*;sudo /etc/init.d/ec2autorun start"
  ssh -p 2222 ec2-user@${IP} ${Execute}
done
