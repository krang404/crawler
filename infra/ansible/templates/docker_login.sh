#!/bin/bash

cat key.json | docker login \
  --username json_key \
  --password-stdin \
  cr.yandex
