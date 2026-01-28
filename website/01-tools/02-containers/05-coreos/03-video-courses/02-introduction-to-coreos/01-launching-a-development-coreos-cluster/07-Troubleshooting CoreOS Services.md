---
layout: page
title: Introduction to CoreOS Training Video, Troubleshooting CoreOS Services
description: Introduction to CoreOS Training Video, Troubleshooting CoreOS Services
keywords: Introduction to CoreOS Training Video, Troubleshooting CoreOS Services
permalink: /devops/containers/coreos/introduction-to-coreos/launching-a-development-coreos-cluster/Troubleshooting_CoreOS_Services/
---

# [O’Reilly Media / Infinite Skills] Introduction to CoreOS Training Video [2015, ENG] : Launching A Development CoreOS Cluster : Troubleshooting CoreOS Services

<br/>

### Troubleshooting CoreOS Services

<br/>

    $ systemctl status docker
    ● docker.service - Docker Application Container Engine
       Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor pres
       Active: active (running) since Sun 2016-11-27 00:56:40 UTC; 2h 43min ago
         Docs: http://docs.docker.com
     Main PID: 636 (docker)
        Tasks: 33
       Memory: 442.3M
          CPU: 22.857s
       CGroup: /system.slice/docker.service
               ├─ 636 docker daemon --host=fd:// --selinux-enabled
               ├─ 889 containerd -l /var/run/docker/libcontainerd/docker-containerd.
               ├─5740 docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 3000 -cont
               └─5744 containerd-shim 405e83cdc97c702b229d58ebee3a2c3d988714470b16ed

    Nov 27 02:13:43 core-01 dockerd[636]: time="2016-11-27T02:13:43.146043346Z" leve
    Nov 27 02:13:43 core-01 dockerd[636]: time="2016-11-27T02:13:43.182032126Z" leve
    Nov 27 02:13:43 core-01 dockerd[636]: time="2016-11-27T02:13:43.182563242Z" leve
    Nov 27 02:13:43 core-01 dockerd[636]: time="2016-11-27T02:13:43.224193536Z" leve
    Nov 27 02:23:16 core-01 dockerd[636]: time="2016-11-27T02:23:16.687457176Z" leve
    Nov 27 02:23:16 core-01 dockerd[636]: time="2016-11-27T02:23:16.710737499Z" leve
    Nov 27 02:23:19 core-01 dockerd[636]: time="2016-11-27T02:23:19.406633927Z" leve
    Nov 27 02:23:19 core-01 dockerd[636]: time="2016-11-27T02:23:19.451274111Z" leve
    Nov 27 02:23:19 core-01 dockerd[636]: time="2016-11-27T02:23:19.451794255Z" leve

<br/>

    $ systemctl status -l fleet
    ● fleet.service - fleet daemon
       Loaded: loaded (/usr/lib/systemd/system/fleet.service; disabled; vendor prese
      Drop-In: /run/systemd/system/fleet.service.d
               └─20-cloudinit.conf
       Active: active (running) since Sun 2016-11-27 00:57:06 UTC; 2h 20min ago
     Main PID: 831 (fleetd)
        Tasks: 7
       Memory: 24.9M
          CPU: 1min 41.107s
       CGroup: /system.slice/fleet.service
               └─831 /usr/bin/fleetd

    Nov 27 02:40:15 core-02 fleetd[831]: INFO manager.go:259: Removing systemd unit
    Nov 27 02:40:15 core-02 fleetd[831]: INFO manager.go:182: Instructing systemd to
    Nov 27 02:40:15 core-02 fleetd[831]: INFO reconcile.go:330: AgentReconciler comp
    Nov 27 02:40:15 core-02 fleetd[831]: INFO reconcile.go:330: AgentReconciler comp
    Nov 27 02:43:05 core-02 fleetd[831]: INFO manager.go:246: Writing systemd unit n
    Nov 27 02:43:05 core-02 fleetd[831]: INFO manager.go:182: Instructing systemd to
    Nov 27 02:43:05 core-02 fleetd[831]: INFO manager.go:127: Triggered systemd unit
    Nov 27 02:43:05 core-02 fleetd[831]: INFO reconcile.go:330: AgentReconciler comp
    Nov 27 02:43:05 core-02 fleetd[831]: INFO reconcile.go:330: AgentReconciler comp
    Nov 27 02:43:05 core-02 fleetd[831]: INFO reconcile.go:330: AgentReconciler comp

<br/>

    $ systemctl status -l etcd
    ● etcd.service - etcd
       Loaded: loaded (/usr/lib/systemd/system/etcd.service; static; vendor preset:
       Active: inactive (dead)

<br/>

    $ systemctl status etcd2
    ● etcd2.service - etcd2
       Loaded: loaded (/usr/lib/systemd/system/etcd2.service; disabled; vendor prese
      Drop-In: /run/systemd/system/etcd2.service.d
               └─20-cloudinit.conf
       Active: active (running) since Sun 2016-11-27 00:56:42 UTC; 2h 44min ago
     Main PID: 833 (etcd2)
        Tasks: 9
       Memory: 66.5M
          CPU: 2min 9.642s
       CGroup: /system.slice/etcd2.service
               └─833 /usr/bin/etcd2

    Nov 27 03:03:22 core-01 etcd2[833]: saved snapshot at index 40004
    Nov 27 03:03:22 core-01 etcd2[833]: compacted raft log at 35004
    Nov 27 03:24:29 core-01 etcd2[833]: failed to send out heartbeat on time (deadli
    Nov 27 03:24:29 core-01 etcd2[833]: server is likely overloaded
    Nov 27 03:24:29 core-01 etcd2[833]: failed to send out heartbeat on time (deadli
    Nov 27 03:24:29 core-01 etcd2[833]: server is likely overloaded
    Nov 27 03:36:55 core-01 etcd2[833]: failed to send out heartbeat on time (deadli
    Nov 27 03:36:55 core-01 etcd2[833]: server is likely overloaded
    Nov 27 03:36:55 core-01 etcd2[833]: failed to send out heartbeat on time (deadli
    Nov 27 03:36:55 core-01 etcd2[833]: server is likely overloaded

<br/>

       $ journalctl -b -u etcd
       -- No entries --
