#!/bin/bash

set -exv

CICD_TOOLS_URL="https://raw.githubusercontent.com/RedHatInsights/cicd-tools/main/src/bootstrap.sh"
# shellcheck source=/dev/null
source <(curl -sSL "$CICD_TOOLS_URL") image_builder

export CICD_IMAGE_BUILDER_IMAGE_NAME='quay.io/cloudservices/compliance-backend'
export CICD_IMAGE_BUILDER_BUILD_ARGS=("IMAGE_TAG=$(cicd::image_builder::get_image_tag)")
# Check if the current Git branch is 'origin/security-compliance'.
if [[ "$GIT_BRANCH" == "origin/security-compliance" ]]; then
    # Generate a tag for the Docker image based on the current date and Git commit short hash.
    SECURITY_COMPLIANCE_TAG="sc-$(date +%Y%m%d)-$(git rev-parse --short=7 HEAD)"
    
    # Set ADDITIONAL_TAGS to the generated security compliance tag.
    export CICD_IMAGE_BUILDER_ADDITIONAL_TAGS=("$SECURITY_COMPLIANCE_TAG")
else
    # If the current Git branch is not 'origin/security-compliance':
    export CICD_IMAGE_BUILDER_ADDITIONAL_TAGS=("latest")
fi

echo -n "$PULP_CLIENT_CERT" > "${WORKSPACE}/pulp_client.crt"
# Try using the cert
HTTPS_PROXY=http://squid.corp.redhat.com:3128 curl --cert "${WORKSPACE}/pulp_client.crt"  https://mtls.internal.console.stage.redhat.com/api/pulp-content/compliance/rubygems/

cicd::image_builder::build_and_push
