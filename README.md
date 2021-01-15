# brudi-operator
The brudi-operator is a Helm-based kubernetes operator for the [`brudi`](https://github.com/mittwald/brudi) backup tool. It offers easy control of `brudi` in your kubernetes-cluster via custom `backup` and `restore` resources, which can be sued to shedule backups at regular intervals or restore them if needed, with the operator handling the specifics such as cron and container creation.

## Table of contents

## Deployment

## Usage

### Create backups

Example for backing up a mongodb every 15 minutes and storing the backups in a restic repository:
```yaml
apiVersion: mittwald.systems/v1alpha1
kind: Backup
metadata:
  name: example-backup
spec:
  image:
    repository: quay.io/mittwald/brudi
    pullPolicy: IfNotPresent

  cronjob:
    schedule: '*/15 * * * *'
    restartPolicy: Never
    concurrencyPolicy: Forbid
    failedJobsHistoryLimit: 1
    successfulJobsHistoryLimit: 1

  brudi:
    config:
      mongodump:
        options:
          flags:
            host: mongodb
            port: 27017
            out: /tmp/mongo.dump
            username: root
            password: mongodbroot
      restic:
        global:
          flags:
            repo: "YOUR_RESTIC_REPO"
        forget:
          flags:
            keepDaily: 7
            keepHourly: 24
            keepLast: 48
            keepMonthly: 6
            keepWeekly: 2
            keepYearly: 2
          ids: []
    cli:
      command: "mongodump"
      restic: true
      resticForget: false
      cleanup: false

  additionalEnv:{}

  additionalLabels: {}

  additionalVolumes: {}

  additionalVolumeMounts: {}

  imagePullSecrets: []
  nameOverride: ""
  fullnameOverride: ""

  podSecurityContext: {}

  securityContext: {}

  resources: {}

  nodeSelector: {}

  tolerations: []

  affinity: {}
```

### Restore from backups

Example to restore a mongodb from the last restic backup
```yaml
apiVersion: mittwald.systems/v1alpha1
kind: Restore
metadata:
  name: example-restore
spec:
  image:
    repository: quay.io/mittwald/brudi
    pullPolicy: IfNotPresent

  job:
    restartPolicy: Never
    concurrencyPolicy: Forbid

  brudi:
    config:
      mongorestore:
        options:
          flags:
            host: mongodb
            port: 27017
            dir: /tmp/mongo.dump
            username: root
            password: mongodbroot
      restic:
        global:
          flags:
            repo: "YOUR_RESTIC_REPO"
        restore:
          flags:
            target: "/"
          id: "latest"
    cli:
      command: "mongorestore"
      restic: true
      resticForget: false
      cleanup: false

  additionalEnv: {}

  additionalLabels: {}

  additionalVolumes: {}

  additionalVolumeMounts: {}

  imagePullSecrets: []
  nameOverride: ""
  fullnameOverride: ""

  podSecurityContext: {}

  securityContext: {}

  resources: {}

  nodeSelector: {}

  tolerations: []

  affinity: {}
```