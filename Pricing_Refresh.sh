#!/bin/bash	
set -x	
source /home/ec2-user/Pricing_Functions.sh	

 echo "performing pricing refresh"	
read -p "Enter PodName : " PodName	
PodName=$PodName	
read -p "Enter Version : " Version	
Stack=IDX	
Version=$Version	
Component=IDX	
InstanceCount=1	
aws_path=`which aws`	
WORKSPACE=${WORKSPACE}	

 export PodName	
export VpcName	
export Stack	
export Component	
export Version	
export InstanceCount	
export WORKSPACE=${WORKSPACE}	
export aws_path=`which aws`	


 if [ "$PodName" == SBX ]	
then	
        VpcName=V2Dev	
        echo "performing refresh for $PodName"	
        #createStack $VpcName $PodName $Component $Stack $InstanceCount	
        #sleep 5m	
        #GetHostIPs=$(getIPAddresses)	
        #sleep 8m	
        pricingDataS3Path=$(aws s3 ls s3://avaloncms/PricingData/ --recursive | sort | tail -n 1 | awk '{print $4}')	
        echo "$pricingDataS3Path"	
        sleep 8m	
        GetZip="cd /var/lib/idx/data ;	
        mkdir pricing ;	
        cd pricing ;	
        aws s3 cp s3://avaloncms/$pricingDataS3Path . ;	
        sleep 5m	
        sudo unzip test_*.zip"	
        ssh -p 2222 ec2-user@"$GetHostIPs" "$GetZip"	
        zip	
        certificate	
        count $PodName	
        mongo automation_dell --username admin --password welcome --eval 'db.app.pricings.drop()'	
        restore $PodName	
        count $PodName	
        sleep 2m	
        echo "pricing complete for $PodName"	
        sleep 2m	
        echo "performing stack termination"	
        terminateStack $VpcName $PodName $Component $Stack	
fi 	

 if [ "$PodName" == SQA ] || [ "$PodName" == PE ] || [ "$PodName" == RENEW ]	
then 	
        VpcName=V2Dev	
        echo "performing refresh for $PodName"	
        createStack $VpcName $PodName $Component $Stack $InstanceCount	
        sleep 5m 	
        GetHostIPs=$(getIPAddresses)	
        sleep 5m	
        pricingDataS3Path=$(aws s3 ls s3://avaloncms/PricingData/ --recursive | sort | tail -n 1 | awk '{print $4}')	
        echo "$pricingDataS3Path"	
        sleep 10m	
        GetZip="cd /var/lib/idx/data ;	
        mkdir pricing ;	
        cd pricing ;	
        aws s3 cp s3://avaloncms/$pricingDataS3Path . ;	
        sleep 2m	
        sudo unzip test_*.zip"	
        ssh -p 2222 ec2-user@"$GetHostIPs" "$GetZip"	
        zip	
        certificate	
        count $PodName	
        restore $PodName	
        sleep 2m	
        mongo automation_dell --username admin --password welcome --eval 'db.app.pricings.renameCollection("app.pricings.backup")'	
        mongo automation_dell --username admin --password welcome --eval 'db.app.pricings.new.renameCollection("app.pricings")'	
        count $PodName	
        echo "pricing complete for $PodName"	
        sleep 2m	
        echo "performing stack termination"	
        terminateStack $VpcName $PodName $Component $Stack	
fi
