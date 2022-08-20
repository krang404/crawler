#!/bin/bash

sed -i '1d' $(pwd)/../../ansible/inventory

echo $1 | tee $(pwd)/../../ansible/inventory
