#!/bin/bash

sed -i '1d' $(pwd)/../../ansible-plays/inventory

echo $1 | tee $(pwd)/../ansible-plays/inventory
