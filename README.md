# k8s-master-upgrader

This is a script to upgrade a GKE master if a new version is available.

You can find the alpine-based Docker image 
[here](https://hub.docker.com/r/eversc/k8s-master-upgrader).

To get the latest version available in a specific zone, it issues the following
command:

```
gcloud container get-server-config \
  --zone $GCP_ZONE\
  --project $GCP_PROJECT\
  --format="json" | jq -r '.validMasterVersions[0]'
```

note: this does, therefore, require that Google return the latest
validMasterVersions as the first element.

## Config

An example config:

```
CLUSTER_NAME=my-cluster
GCP_PROJECT=my-project
GCP_SA_ACCOUNT=k8s-master-upgrader@my-project.iam.gserviceaccount.com
GCP_ZONE=europe-west2-a
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/**change_me**/**change_me**/**change_me**
```

The key.json for the GCP Service Account used in `gcloud` calls needs to be
placed at the path `/home/gcloud/key.json`

## Env Vars

| Name        | Required           | Default  |
| ------------- |:------------:| -----|
| CLUSTER_NAME     | y |  |
| CONFIG_PATH     | n |  "./k8s_master_upgrade.conf" |
| GCP_PROJECT     | y |  |
| GCP_SA_ACCOUNT     | y |  |
| GCP_ZONE     | y |  |
| SLACK_WEBHOOK_URL | n | "" |

If an upgrade is performed, and you have `SLACK_WEBHOOK_URL` defined, the script
will post a message to the Slack URL you've specified, with a message like:

```
k8s master of cluster: `my-cluster` upgraded from version `1.12.5-gke.10`
to `1.12.5-gke.5`.
```

