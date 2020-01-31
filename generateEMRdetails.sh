#!/bin/bash


scriptStartTime=$(date +%s)

printf "\n Script Execution Start time : ${scriptStartTime}\n"

outFolder="${WORKSPACE}/IL/EMRJSON"
mkdir ${WORKSPACE}/IL
mkdir ${WORKSPACE}/IL/EMRJSON
v2devProfileName="$1"
v2prodProfileName="$2"

printf "\n\nDownloading V2DEV EMR List JSON file"
aws emr --region us-east-1 --profile ${v2devProfileName}  list-clusters --active  > v2DevEMRList.json
printf "\nDownload Complete\n"

printf "\n\nDownloading PROD EMR List JSON file"
aws emr --region us-east-1 --profile ${v2prodProfileName}  list-clusters --active  > v2ProdEMRList.json
printf "\nDownload Complete\n"


v2DevNoOfClusters=$(cat v2DevEMRList.json  |  jq ".Clusters | length")



v2ProdNoOfClusters=$(cat v2ProdEMRList.json  |  jq ".Clusters | length")



# for thisAccount in ${v2devProfileName} ${v2prodProfileName}; do
#     case "$thisAccount" in
#         "v2p" )
#             echo "Working on prod IL files"
#             account="965786919165"
#             outFile="${outFolder}/EMRV2PROD.json"
#             ;;
#         "v2d" )
#             echo "working on DEV IL files"
#             account="969364019056"
#             outFile="${outFolder}/EMRV2DEV.json"
#             ;;
#     esac


## Columns Headingings  Name | Core node count| Task Node count | Case number | Case Owner
#set -x

outFile="${outFolder}/EMRDETAILS.json"
touch "${outFile}"
printf '%s\n' "[" > $outFile

printf "\n\n ********** Working on V2DEV EMR Details **********"
printf "\n\n v2DevNoOfClusters : ${v2DevNoOfClusters}"

for ((i=0; i<$v2DevNoOfClusters; i++));
do
    clusterID=$(cat v2DevEMRList.json  |  jq ".Clusters[$i].Id")    
    clusterIDD=$(echo "$clusterID" | tr -d '"')
    clusterName=$(cat v2DevEMRList.json  |  jq ".Clusters[$i].Name")
    clusterNamee=$(echo "$clusterName" | tr -d '"')
    printf "\n clusterID : $clusterIDD"
    printf "\n clusterName :  $clusterNamee"

    printf ' %s\n' "{" >> $outFile
    printf '    "ClusterId":"%s",\n' "$clusterIDD" >> $outFile
    printf '    "ClusterName":"%s",\n' "$clusterNamee" >> $outFile


    aws emr --profile ${v2devProfileName} --region us-east-1 describe-cluster --cluster-id $clusterIDD  > $clusterID.json
    
    noOfClusterInstanceGroups=$(cat $clusterID.json | jq ".Cluster.InstanceGroups | length")

    printf "\n\n noOfClusterInstanceGroups : ${noOfClusterInstanceGroups} "

    noOfTagsOfCluster=$(cat $clusterID.json | jq ".Cluster.Tags | length")
    clusterCaseNumber=""
    clusterCaseOwner=""

    for ((t=0; t<${noOfTagsOfCluster}; t++));
    do
    	tagKey=$(cat $clusterID.json | jq ".Cluster.Tags[$t].Key")
        tagValue=$(cat $clusterID.json | jq ".Cluster.Tags[$t].Value")        
        printf '    %s:%s,\n' "${tagKey}" "${tagValue}" >> $outFile
    done

    for ((ig=0; ig<${noOfClusterInstanceGroups}; ig++));
    do
        instanceGroupType=$(cat $clusterID.json | jq ".Cluster.InstanceGroups[$ig].InstanceGroupType")        
        instanceGroupTypee=$(echo "$instanceGroupType" | tr -d '"')
        #printf "\n\ninstanceGroupTypee : ${instanceGroupTypee}"

        if [[ "${instanceGroupTypee}" == "CORE" ]]; then
            coreInstancesCount=$(cat $clusterID.json | jq ".Cluster.InstanceGroups[$ig].RunningInstanceCount")
            printf '    \"%s\":\"%s\",\n' "CoreNodeCount" "${coreInstancesCount}" >> $outFile
        fi

        if [[ "${instanceGroupTypee}" == "TASK" ]]; then
            taskInstancesCount=$(cat $clusterID.json | jq ".Cluster.InstanceGroups[$ig].RunningInstanceCount")
            printf '    \"%s\":\"%s\",\n' "TaskNodeCount" "${taskInstancesCount}" >> $outFile
        fi
    done


    printf "    \"blank\" : \"blank\" \n"  >> $outFile
    printf ' %s\n' "}," >> $outFile    
done

printf "\n\n ********* DONE ************"

printf "\n\n ************** Working on V2PROD EMR Details ***********"

printf "\n\n v2ProdNoOfClusters : ${v2ProdNoOfClusters}  "
for ((i=0; i<$v2ProdNoOfClusters; i++));
do
    clusterID=$(cat v2ProdEMRList.json  |  jq ".Clusters[$i].Id")    
    clusterIDD=$(echo "$clusterID" | tr -d '"')
    clusterName=$(cat v2ProdEMRList.json  |  jq ".Clusters[$i].Name")
    clusterNamee=$(echo "$clusterName" | tr -d '"')
    printf "\n clusterID : $clusterIDD"
    printf "\n clusterName :  $clusterNamee"

    printf ' %s\n' "{" >> $outFile
    printf '    "ClusterId":"%s",\n' "$clusterIDD" >> $outFile
    printf '    "ClusterName":"%s",\n' "$clusterNamee" >> $outFile


    aws emr --profile ${v2prodProfileName} --region us-east-1 describe-cluster --cluster-id $clusterIDD  > $clusterID.json
    
    noOfClusterInstanceGroups=$(cat $clusterID.json | jq ".Cluster.InstanceGroups | length")

    printf "\n\n noOfClusterInstanceGroups : ${noOfClusterInstanceGroups} "

    noOfTagsOfCluster=$(cat $clusterID.json | jq ".Cluster.Tags | length")
    clusterCaseNumber=""
    clusterCaseOwner=""

    for ((t=0; t<${noOfTagsOfCluster}; t++));
    do
        tagKey=$(cat $clusterID.json | jq ".Cluster.Tags[$t].Key")
        tagValue=$(cat $clusterID.json | jq ".Cluster.Tags[$t].Value")        
        printf '    %s:%s,\n' "${tagKey}" "${tagValue}" >> $outFile
    done

    for ((ig=0; ig<${noOfClusterInstanceGroups}; ig++));
    do
        instanceGroupType=$(cat $clusterID.json | jq ".Cluster.InstanceGroups[$ig].InstanceGroupType")        
        instanceGroupTypee=$(echo "$instanceGroupType" | tr -d '"')
        #printf "\n\ninstanceGroupTypee : ${instanceGroupTypee}"

        if [[ "${instanceGroupTypee}" == "CORE" ]]; then
            coreInstancesCount=$(cat $clusterID.json | jq ".Cluster.InstanceGroups[$ig].RunningInstanceCount")
            printf '    \"%s\":\"%s\",\n' "CoreNodeCount" "${coreInstancesCount}" >> $outFile
        fi

        if [[ "${instanceGroupTypee}" == "TASK" ]]; then
            taskInstancesCount=$(cat $clusterID.json | jq ".Cluster.InstanceGroups[$ig].RunningInstanceCount")
            printf '    \"%s\":\"%s\",\n' "TaskNodeCount" "${taskInstancesCount}" >> $outFile
        fi
    done


    printf "    \"blank\" : \"blank\" \n"  >> $outFile
    printf ' %s\n' "}," >> $outFile    
done

printf "\n\n ********* DONE ************\n\n"



printf ' %s\n' "{}" >> $outFile
printf '%s\n' "]" >> $outFile

