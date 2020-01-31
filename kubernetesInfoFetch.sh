#!/bin/bash
pods=`kubectl get pods |awk '{print $1}'|awk '{if(NR>1)print}'| xargs` 
echo "pods and there status are: $name"
jq -R '[ name= kubectl describe pod $pods > pods.txt ]'
grep -e "^\\Name" -e "^\\Status" -e Image -e "^\\Age" pods.txt
