#!/bin/bash

printf "\n\n getting cluster id"
id=$(cat /mnt/var/lib/info/job-flow.json | grep jobFlowId | cut -f2 -d: | cut -f2 -d'"')
printf "\n\n id is : $id"
aws emr describe-cluster --cluster-id $id --region us-east-1 > clusterdetails.json

clusterName=$(cat clusterdetails.json  |  jq -r '.Cluster.Name' clusterdetails.json)
clusterNamee=$(echo "$clusterName" | tr -d '"')
printf "\n clusterName :  $clusterNamee"

caseNumber=$(cat clusterdetails.json  |  jq --raw-output '.Cluster.Tags[4].Value' clusterdetails.json)
caseNumberr=$(echo "$caseNumber" | tr -d '"')
printf "\n caseNumber :  $caseNumberr"

caseOwnerName=$(cat clusterdetails.json  |  jq --raw-output '.Cluster.Tags[0].Value' clusterdetails.json)
caseOwnerNamee=$(echo "$caseOwnerName" | tr -d '"')
printf "\n caseOwnerName :  $caseOwnerNamee"

ClusterName=$clusterNamee
printf "\n clusterName :  $clusterName"
caseNumber=$caseNumberr
printf "\n caseNumber :  $caseNumber"
caseOwnerName=$caseOwnerNamee
printf "\n caseOwnerName :  $caseOwnerName"

aws ses send-email --region us-east-1 --from "tdixit@servicesource.com" --destination "ToAddresses=anamika.nagar@impetus.com --message "Subject={Data=EBS modified,Charset=UTF-8},Body={Text={Data=heyyyyya,Charset=UTF-8},Html={Data=<!DOCTYPE html><html><body><p>Hi $caseOwnerName&#44;</p><p>The volume on the $ClusterName is modified by 50% .</p><p>Case-$caseNumber</p><p style="line-height:0.6">Regards&#44;</p><p style="line-height:0.6">Ops Team.</p></body></html>,Charset=UTF-8}}" 
echo "Mail sent to : $caseOwnerName , as the volume on the cluster is modified Volume by 50%"
