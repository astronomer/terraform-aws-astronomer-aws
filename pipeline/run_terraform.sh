set -xe

terraform -v

# unique deployment ID to avoid collisions in CI
DEPLOYMENT_ID=$(echo "$DRONE_REPO_NAME$DRONE_BUILD_NUMBER" | md5sum | awk '{print $1}')

cp providers.tf.example examples/$EXAMPLE/providers.tf
cp backend.tf.example examples/$EXAMPLE/backend.tf
cd examples/$EXAMPLE
sed -i "s/REPLACE/$DEPLOYMENT_ID/g" backend.tf

terraform init

if [ $DESTROY -eq 1 ]; then
  terraform destroy --auto-approve -var "deployment_id=$DEPLOYMENT_ID"
else
  terraform apply --auto-approve -var "deployment_id=$DEPLOYMENT_ID"
fi
