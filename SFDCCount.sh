#!/bin/bash
# NAME:     SFDCCount.sh
# TODO:     - Connect sfdc
#           - Fire SFDC Query and get count
set -x
# set variables/arrays

#if $ALL == true; then
#	COLLECTIONS='product2,asset,account,ssi_zth__location_address__c,ssi_zth__hierarchy_level__c,pricebookentry,contact,opportunity,quote,servicesource1__ren_source__c,case,servicesource1__ren_renews_to__c,quotelineitem,task,servicesource1__chl_partner_opportunity__c';
#fi

POD=$1
echo ${POD}
STACK=$2
echo ${STACK}
TENANT=$3
echo ${TENANT}
PLATFORM_VERSION=$4
echo ${PLATFORM_VERSION}
COLLECTIONS=$5
echo ${COLLECTIONS}

xpathUpToTenant='.env.'${POD}'.'${STACK}'.'${PLATFORM_VERSION}'.'${TENANT}

xpathSFDCUserName=$xpathUpToTenant'.username'
xpathSFDCPassword=$xpathUpToTenant'.password'
xpathSFDCSecurityToken=$xpathUpToTenant'.securitytoken'
xpathSFDCClientId=$xpathUpToTenant'.client_id'
xpathSFDCSecretKey=$xpathUpToTenant'.client_secret'

SFDCUserName=$(cat /var/lib/jenkins/orca/scripts/devadmin/sfdc/PROPERTY_DETAILS.json | jq ".\"$POD\".\"$PLATFORM_VERSION\".username"| tr -d '"')
SFDCPass=$(cat /var/lib/jenkins/orca/scripts/devadmin/sfdc/PROPERTY_DETAILS.json | jq ".\"$POD\".\"$PLATFORM_VERSION\".password"| tr -d '"')
SFDCSecurityToken=$(cat /var/lib/jenkins/orca/scripts/devadmin/sfdc/PROPERTY_DETAILS.json | jq ".\"$POD\".\"$PLATFORM_VERSION\".securityToken"| tr -d '"')
SFDCSecretKey=$(cat /var/lib/jenkins/orca/scripts/devadmin/sfdc/PROPERTY_DETAILS.json | jq ".\"$POD\".\"$PLATFORM_VERSION\".clientSecretKey"| tr -d '"')
SFDCClientId=$(cat /var/lib/jenkins/orca/scripts/devadmin/sfdc/PROPERTY_DETAILS.json | jq ".\"$POD\".\"$PLATFORM_VERSION\".clientId"| tr -d '"')

echo $SFDCUserName
echo $SFDCPass
echo $SFDCSecurityToken
echo $SFDCSecretKey
echo $SFDCClientId

#take access token by hitting below url temporary
if [ "$POD" == sqa ] || [ "$POD" == sbx ] || [ "$POD" == sbo ]
then 
response=$(curl -s -X POST -k -H 'Content-Type: application/x-www-form-urlencoded' 'https://test.salesforce.com/services/oauth2/token' --data 'grant_type=password&username='$SFDCUserName'&password='$SFDCPass$SFDCSecurityToken'&client_id='$SFDCClientId'&client_secret='$SFDCSecretKey)
fi
if [ "$POD" == renew ]
then 
response=$(curl -s -X POST -k -H 'Content-Type: application/x-www-form-urlencoded' 'https://login.salesforce.com/services/oauth2/token' --data 'grant_type=password&username='$SFDCUserName'&password='$SFDCPass$SFDCSecurityToken'&client_id='$SFDCClientId'&client_secret='$SFDCSecretKey)
fi
#extract token from response json
access_token=$(echo $response | jq -r '.access_token')
#extract instance url which is environment specific e.g. na55.salesforce.com
instanceURL=$(echo $response | jq -r '.instance_url')

echo $instanceURL
echo "access token" $access_token
allCnt=''
for coll in $(echo ${COLLECTIONS} | sed "s/,/ /g")
do  
	# Sent SOQL Query using above access token and create string variable contains all entities count
	cntRes=$(curl -H "Authorization: Bearer $access_token" -H "X-PrettyPrint:1" ${instanceURL}'/services/data/v34.0/query/?q=SELECT+count()+from+'$coll)
	echo $cntRes
	count=$(echo $cntRes | jq -r '.totalSize')

allCnt="$allCnt\n$coll count is :"$count
done

echo -e $allCnt
################
#####END OF SCRIPT########
