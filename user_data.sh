#!/bin/bash


AWS_DEFAULT_REGION=$(hostname -f | cut -d'.' -f2)

export AWS_DEFAULT_REGION

declare -x BASE_USER_PATH="/home/ec2-user/"

function get_packages(){

    sudo yum install -y jq git python3

}

get_packages

# install poetry

curl -sSL https://install.python-poetry.org | sudo -u ec2-user python3 -

sudo -u ec2-user mkdir -p "${BASE_USER_PATH}.aws"

sudo -u ec2-user mkdir -p "${BASE_USER_PATH}bin"

cat <<- HEREDOC | sudo -u ec2-user tee -a ${BASE_USER_PATH}.aws/config
[default]
region=$AWS_DEFAULT_REGION
output=json
HEREDOC


GITHUB_TOKEN=$(aws secretsmanager get-secret-value --secret-id snyk_sync_secrets --query SecretString | jq -r 'fromjson | .GITHUB_TOKEN')

export GITHUB_TOKEN

sudo -u ec2-user git config --global url."https://api@github.com/".insteadOf "https://github.com/"
sudo -u ec2-user git config --global url."https://ssh@github.com/".insteadOf "ssh://git@github.com/"
sudo -u ec2-user git config --global url."https://git@github.com/".insteadOf "git@github.com:"

echo 'echo password=$GITHUB_TOKEN' | sudo -u ec2-user tee -a "${BASE_USER_PATH}bin/git-credential-script"
sudo -u ec2-user chmod +x "${BASE_USER_PATH}bin/git-credential-script"

sudo -u ec2-user git config --global credential.helper "/bin/bash ${BASE_USER_PATH}bin/git-credential-script"

sudo -u ec2-user git clone "https://github.com/snyk-playground/snyk-sync.git" "${BASE_USER_PATH}snyk-sync"

/bin/bash "${BASE_USER_PATH}snyk-sync/scripts/install_snyk_tools.sh"

cd "${BASE_USER_PATH}snyk-sync" || exit

sudo -u ec2-user "${BASE_USER_PATH}.local/bin/poetry" config virtualenvs.in-project true
sudo -u ec2-user "${BASE_USER_PATH}.local/bin/poetry" install 


cd "${BASE_USER_PATH}" || exit

sudo -u ec2-user cp "${BASE_USER_PATH}snyk-sync/scripts/aws_cron.sh" "${BASE_USER_PATH}bin/aws_cron.sh"

sudo -u ec2-user chmod +x "${BASE_USER_PATH}bin/aws_cron.sh"

