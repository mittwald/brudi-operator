<!-- vscode-markdown-toc -->
* 1. [Table of contents](#Tableofcontents)
* 2. [Deployment](#Deployment)
* 3. [Usage](#Usage)
	* 3.1. [Create backups](#Createbackups)
	* 3.2. [Restore from backups](#Restorefrombackups)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc --># brudi-operator

The brudi-operator is a Helm-based kubernetes operator for the [`brudi`](https://github.com/mittwald/brudi) backup tool. It offers easy control over `brudi` in your kubernetes-cluster via custom `backup` and `restore` resources. These can be sued to schedule backups at regular intervals or restore data, if needed, with the operator handling the specifics such as cron and container creation.

##  1. <a name='Tableofcontents'></a>Table of contents

* [Deployment](#deployment)
* [Usage](#usage)
  * [Create backups](#create-backups)
  * [Restore from backups](#restore-from-backups)

##  2. <a name='Deployment'></a>Deployment

As mentioned in the introduction, `brudi-operaotr` is based on [Helm](https://helm.sh/). Refer to Helm's [documentation](documentation) to get started, then follow the steps below

1. [Add the Mittwald-Charts Repo](https://github.com/mittwald/helm-charts)

```shell
$ helm repo add mittwald https://helm.mittwald.de
"mittwald" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "mittwald" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

1. Upgrade or install `brudi-operator` `helm upgrade --install brudi-operator mittwald/brudi-operator`

##  3. <a name='Usage'></a>Usage

###  3.1. <a name='Createbackups'></a>Create backups

Automatic backups in the form of `cronjobs` can be scheduled using `backup` resources. The operator will watch for these resources and create or delete matching `cronjobs` when a `backup` resource is created/deleted. To create a resource, simply create a `.yaml` file that describes it and apply it to your cluster, the operator will take care of the rest.
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

For more configuration options please refer to the [brudi backup documentation](https://github.com/mittwald/brudi#sources)

###  3.2. <a name='Restorefrombackups'></a>Restore from backups

Restoration from backup is done with `jobs`, which are created via `restore` resources.  
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

For more configuration options please refer to the [brudi restore documentation](https://github.com/mittwald/brudi#restoring-from-backup)
