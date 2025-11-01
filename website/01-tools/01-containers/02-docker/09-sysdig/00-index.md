---
layout: page
title: Получить информацию о запущенных Docker контейнерах c помощью sysdig
description: Получить информацию о запущенных Docker контейнерах c помощью sysdig
keywords: devops, docker, Получить информацию о запущенных Docker контейнерах c помощью sysdig
permalink: /devops/containers/docker/sysdig/
---

# Получить информацию о запущенных Docker контейнерах c помощью sysdig

Инсталляция:

    # curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

<br/>

    # sysdig -cl

    Category: Application
    ---------------------
    httplog         HTTP requests log
    httptop         Top HTTP requests
    memcachelog     memcached requests log

    Category: CPU Usage
    -------------------
    spectrogram     Visualize OS latency in real time.
    subsecoffset    Visualize subsecond offset execution time.
    topcontainers_cpu
                    Top containers by CPU usage
    topprocs_cpu    Top processes by CPU usage

    Category: Errors
    ----------------
    topcontainers_error
                    Top containers by number of errors
    topfiles_errors Top files by number of errors
    topprocs_errors top processes by number of errors

    Category: I/O
    -------------
    echo_fds        Print the data read and written by processes.
    fdbytes_by      I/O bytes, aggregated by an arbitrary filter field
    fdcount_by      FD count, aggregated by an arbitrary filter field
    fdtime_by       FD time group by
    iobytes         Sum of I/O bytes on any type of FD
    iobytes_file    Sum of file I/O bytes
    spy_file        Echo any read/write made by any process to all files. Optionall
                    y, you can provide the name of one file to only intercept reads
                    /writes to that file.
    stderr          Print stderr of processes
    stdin           Print stdin of processes
    stdout          Print stdout of processes
    topcontainers_file
                    Top containers by R+W disk bytes
    topfiles_bytes  Top files by R+W bytes
    topfiles_time   Top files by time
    topprocs_file   Top processes by R+W disk bytes
    tracers_2_statsd
                    Print the data read and written by processes.

    Category: Logs
    --------------
    spy_logs        Echo any write made by any process to a log file. Optionally, e
                    xport the events around each log message to file.
    spy_syslog      Print every message written to syslog. Optionally, export the e
                    vents around each syslog message to file.

    Category: Misc
    --------------
    around          Export to file the events around the where the given filter mat
                    ches.

    Category: Net
    -------------
    iobytes_net     Show total network I/O bytes
    spy_ip          Show the data exchanged with the given IP address
    spy_port        Show the data exchanged using the given IP port number
    topconns        Top network connections by total bytes
    topcontainers_net
                    Top containers by network I/O
    topports_server Top TCP/UDP server ports by R+W bytes
    topprocs_net    Top processes by network I/O

    Category: Performance
    ---------------------
    bottlenecks     Slowest system calls
    fileslower      Trace slow file I/O
    flame           Sysdig trace flame graph builder
    netlower        Trace slow network I/0
    proc_exec_time  Show process execution time
    scallslower     Trace slow syscalls
    topscalls       Top system calls by number of calls
    topscalls_time  Top system calls by time

    Category: Security
    ------------------
    list_login_shells
                    List the login shell IDs
    shellshock_detect
                    print shellshock attacks
    spy_users       Display interactive user activity

    Category: System State
    ----------------------
    lscontainers    List the running containers
    lsof            List (and optionally filter) the open file descriptors.
    netstat         List (and optionally filter) network connections.
    ps              List (and optionally filter) the machine processes.

    Use the -i flag to get detailed information about a specific chisel

<br/>

    # sysdig -pc -c lscontainers
    container.type container.image container.name      container.id
    -------------- --------------- ------------------- ------------
    docker         debian          fervent_hoover      ab4082d2b4fc

<br/>

    # sysdig -c topcontainers_cpu
    # sysdig -pc -c topcontainers_cpu
    # sysdig -pc -c topprocs_net

    # sysdig -pc -c topprocs_cpu
    # sysdig -pc -c topprocs_cpu container.name contains myapp # вместо myapp общее название для нескольких контейнеров
