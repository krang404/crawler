#!/bin/bash

#Add service account to VM metadata

yc compute instance update $1 --service-account-id $2

#Create key to login Yandex Registry
yc iam key create \
--service-account-id $2 \
-o $(pwd)/../../ansible/templates/key.json
