#!/bin/bash	
set -x	
export PodName=$PodName	
export Version=$Version	

 export AWS_PROFILE=v2dev	
export VpcName=V2Dev	

 export Stack=IDX	
export Component=IDX	
export InstanceCount=1	

 export WORKSPACE=/var/lib/jenkins/orca	
export aws_path=`which aws`	

 #scp -P 2222 /var/lib/jenkins/orca/scripts/dellpricing-refresh/Pricing_Refresh.sh /var/lib/jenkins/orca/scripts/dellpricing-refresh/Pricing_Functions.sh  ec2-user@${GetHostIPs}:~/	
source /var/lib/jenkins/orca/scripts/dellpricing-refresh/Pricing_Functions.sh	
echo "performing refresh for $PodName"	
#terminateStack $VpcName $PodName $Component $Stack	
createStack $VpcName $PodName $Component $Stack $InstanceCount	
sleep 10m	
GetHostIPs=$(getIPAddresses)	
Execute="chmod +x /var/lib/jenkins/orca/scripts/dellpricing-refresh/Pricing_Functions.sh;chmod +x /var/lib/jenkins/orca/scripts/dellpricing-refresh/Pricing_Refresh.sh ;./var/lib/jenkins/orca/scripts/dellpricing-refresh/Pricing_Refresh.sh"	
ssh -p 2222 ec2-user@"$GetHostIPs" "$Execute"
