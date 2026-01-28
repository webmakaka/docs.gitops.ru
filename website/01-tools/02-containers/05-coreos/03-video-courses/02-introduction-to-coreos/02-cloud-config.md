---
layout: page
title: CoreOS cloud-config
description: CoreOS cloud-config
keywords: CoreOS cloud-config
permalink: /devops/containers/coreos/cloud-config/
---

# CoreOS cloud-config

    #cloud-config

    coreos:
      etcd2:
        name: core-01
        # generate a new token for each unique cluster from https://discovery.etcd.io/new?size=3
        # specify the initial size of your cluster with ?size=X
        discovery: https://discovery.etcd.io/5997...
        # multi-region and multi-cloud deployments need to use $public_ipv4
        #advertise-client-urls: http://$private_ipv4:2379,http://$private_ipv4:4001
        advertise-client-urls: http://$public_ipv4:2379,http://$public_ipv4:4001
        initial-advertise-peer-urls: http://$private_ipv4:2380
        # listen on both the official ports and the legacy ports
        # legacy ports can be omitted if your application doesn't depend on them
        listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
        listen-peer-urls: http://$private_ipv4:2380,http://$private_ipv4:7001
        initial-cluster-token: core-01_etcd
        initial-cluster: core-01=http://$private_ipv4:2380
        initial-cluster-state: new
      fleet:
        public-ip: $public_ipv4 # used for fleetctl ssh command
        metadata: region=lon1
      flannel:
        interface: $public_ipv4
      update:
        reboot-strategy: best-effort
      units:
        - name: etcd2.service
          command: start
        - name: fleet.service
          command: start
        - name: docker-tcp.socket
          command: start
          enable: true
          content: |
            [Unit]
            Description=Docker Socket for the API

            [Socket]
            ListenStream=2375
            Service=docker.service
            BindIPv6Only=both

            [Install]
            WantedBy=sockets.target
    ssh_authorized_keys:
      - ssh-rsa AAAA...
    hostname: core-01
    write_files:
      - path: /etc/ssh/sshd_config
        permissions: 0600
        owner: root:root
        content: |
          # Use most defaults for sshd configuration.
          UsePrivilegeSeparation sandbox
          Subsystem sftp internal-sftp

          PermitRootLogin no
          AllowUsers core
          PasswordAuthentication no
          ChallengeResponseAuthentication no
