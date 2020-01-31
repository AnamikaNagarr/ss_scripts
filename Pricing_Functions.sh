#!/bin/bash	

 die () {	
    echo "####### CRITICAL ERROR #########"	
    echo >&2 "$@"	
    echo "################################"	
    exit 1	
}	


 validateStack()	
{	
  STACK_STATUS=""	
  while [[ $STACK_STATUS != "CREATE_COMPLETE" ]]	
  do	
   STACK_STATUS=$($aws_path cloudformation describe-stacks --stack-name "$PodName-$Component-$Version" | jq '.Stacks[0].StackStatus')	
   [[ "$?" -ne 0 ]] && die "Failed to get stack information"	
   STACK_STATUS=$(echo "$STACK_STATUS" | sed "s/\"//g")	
   sleep 30	
  done	
}	

 getIPAddresses()	
{	
  GetHostIPs=$($aws_path  ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" "Name=tag:Stack,Values=$Stack" "Name=tag:PodName,Values=$PodName" "Name=tag:Version,Values=$Version" --output text --query 'Reservations[*].Instances[*].[PrivateIpAddress]')	
  #/usr/local/bin/aws ec2 describe-instances --region us-east-1 --filters Name=instance-state-name,Values=running Name=tag:Stack,Values=IDX Name=tag:PodName,Values=SQA Name=tag:Version,Values=STK3 --output text --query 'Reservations[*].Instances[*].[PrivateIpAddress]'	
  sleep 2m	
  echo "$GetHostIPs"	
}	

 createStack() 	
{	
set +e	
$aws_path cloudformation describe-stacks --stack-name "$PodName-$Component-$Version"	

 if [[ $? == 0 ]]; then	
 echo "Stack already exists so not doing anything"	
else	
  "${WORKSPACE}"/bin/orca deploy pod-component --yes --direct-update "$VpcName" "$PodName" "$Component" "$Version"       	
 [[ "$?" -ne 0 ]] && die "Failed to create/update the stack"	
 validateStack "$PodName" "$Component" "$Version"	
fi	
set -e	
}	

 terminateStack() 	
{	
	"${WORKSPACE}"/bin/orca delete --yes pod-component "$VpcName" "$PodName" "$Component" "$Version"	

         [[ "$?" -ne 0 ]] && die "Failed to terminate the stack"	

         echo "Stack termination has been initiated"	
}	

 #This function will download certificate	
  certificate() 	
{	
  echo "performing certificate download"	
  export JAVA_HOME=$JAVA_HOME	
  echo "$pwd"	
  sudo wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem 	
  sudo keytool -import -alias rds-combined-ca-bundle -keystore "$JAVA_HOME"/jre/lib/security/cacerts -trustcacerts -file rds-combined-ca-bundle.pem -storepass changeit -no-prompt	
  sudo keytool -list -v -keystore "$JAVA_HOME"/jre/lib/security/cacerts -storepass changeit -alias rds-combined-ca-bundle 	
}	

 #This function will get count for app.pricings collection only	
  count() 	
{	
  if [[ $PodName == SBX ]]; then	
   mongo automation_dell --ssl --host shared-docdb.cluster-cpbvd3ebtcjx.us-east-1.docdb.amazonaws.com:27017 --sslCAFile rds-combined-ca-bundle.pem --username admin --password welcome --eval 'db.app.pricings.count()'	
  else	
  mongo automation_dell --username admin --password welcome --eval 'db.app.pricings.count()'	
fi	
}	

 #This function will get the zip and unzip it 	
  zip()	
{	
  cd /var/lib/idx/data	
  mkdir pricing	
  cd pricing	
  zip=avaloncms/$(aws s3 ls s3://avaloncms/PricingData/ --recursive | sort | tail -n 1 | awk '{print $4}')	
  echo "$zip"	
  aws s3 cp s3://"$zip" .	
  sudo unzip test_*.zip 	
}	

 #This function will perform restore 	
  restore()	
{	

   if [[ $PodName == SBX ]]; then	
    echo "PREFORMING RESTORE AND INDEXING ON SBX"	
    mongorestore --ssl --host shared-docdb.cluster-cpbvd3ebtcjx.us-east-1.docdb.amazonaws.com:27017 --sslCAFile rds-combined-ca-bundle.pem --db automation_dell /var/lib/idx/data/pricing/test/app.pricings.bson --username admin --password welcome --collection app.pricings --noIndexRestore >> SBX_DocDB_Pricing_Restore.log 	
    mongo sbx_configdata_frb5 --ssl --host shared-docdb.cluster-cpbvd3ebtcjx.us-east-1.docdb.amazonaws.com:27017 --username admin --password welcome  --sslCAFile rds-combined-ca-bundle.pem -eval "var dbList=['dell#automation_dell#admin#welcome'],auxDB='sbx_configdata_frb5', isDocumentDb =true" metadataIndexes.js >> createAppPricingsIndex.log	
  elif [[ $PodName == SQA ]]; then	
  echo "PREFORMING RESTORE ON SQA"	
  mongorestore --collection app.pricings.new -u admin -p welcome --db automation_dell /var/lib/idx/data/pricing/test/app.pricings.bson >> SQA_Pricing_Restore.log	
  elif [[ $PodName == PE ]]; then 	
  echo "PREFORMING RESTORE ON PE"	
  mongorestore  -u appuser_dell -p adth78hj --db automation_dell --collection app.pricings.new  /var/lib/idx/data/pricing/test/app.pricings.bson >> PE_Pricing_Restore.log	
  elif [[ $PodName == RENWEW ]]; then	
  echo "PREFORMING RESTORE ON RENEW"	
  mongorestore --collection app.pricings.new -u admin -p welcome --db automation_dell /var/lib/idx/data/pricing/test/app.pricings.bson >> RENEW_Pricing_Restore.log	
 fi 	
}
