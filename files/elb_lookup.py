import os
import boto3

client = boto3.client('elb')
clientv2 = boto3.client('elbv2')
vpc_id = os.environ['VPC_ID']
cluster_name = os.environ['CLUSTER_NAME']

def _get_elb_name():
    response = client.describe_load_balancers()
    response2 = clientv2.describe_load_balancers()
    load_balancers = response['LoadBalancerDescriptions']
    nlb_load_balancers = response2['LoadBalancers']

    # get all the ELBs in this VPC
    load_balancer_names_in_vpc = []
    for lb in load_balancers:
        if lb['VPCId'] == vpc_id:
            load_balancer_names_in_vpc.append(lb["LoadBalancerName"])

    # get all the ELBs in this VPC
    nlb_load_balancer_arns_in_vpc = []
    for lb in nlb_load_balancers:
        if lb['VpcId'] == vpc_id:
            nlb_load_balancer_arns_in_vpc.append(lb["LoadBalancerArn"])

    tag_descriptions = []
    # get the tags
    if len(load_balancer_names_in_vpc) > 0:
        response = client.describe_tags(
            LoadBalancerNames=load_balancer_names_in_vpc)
        tag_descriptions += response['TagDescriptions']
    if len(nlb_load_balancer_arns_in_vpc) > 0:
        response2 = clientv2.describe_tags(
            ResourceArns=nlb_load_balancer_arns_in_vpc)
        tag_descriptions += response2['TagDescriptions']

    # return the name of the ELB corresponding to this cluster
    for description in tag_descriptions:
        tags = {}
        for tag in description['Tags']:
            tags[tag['Key']] = tag['Value']
        if f"kubernetes.io/cluster/{cluster_name}" in tags.keys() \
          and "kubernetes.io/service-name" in tags.keys() \
          and tags["kubernetes.io/service-name"] == "astronomer/astronomer-nginx":
            if 'ResourceArn' in description.keys():
                arn = description['ResourceArn']
                for lb in nlb_load_balancers:
                    if lb['LoadBalancerArn'] == arn:
                        return {
                            "Name" : lb['LoadBalancerName']
                        }
            else:
                return {
                    "Name" : description['LoadBalancerName']
                }

    return None

def my_handler(event, context):
    return _get_elb_name()
