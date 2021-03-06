#!/bin/bash

context=$1
namespace=$2
imageTag=$3
database=$4
serviceType=$5
nodePort=$6
network=$7
deployPvc=$8
httpPort=$9
rpcPort=${10}

echo "context: ${context}"
echo "namespace: ${namespace}"
echo "imageTag: ${imageTag}"
echo "database: ${database}"
echo "serviceType: ${serviceType}"
echo "nodePort: ${nodePort}"
echo "network: ${network}"
echo "deployPvc: ${deployPvc}"
echo "httpPort: ${httpPort}"
echo "rpcPort: ${rpcPort}"


kubeContextArg=""
if [[ ${context} != "" ]]
then
    kubeContextArg="--kube-context ${context}"
fi

networkArg=""
if [[ ${network} != "" ]]
then
    networkArg="--set project.network=${network}"
fi

networkSuffix=""
if [[ ${network} != "" ]]
then
    networkSuffix="-${network}"
fi

networkSuffixArg=""
if [[ ${network} != "" ]]
then
    networkSuffixArg="--set project.networkSuffix=${networkSuffix}"
fi

namespaceArg=""
if [[ ${namespace} != "" ]]
then
    namespaceArg="--namespace ${namespace}${networkSuffix}"
fi

namespaceValueArg=""
if [[ ${namespace} != "" ]]
then
    namespaceValueArg="--set project.namespace=${namespace}${networkSuffix}"
fi

serviceTypeArg=""
if [[ ${serviceType} != "" ]]
then
    serviceTypeArg="--set service.type=${serviceType}"
fi

nodePortArg=""
if [[ ${nodePort} != "" ]]
then
    nodePortArg="--set service.nodePort=${nodePort}"
fi

#./undeploy-helm.sh "${context}" ${network}

kubectl create namespace ${namespace}${networkSuffix}

#if [[ ${deployPvc} == "true" ]]
#then
#    cd ./scripts
#    ./create-pv.sh  "${context}" "${namespace}${networkSuffix}" ${networkSuffix} ${storage}
#    cd ..
#fi

rpcPortArg=""
if [[ ${rpcPort} != "" ]]
then
    rpcPortArg="--set service.externalPort=${rpcPort} --set service.internalPort=${rpcPort}"
fi


helm ${kubeContextArg} ${namespaceArg} install -n btcd-kube${networkSuffix} --set database=${database} ${namespaceValueArg} ${serviceTypeArg} ${nodePortArg} ${networkArg} ${networkSuffixArg} ${rpcPortArg} --set image.tag=${imageTag} charts/btcd-kube


if [ $? -eq 0 ]
then
  echo "Deploy Success"
else
  echo "Deploy Error" >&2
fi


#./deploy-helm.sh minikube jx-local 0.0.1 cryptocurrency-services-local
#./deploy-helm.sh "" jx-local 0.0.1 cryptocurrency-services-local
#./deploy-helm.sh "" "" 0.0.1 cryptocurrency-services-local
