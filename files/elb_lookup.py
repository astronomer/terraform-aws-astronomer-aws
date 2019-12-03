import os
import boto3

def _generate_lb_name_and_tags(client=None,
                               clientv2=None):
    ''' Generate tuples (LB name, tag description)
    for both LB api versions, interleaving queries
    between the v1 and v2 APIs.
    '''

    vpc_id = os.environ['VPC_ID']

    # Get the first page of results from both
    # ELBv1 and ELBv2 APIs
    response = client.describe_load_balancers()
    response2 = clientv2.describe_load_balancers()
    load_balancers = response['LoadBalancerDescriptions']
    nlb_load_balancers = response2['LoadBalancers']

    v1_next_token = response.get('NextMarker')
    v2_next_token = response2.get('NextMarker')

    # do-while loop, conditional at bottom
    while True:

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

        # get the tags by LB name for the case of ELBv1
        if len(load_balancer_names_in_vpc) > 0:
            response = client.describe_tags(
                LoadBalancerNames=load_balancer_names_in_vpc)
            for description in response['TagDescriptions']:
                yield description['LoadBalancerName'], description

        # get the tags by LB ARN for the case of ELBv2
        if len(nlb_load_balancer_arns_in_vpc) > 0:
            response2 = clientv2.describe_tags(
                ResourceArns=nlb_load_balancer_arns_in_vpc)
            for description in response2['TagDescriptions']:
                arn = description['ResourceArn']
                for lb in nlb_load_balancers:
                    if lb['LoadBalancerArn'] == arn:
                        yield lb['LoadBalancerName'], description
                        break

        # If there is not a remaing page on either API,
        # then exit
        if not (v1_next_token or v2_next_token):
            break

        # Grab the next page of data and continue to loop
        load_balancers = []
        nlb_load_balancers = []
        # only loop up if pagination is not complete
        if v1_next_token:
            response = client.describe_load_balancers(Marker=v1_next_token)
            load_balancers = response['LoadBalancerDescriptions']
            v1_next_token = response.get('NextMarker')
        if v2_next_token:
            response2 = clientv2.describe_load_balancers(Marker=v2_next_token)
            nlb_load_balancers = response2['LoadBalancers']
            v2_next_token = response2.get('NextMarker')

def _get_elb_name(client=None,
                  clientv2=None):
    ''' Iterate through a generator that returns LB or NLB name and tags description
    '''
    # Initialize clients, if necessary
    if not client:
        client = boto3.client('elb')
    if not clientv2:
        clientv2 = boto3.client('elbv2')

    cluster_name = os.environ['CLUSTER_NAME']
    for name, description in _generate_lb_name_and_tags(client=client, clientv2=clientv2):
        # Re-map tags from {"Key": "mykey", "Value": "myvalue"} to {"mykey": "myvalue"}
        tags = {}
        for tag in description['Tags']:
            tags[tag['Key']] = tag['Value']
        # If all the tags match, then it's the LB or NLB we are looking for
        if f"kubernetes.io/cluster/{cluster_name}" in tags.keys() \
          and "kubernetes.io/service-name" in tags.keys() \
          and tags["kubernetes.io/service-name"] == "astronomer/astronomer-nginx":
                return {
                    "Name" : name
                }
    return None

def my_handler(event, context):
    return _get_elb_name()
