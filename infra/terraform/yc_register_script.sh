#!/bin/bash

#Backup docker login profile
mv ~/.docker/config.json ~/.docker/config.json.bak

#Create key for service-account
yc iam key create \
--service-account-name $1 \
-o $(pwd)/modules/test_registry/key.json \

#Create profile for service-account
yc config profile create $1

#Add key for service-account in profile
yc config set service-account-key $(pwd)/modules/test_registry/key.json

#Docker login
cat $(pwd)/modules/test_registry/key.json  |  docker login --username json_key \
  --password-stdin \
  cr.yandex

#Use credentials-helper
yc container registry configure-docker

#Move credentials to directory with Dockerfile
mv ~/.docker/config.json  $(pwd)/../../docker/gitlab-runner/

#Activate default account
yc config profile activate default

#Create key for another service account
yc iam key create \
--service-account-name $3 \
-o  $(pwd)/modules/private_registry/key.json \

#Create profile for another service-account
yc config profile create $3

#Add key for another service-account in profile
yc config set service-account-key $(pwd)/modules/private_registry/key.json

#Docker login
cat $(pwd)/modules/private_registry/key.json  |  docker login --username json_key \
  --password-stdin \
  cr.yandex

#Use credentials-helper
yc container registry configure-docker

#Build image with test account credentials
docker build -t cr.yandex/$2/gitlab-runner $(pwd)/../../docker/gitlab-runner/

#Push image in private_registry
docker push cr.yandex/$2/gitlab-runner

#Activate default profile
yc config profile activate default

#Rollback default profile and clear credentials
mv ~/.docker/config.json.bak ~/.docker/config.json
rm -r $(pwd)/modules/test_registry/key.json

#Move key for private_registry to ansible templates
mv $(pwd)/modules/private_registry/key.json  $(pwd)/../ansible/templates/key.json
