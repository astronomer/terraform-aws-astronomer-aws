#!/bin/bash

set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

terraform --version
terraform init
terraform apply --auto-approve --target=module.astronomer_aws_with_vpc
terraform apply --auto-approve
terraform destroy --auto-approve
