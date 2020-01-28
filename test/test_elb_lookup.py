#!/usr/bin/env python3

import os
this_directory = os.path.dirname(os.path.realpath(__file__))
script_dir = os.path.realpath(os.path.join(this_directory,'../files'))
import sys
sys.path.append(script_dir)
from unittest.mock import MagicMock
from elb_lookup import _get_elb_name

cluster_name = 'myfakecluster'
os.environ['CLUSTER_NAME'] = cluster_name
os.environ['VPC_ID'] = 'myfakevpcid'

def mock_boto3_elbv1_client(paginate_times=0):
    mock_client = MagicMock()
    pages_lb = [
        {
            'LoadBalancerDescriptions': [
                {
                    'LoadBalancerName': 'myfakelb',
                    'VPCId': 'myfakevpcid'
                },
            ]
        }
    ]
    pages_tags = [
        {
            'TagDescriptions': [
                {
                    'LoadBalancerName': 'myfakelb',
                    'Tags': [
                        {
                            'Key': f"kubernetes.io/cluster/{cluster_name}",
                            'Value': '1'
                        },
                        {
                            'Key': f"kubernetes.io/service-name",
                            'Value': 'astronomer/astronomer-nginx'
                        }
                    ]
                },
            ]
        }
    ]
    for i in range(0, paginate_times):
        pages_lb = [
            {
                'LoadBalancerDescriptions': [
                    {
                        'LoadBalancerName': f'myfakelb-{i}',
                        'VPCId': 'myfakevpcid'
                    },
                ],
                'NextMarker': 'foo'
            }
        ] + pages_lb
        pages_tags = [
            {
                'TagDescriptions': [
                    {
                        'LoadBalancerName': f'myfakelb-{i}',
                        'Tags': []
                    },
                ]
            }
        ] + pages_tags

    mock_client.describe_load_balancers.side_effect = pages_lb
    mock_client.describe_tags.side_effect = pages_tags
    return mock_client

def mock_boto3_elbv2_client(paginate_times=0):
    mock_client = MagicMock()
    pages_lb = [
        {
            'LoadBalancers': [
                {
                    'LoadBalancerName': 'myfakelb',
                    'LoadBalancerArn': 'myfakelbarn',
                    'VpcId': 'myfakevpcid'
                },
            ]
        }
    ]
    pages_tags = [
        {
            'TagDescriptions': [
                {
                    'ResourceArn': 'myfakelbarn',
                    'Tags': [
                        {
                            'Key': f"kubernetes.io/cluster/{cluster_name}",
                            'Value': '1'
                        },
                        {
                            'Key': f"kubernetes.io/service-name",
                            'Value': 'astronomer/astronomer-nginx'
                        }
                    ]
                },
            ]
        }
    ]

    for i in range(0, paginate_times):
        pages_lb = [
            {
                'LoadBalancers': [
                    {
                        'LoadBalancerName': f'myfakelb-{i}',
                        'LoadBalancerArn': f'myfakelbarn-{i}',
                        'VpcId': 'myfakevpcid'
                    },
                ],
                'NextMarker': 'foo'
            }
        ] + pages_lb
        pages_tags = [
            {
                'TagDescriptions': [
                    {
                        'ResourceArn': f'myfakearn-{i}',
                        'Tags': []
                    },
                ]
            }
        ] + pages_tags

    mock_client.describe_load_balancers.side_effect = pages_lb
    mock_client.describe_tags.side_effect = pages_tags
    return mock_client

def mock_clients(paginate_times=0):
    return mock_boto3_elbv1_client(paginate_times=paginate_times), \
        mock_boto3_elbv2_client(paginate_times=paginate_times)

def test_get_elb_name():
    clientv1, clientv2 = mock_clients()
    assert 'myfakelb' == _get_elb_name(client=clientv1, clientv2=clientv2)['Name']

def test_get_elb_name_with_pagination():
    clientv1, clientv2 = mock_clients(paginate_times=1000)
    assert 'myfakelb' == _get_elb_name(client=clientv1, clientv2=clientv2)['Name']
