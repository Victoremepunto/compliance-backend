def secrets = [
    [path: params.VAULT_PATH_SVC_ACCOUNT_EPHEMERAL, secretValues: [
        [envVar: 'OC_LOGIN_TOKEN_DEV', vaultKey: 'oc-login-token-dev'],
        [envVar: 'OC_LOGIN_SERVER_DEV', vaultKey: 'oc-login-server-dev'],
        [envVar: 'OC_LOGIN_TOKEN', vaultKey: 'oc-login-token'],
        [envVar: 'OC_LOGIN_SERVER', vaultKey: 'oc-login-server']]],
    [path: params.VAULT_PATH_QUAY_PUSH, secretValues: [
        [envVar: 'QUAY_USER', vaultKey: 'user'],
        [envVar: 'QUAY_TOKEN', vaultKey: 'token']]],
    [path: params.VAULT_PATH_INSIGHTSDROID_GITHUB, secretValues: [
        [envVar: 'GITHUB_TOKEN', vaultKey: 'token'],
        [envVar: 'GITHUB_API_URL', vaultKey: 'mirror_url']]],
    [path: params.VAULT_PATH_COMPLIANCE_PULP_CLIENT_CERT, secretValues: [
        [envVar: 'PULP_CLIENT_CERT', vaultKey: 'pulp-cert']]]
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

        stage('Test cert') {
            steps {
                withVault([configuration: configuration, vaultSecrets: secrets]) {
                    sh '''
                        echo -n "$PULP_CLIENT_CERT" > pulp_client.crt
                        ls -l pulp_client.crt
                        export HTTPS_PROXY=http://squid.corp.redhat.com:3128

                        curl --cert "pulp_client.crt" \
                            https://mtls.internal.console.stage.redhat.com/api/pulp-content/compliance/rubygems/
                        exit 99
                    '''
                }
            }
        }

        stage('Build the PR commit image') {
            steps {
                withVault([configuration: configuration, vaultSecrets: secrets]) {
                    sh 'bash -x build_deploy.sh'
                }
            }
        }

        stage('Run Tests') {
            parallel {
                stage('Run unit tests') {
                    steps {
                        withVault([configuration: configuration, vaultSecrets: secrets]) {
                            sh 'bash -x ./scripts/unit_test.sh'
                        }
                    }
                }
                stage('Run smoke tests') {
                    steps {
                        withVault([configuration: configuration, vaultSecrets: secrets]) {
                            sh '''
                                AVAILABLE_CLUSTERS=('ephemeral' 'crcd')
                                curl -s ${CICD_URL}/bootstrap.sh > .cicd_bootstrap.sh
                                source ./.cicd_bootstrap.sh
                                source "${CICD_ROOT}/deploy_ephemeral_env.sh"
                                source "${CICD_ROOT}/cji_smoke_test.sh"
                            '''
                        }
                    }
                    post {
                        failure {
                            slackSend  channel: '@eshamard', color: "danger", message: "Smoke tests failed in Compliance PR check. <${env.ghprbPullLink}|PR link>  (<${env.BUILD_URL}|Build>)"
                        }
                        unstable {
                            slackSend  channel: '@eshamard', color: "warning", message: "Smoke tests failed in Compliance PR check. <${env.ghprbPullLink}|PR link>  (<${env.BUILD_URL}|Build>)"
                        }
                    }
                }
            }
        }
    }

    post {
        always{
            archiveArtifacts artifacts: 'artifacts/**/*', fingerprint: true
            junit skipPublishingChecks: true, testResults: 'artifacts/junit-*.xml'
        }
    }
}
