#!/bin/bash
set -x
echo "calling script to fetch cluster details "
sh ./generateEMRdetails.sh
output="${Directory}/emrdetails.json" |awk '{print $1}'|awk '{if(NR>1)print}'| xargs` 
echo "looping clusters in dev "
for ((i=0; i<$v2DevNoOfClusters; i++)); 
do
jq -R '[$(cat v2DevEMRList.json | grep -e "^\\clusterName"]
 for ((j=0; i<$v2DevNoOfClusters; i++));  
 do
 caseOwnerName=$clusterCaseOwner
 clusterName=$clusterName
 caseNumber=$clusterCaseNumber
 aws ses send-email \
  --from "tdixit@servicesource.com" \
  --destination "ToAddresses=mkhare@servicesource.com" \
  --message "Subject={Data=EBS modified,Charset=UTF-8},Body={Text={Data=heyyyyya,Charset=UTF-8},Html={Data=<!DOCTYPE html><html><body><p>Hi $caseOwnerName&#44;</p><p>$clusterName Volume on the Cluster is modified .Added additional volume on the cluster.</p><p>Case-$caseNumber</p><p style="line-height:0.6">Regards&#44;</p><p style="line-height:0.6">Ops Team.</p></body></html>,Charset=UTF-8}}" \
echo "mail sent to the $clusterCaseOwner"
