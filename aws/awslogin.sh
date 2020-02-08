#!/bin/bash
AWS_ROLE=$NITRO_AWS_ROLE
AWS_PRINCIPAL=$NITRO_AWS_SAML_PRINCIPAL
BASE64_ENCODED_RESPONSE=$1
echo 
rm ~/.aws/credentials
aws sts assume-role-with-saml --role-arn $AWS_ROLE --principal-arn $AWS_PRINCIPAL --saml-assertion $BASE64_ENCODED_RESPONSE | awk -F:  '
                BEGIN { RS = "[,{}]" ; print "[default]"}
                /:/{ gsub(/"/, "", $2) }
                /AccessKeyId/{ print "aws_access_key_id = " $2 }
                /SecretAccessKey/{ print "aws_secret_access_key = " $2 }
                /SessionToken/{ print "aws_session_token = " $2 }
' >> ~/.aws/credentials