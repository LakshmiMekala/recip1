#!/bin/bash

mkdir ${HOME}/.aws

cat > ${HOME}/.aws/credentials << EOL
[default]
access_key_id = ${SITE_KEY}
secret_access_key = ${SITE_KEY_SECRET}
EOL 

cat > ${HOME}/.aws/config << EOL
[default]
output = json
region = ${AWS_REGION}
EOL 

aws s3 rm s3://test-bucket4569/master-builds/latest --recursive


