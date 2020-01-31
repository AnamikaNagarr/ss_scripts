from kazoo.client import KazooClient
import logging
import json
import sys
import os.path
logging.basicConfig()
import argparse

parser=argparse.ArgumentParser()
parser.add_argument('--POD')
parser.add_argument('--TENANT')
parser.add_argument('--PLATFORM_VERSION')
args=parser.parse_args()
POD = args.POD
TENANT = args.TENANT
PLATFORM_VERSION = args.PLATFORM_VERSION

podNameList=['sbx','sqa','sbo','pe']
print POD
print TENANT
print PLATFORM_VERSION
outFolder= "/var/lib/jenkins/orca/scripts/devadmin/sfdc"
#outFolder= "/home/impadmin/anamika"
PROPERTY_JSON_PATH=outFolder+"/PROPERTY_DETAILS.json"
podDictionary = dict()
if POD == "sbx":
    zkServer='shared-zkp-k8s.int.dev.ssi-cloud.com:2181'
    print("sbx")
if POD == "sbo":
    zkServer='shared-zkp-2.int.dev.ssi-cloud.com:2181'
    print("sbo")

if POD == "sqa" and PLATFORM_VERSION == "frb1":
    zkServer='shared-zkp-k8s.int.dev.ssi-cloud.com:2181'
    print("sqa and stk1.")
if POD == "sqa" and PLATFORM_VERSION == "frb3":
    zkServer='shared-zkp-2.int.dev.ssi-cloud.com:2181'
    print("sqa and stk3.")

if POD == "pe":
    zkServer='pe-zkp-2.int.dev.ssi-cloud.com:2181'
    print("PE")
elif POD == "renew":
    zkServer='renew-zkp-3.int.prod.ssi-cloud.com:2181'
    print("RENEW")
zk = KazooClient(hosts=zkServer, read_only=True)

zk.start()
platformPath = "/env/"+POD+"/releases"
platformList = zk.get_children(platformPath)
print "\n\nPlatform Versions in %s environment are :  %s" % (POD, platformList)
platformDictionary = dict()
propertyDict = dict()
#for platform in platformList:
#    print "\n Current Platform available : "+PLATFORM_VERSION
#    propertyDict = dict()
usernameData=""
passwordData=""
securityTokenData=""
clientIdData=""
clientSecretKeyData=""
tenantDataJSON=""
tenantnameList=['dell','cisco','symantec','nexmech','netapp','leica','mcafee']
tenantPath=platformPath+"/"+PLATFORM_VERSION+"/env-config/PRISM"
print tenantPath
print zk.exists(tenantPath)

if zk.exists(tenantPath):
    tenantDataJSONString, status = zk.get(tenantPath)
    tenantDataJSON = json.loads(tenantDataJSONString)
    print(tenantDataJSONString)
    print(tenantDataJSON)
if "username" in tenantDataJSON.keys():
    usernameData = tenantDataJSON["username"][TENANT]
print usernameData
if "password" in tenantDataJSON.keys():
    passwordData = tenantDataJSON["password"][TENANT]
print passwordData
if "securityToken" in tenantDataJSON.keys():
    securityTokenData = tenantDataJSON["securityToken"][TENANT]
print securityTokenData
if "clientId" in tenantDataJSON.keys():
    clientIdData = tenantDataJSON["clientId"][TENANT]
print clientIdData
if "clientSecretKey" in tenantDataJSON.keys():
    clientSecretKeyData = tenantDataJSON["clientSecretKey"][TENANT]
print clientSecretKeyData
 
propertyDict["username"]=usernameData
propertyDict["password"]=passwordData
propertyDict["securityToken"]=securityTokenData
propertyDict["clientId"]=clientIdData
propertyDict["clientSecretKey"]=clientSecretKeyData
platformDictionary[PLATFORM_VERSION]=propertyDict
podDictionary[POD]=platformDictionary
print "podDictionary : "+str(podDictionary) 
podDictionaryString = json.dumps(podDictionary)
print "\n\n podDictionaryString : "+podDictionaryString
PropertyJSON = open(PROPERTY_JSON_PATH,"w")
PropertyJSON.write(podDictionaryString);
PropertyJSON.close()
zk.stop()

