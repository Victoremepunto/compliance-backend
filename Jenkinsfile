def secrets = [
    [path: params.VAULT_PATH_SVC_ACCOUNT_EPHEMERAL, secretValues: [
        [envVar: 'OC_LOGIN_TOKEN_DEV', vaultKey: 'oc-login-token-dev'],
        [envVar: 'OC_LOGIN_SERVER_DEV', vaultKey: 'oc-login-server-dev'],
        [envVar: 'OC_LOGIN_TOKEN', vaultKey: 'oc-login-token'],
        [envVar: 'OC_LOGIN_SERVER', vaultKey: 'oc-login-server']]],
    [path: params.VAULT_PATH_QUAY_PUSH, secretValues: [
        [envVar: 'QUAY_USER', vaultKey: 'user'],
        [envVar: 'QUAY_TOKEN', vaultKey: 'token']]],
    [path: params.VAULT_PATH_RHR_PULL, secretValues: [
        [envVar: 'RH_REGISTRY_USER', vaultKey: 'user'],
        [envVar: 'RH_REGISTRY_TOKEN', vaultKey: 'token']]]
]

def configuration = [vaultUrl: params.VAULT_ADDRESS, vaultCredentialId: params.VAULT_CREDS_ID]

pipeline {
    agent { label 'rhel8' }
    options {
        timestamps()
        parallelsAlwaysFailFast()
    }
    environment {
        APP_NAME="compliance"
        ARTIFACTS_DIR=""
        CICD_URL="https://raw.githubusercontent.com/RedHatInsights/cicd-tools/main"
        COMPONENT_NAME="compliance"
        COMPONENTS_W_RESOURCES="compliance"
        IMAGE="quay.io/cloudservices/compliance-backend"
        IQE_CJI_TIMEOUT="30m"
        IQE_FILTER_EXPRESSION=""
        IQE_MARKER_EXPRESSION="compliance_smoke"
        IQE_PLUGINS="compliance"
        REF_ENV="insights-stage"
    }

    stages {
        stage('Dummy test stage') {
            steps {
                withVault([configuration: configuration, vaultSecrets: secrets]) {
                sh '''
                    env
                    whoami
                    ls -lrt $KUBE_
                    curl -s ${CICD_URL}/bootstrap.sh > .cicd_bootstrap.sh
                    source ./.cicd_bootstrap.sh
                    # source "${CICD_ROOT}/deploy_ephemeral_env.sh"
                    # source "${CICD_ROOT}/cji_smoke_test.sh"
                '''
                }
            }
        }
    }
}
