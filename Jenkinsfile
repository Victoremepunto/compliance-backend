def secrets = [
    [path: params.VAULT_PATH_INSIGHTSDROID_GITHUB, secretValues: [
        [envVar: 'GITHUB_TOKEN', vaultKey: 'token'],
        [envVar: 'GITHUB_API_URL', vaultKey: 'mirror_url']]],
    [path: params.VAULT_PATH_INSIGHTSDROID_GITHUB, secretValues: [
         [envVar: 'GITHUB_TOKEN', vaultKey: 'token'],
         [envVar: 'GITHUB_API_URL', vaultKey: 'mirror_url']]],        
]

def configuration = [vaultUrl: params.VAULT_ADDRESS, vaultCredentialId: params.VAULT_CREDS_ID]

pipeline {
    agent { label 'rhel8' }
    options {
        timestamps()
    }
    stages {
        stage('Test notifying back ot the PR') {
            steps {
                withVault([configuration: configuration, vaultSecrets: secrets]) {
                    sh '''
                        url="${GITHUB_API_URL}/repos/${ghprbGhRepository}/issues/${ghprbPullId}/comments"
                        curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                        -H "Accept: application/vnd.github+json" \
                        -H "X-GitHub-Api-Version: 2022-11-28" \
                        -X POST -d '{"body":"Me too"}' "$url"
                    '''

                }

            }
        }
    }

    post {
        always{
            sh "echo 'done!'"
        }
    }
}
