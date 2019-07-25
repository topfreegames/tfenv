#!/usr/bin/env bash

check_version() {
  v="${1}"
  [ -n "$(terraform --version | grep -E "^Terraform v${v}((-dev)|( \([a-f0-9]+\)))?$")" ]
}

cleanup() {
  if [ -n "$TFENV_CONFIG_DIR" ]; then
    rm -rf "$TFENV_CONFIG_DIR"
  else
    rm -rf ./versions
    rm ./version
  fi
  rm -rf ./.terraform-version
  rm -rf ./min_required.tf
}
