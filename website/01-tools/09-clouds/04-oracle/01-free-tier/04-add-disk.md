---
layout: page
title: Добавить iscsi диск виртуальной машине Oracle
description: Добавить iscsi диск виртуальной машине Oracle
keywords: Добавить iscsi диск виртуальной машине Oracle
permalink: /tools/clouds/oracle/free-tier/compute-instance/add-disk/
---

<br/>

# Добавить iscsi диск виртуальной машине Oracle

<br/>

```shell
// Create block volume
$ oci bv volume create \
    --availability-domain ${AVAILABILITY_DOMAIN} \
    --compartment-id ${COMPARTMENT_ID} \
    --size-in-mbs 51200
    --display-name VOLUME_DISPLAY_NAME
```

<br/>

```shell
$ export VOLUME_ID=ocid1.volume.oc1.eu-frankfurt-1.abtheljtdfi26t4mjt3rv5z2bmeo4enkgm2givrvm4oiqs4ys6u6umj4jsmq
```

<br/>

```shell
// Check status of the block volume
$ oci bv volume get \
    --volume-id ${VOLUME_ID}
```

<br/>

```shell
// Add block volume to instance
$ oci compute volume-attachment attach \
    --instance-id ${INSTANCE_ID} \
    --type iscsi \
    --volume-id ${VOLUME_ID}
```

<br/>

```shell
$ oci compute volume-attachment list \
    --instance-id ${INSTANCE_ID}
```

<br/>

```shell
$ export ATTACHMENT_ID=ocid1.volumeattachment.oc1.eu-frankfurt-1.antheljtljudzkacz7yiszxkj27qo6bslw3q7pwehhb2oobpa474ycj4phva
```

```shell
$ oci compute volume-attachment get \
    --volume-attachment-id ${ATTACHMENT_ID}
```
