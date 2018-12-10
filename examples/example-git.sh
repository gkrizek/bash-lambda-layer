
handler () {
    set -e

    EVENT_DATA=$1
    echo $EVENT_DATA

    REPO=$(echo $EVENT_DATA | jq -r ."repository")
    OWNER=$(echo $EVENT_DATA | jq -r ."owner")
    BUCKET=$(echo $EVENT_DATA | jq -r ."bucket")
    mkdir -p /tmp/.ssh
    aws s3 cp s3://$BUCKET/id_rsa /tmp/.ssh/id_rsa
    chmod 400 /tmp/.ssh/id_rsa
    eval `ssh-agent -s`
    export GIT_SSH="/tmp"
    export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/tmp/.ssh/known_hosts -i /tmp/.ssh/id_rsa"
    ssh-add /tmp/.ssh/id_rsa 2>&1
    ssh-keyscan github.com >> /tmp/.ssh/known_hosts 2>&1
    git clone ssh://git@github.com/$OWNER/$REPO.git /tmp/$REPO 2>&1
    ls -al /tmp/$REPO

    echo "Successfully cloned repository" >&2
}