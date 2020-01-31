#!bin/bash
knife status| awk '{if($1>600)print$4}' |sed s/.$// |awk -F'no' 'NF!=2' > stalenodes.txt
if [ -s stalenodes.txt ]
then
        grep -o -P 'i-0................'< stalenodes.txt | sort -u > instance_id.txt
        while read in; do knife node show ${in} | grep IP\: | cut -d':' -f2 | tr -d ' '; done < stalenodes.txt > instance_ip.txt
        wc -l stalenodes.txt instance_id.txt instance_ip.txt
else
        echo "No instances"
fi
export AWS_PROFILE=v2dev
aws ec2 describe-instances | grep InstanceId | grep -o -P 'i-0................' > instanceid_dev.txt
while read in; do grep  ${in} stalenodes.txt; done < instanceid_dev.txt > actualid_dev.txt
while read in; do knife node show ${in} | grep IP\: | cut -d':' -f2 | tr -d ' '; done < actualid_dev.txt > instanceip_dev.txt
export AWS_PROFILE=v2prod
aws ec2 describe-instances | grep InstanceId | grep -o -P 'i-0................' > instanceid_prod.txt
aws ec2 describe-instances | grep PrivateIpAddress | grep -o -P "\d+\.\d+\.\d+\.\d+" > instanceip_prod.txt
wc -l instanceid_dev.txt instanceip_dev.txt instanceid_prod.txt instanceip_prod.txt 

comm -12 <(sort instanceid_dev.txt) <(sort instance_id.txt) > bootid_dev.txt
comm -12 <(sort instanceip_dev.txt) <(sort instance_ip.txt) > bootip_dev.txt
comm -12 <(sort instanceid_prod.txt) <(sort instance_id.txt) > bootid_prod.txt
comm -12 <(sort instanceip_prod.txt) <(sort instance_ip.txt) > bootip_prod.txt
cat bootid_dev.txt bootid_prod.txt >  bootid.txt
cat bootip_dev.txt bootip_prod.txt >  bootip.txt
diff -12 <(sort instance_id.txt) <(sort bootid.txt) > deleteid.txt
diff -12 <(sort instance_ip.txt) <(sort bootip.txt) > deleteip.txt
wc -l bootid_dev.txt bootip_dev.txt bootid_prod.txt bootip_prod.txt bootid.txt bootip.txt deleteid.txt deleteip.txt

while read in; do grep -w ${in} stalenodes.txt; done < deleteid.txt > deleteidfinal.txt
while read in; do grep -w ${in} stalenodes.txt; done < bootid.txt > bootidfinal.txt

if [ -s bootidfinal.txt ]
then
        while read in; do knife node delete ${in} -y;knife node delete ${in} -y; done < bootidfinal.txt
else
        echo "No Nodes detacted"
fi

if [ -s bootip.txt ]
then
        a=$(cat bootip.txt)
        IFS=$'\n' read -d '' -r -a iplist < bootip.txt
        for  ip in ${iplist[@]}
        do
        Execute="cd /etc/yum.repos.d;ls;sudo rm -rf sensu.repo;ls;cd;sudo rm -rf /home/ec2-user/install /etc/bootstrap/userdata /etc/chef/*;sudo /etc/init.d/ec2autorun start"
        ssh -p 2222 ec2-user@${ip} ${Execute}
        done
else
        echo "No instance available for bootstraping"
fi
if [ -s deleteidfinal.txt ]
then
        while read in; do knife node delete ${in} -y;knife node delete ${in} -y; done < deleteidfinal.txt
else
        echo "No Nodes detacted"
fi
rm -rf *.txt

