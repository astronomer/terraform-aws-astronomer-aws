set -xe

TERRAFORM=terraform-0.12.29

$TERRAFORM -v

# unique deployment ID to avoid collisions in CI
# needs to be 32 characters or less and start with letter

cp providers.tf.example examples/$EXAMPLE/providers.tf
cp backend.tf.example examples/$EXAMPLE/backend.tf
cd examples/$EXAMPLE

if [ $DESTROY -eq 1 ]; then
  DEPLOYMENT_ID=ci$(echo "$CIRCLE_PROJECT_REPONAME$CIRCLE_PREVIOUS_BUILD_NUM" | md5sum | awk '{print substr($1,0,30)}')
  echo $DEPLOYMENT_ID
  sed -i "s/REPLACE/$DEPLOYMENT_ID/g" backend.tf
  $TERRAFORM init
  $TERRAFORM destroy --auto-approve -var "deployment_id=$DEPLOYMENT_ID"
else
  DEPLOYMENT_ID=ci$(echo "$CIRCLE_PROJECT_REPONAME$CIRCLE_BUILD_NUM" | md5sum | awk '{print substr($1,0,30)}')
  echo $DEPLOYMENT_ID
  sed -i "s/REPLACE/$DEPLOYMENT_ID/g" backend.tf
  $TERRAFORM init
  $TERRAFORM apply --auto-approve -var "deployment_id=$DEPLOYMENT_ID"
  # check that kubernetes is up and running
  export KUBECONFIG=./kubeconfig-$DEPLOYMENT_ID
  kubectl get namespaces
  kubectl get pods --all-namespaces
fi
