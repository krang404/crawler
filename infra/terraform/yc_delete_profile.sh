#!/bin/bash

yc config profile activate default

yc config profile delete sa-private-registry

yc config profile delete sa-test-registry
