FROM google/cloud-sdk:alpine

RUN apk update \
 && apk add jq \
 && rm -rf /var/cache/apk/*

RUN addgroup -S gcloud && adduser -S gcloud  -G gcloud

COPY upgrade.sh upgrade.sh
RUN chown gcloud:gcloud upgrade.sh
USER gcloud
RUN chmod u+x upgrade.sh

ENTRYPOINT ["./upgrade.sh"]
