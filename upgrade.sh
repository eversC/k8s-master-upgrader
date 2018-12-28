#!/bin/bash
set -e

config_file="./k8s_master_upgrade.conf"
if [ ! -z $CONFIG_PATH ] ; then
  config_file=$CONFIG_PATH
fi

if [ -f $config_file ] ; then
IFS="="
while read -r name value
do
export "$name"="$value"
done < $config_file
fi

[ -z "$CLUSTER_NAME" ] && echo "CLUSTER_NAME is required" && invalid=true
[ -z "$GCP_PROJECT" ] && echo "GCP_PROJECT is required" && invalid=true
[ -z "$GCP_SA_ACCOUNT" ] && echo "GCP_SA_ACCOUNT is required" && invalid=true
[ -z "$GCP_ZONE" ] && echo "GCP_ZONE is required" && invalid=true

if [ "$invalid" = true ] ; then
    exit 1
fi

gcloud auth activate-service-account $GCP_SA_ACCOUNT --key-file=./key.json

greatest_master_version=$(gcloud container get-server-config --zone $GCP_ZONE --project $GCP_PROJECT --format="json" | jq -r '.validMasterVersions[0]')

regex='^[0-9]*\.[0-9]*\..*$'
if [[ ! $greatest_master_version =~ $regex ]]
then
  echo "greatest_master_version: $greatest_master_version failed regex: $regex"
  exit 1
fi

current_master_version=$(gcloud container clusters describe $CLUSTER_NAME --zone $GCP_ZONE --project $GCP_PROJECT --format="json" | jq -r .currentMasterVersion)
echo "greatest k8s master version: $greatest_master_version"
echo "current version of k8s cluster '$CLUSTER_NAME' master: '$current_master_version"

if [ $greatest_master_version != $current_master_version ]; then
  echo "upgrade should be performed"
  gcloud container clusters upgrade $CLUSTER_NAME --zone $GCP_ZONE --project $GCP_PROJECT --master --cluster-version $greatest_master_version  --quiet
  if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
   curl -X POST --data-urlencode "payload={\"text\": \"k8s master of cluster: \`$CLUSTER_NAME\` upgraded from version \`$current_master_version\` to \`$greatest_master_version\`.\"}" $SLACK_WEBHOOK_URL
  fi
fi