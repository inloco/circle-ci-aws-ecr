#!/bin/bash

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "Must provide AWS_ACCESS_KEY_ID in environment" 1>&2
  exit 1
fi
if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "Must provide AWS_SECRET_ACCESS_KEY in environment" 1>&2
  exit 1
fi
if [[ -z "$AWS_REGION" ]]; then
  export AWS_REGION='us-east-1'
fi

export PIP=$(which pip pip3 | head -1)
if [[ -n $PIP ]]; then
  if which sudo > /dev/null; then
    sudo $PIP install awscli --upgrade
  else
    # This installs the AWS CLI to ~/.local/bin. Make sure that ~/.local/bin is in your $PATH.
    $PIP install awscli --upgrade --user
  fi
elif [[ $(which unzip curl | wc -l) -eq 2 ]]; then
  cd
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
  unzip awscli-bundle.zip
  if which sudo > /dev/null; then
    sudo ~/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
  else
    # This installs the AWS CLI to the default location (~/.local/lib/aws) and create a symbolic link (symlink) at ~/bin/aws. Make sure that ~/bin is in your $PATH.
    awscli-bundle/install -b ~/bin/aws
  fi
  rm -rf awscli-bundle*
  cd -
else
  echo "Unable to install AWS CLI. Please install pip."
  exit 1
fi

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_REGION"
$(aws ecr get-login --no-include-email)
