#!/bin/bash

while getopts ":a:b:c:" opt; do
  case $opt in
     a)
       projectprefix="$OPTARG";;
       
     b)
       environment="$OPTARG";;

     c)
       reponame="$OPTARG";;
    

   
  esac
done

#Install yq and give executable perms
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O ./yq && chmod +x ./yq



#Get the latest tag
registry="acr$projectprefix$environment"
latesttag=$(az acr repository show-tags -n $registry --repository $reponame | jq '.[-1]')
echo $latesttag
./yq -i ".parameters.tag.value=$latesttag" ./parameters/$environment.parameters.rgstateless.json
