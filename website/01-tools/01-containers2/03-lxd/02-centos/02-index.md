---
layout: page
title: Linux Containers (lxc) в Centos 6.5 x64
description: Linux Containers (lxc) в Centos 6.5 x64
keywords: DevOps, Linux Containers (lxc) в Centos 6.5 x64
permalink: /devops/containers/lxd/centos/
---

# Linux Containers (lxc) в Centos 6.5 x64

<pre>

##############################
### Создание моста

### Инсталляция необходимых пакетов

# yum install -y bridge-utils


### Настраиваем интерфейс, для работы с контейнером

# cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BRIDGE=br0
NM_CONTROLLED=no

EOF

<!--

# ifconfig eth0:0 192.168.1.10 up

-->

# cat > /etc/sysconfig/network-scripts/ifcfg-br0 << EOF
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.1.11
NETWORK=192.168.1.0
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DELAY=0
NM_CONTROLLED=no

EOF


# service network restart


# ifconfig br0
br0       Link encap:Ethernet  HWaddr 08:00:27:D3:AE:5C
          inet addr:192.168.1.11  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fed3:ae5c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13 errors:0 dropped:0 overruns:0 frame:0
          TX packets:17 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:958 (958.0 b)  TX bytes:2254 (2.2 KiB)



# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.08002774f2c7	no		eth0



##################################################


<strong>
При выключенном selinux возникают ошибки.
Если собирать libvirt из исходников, то также возникают ошибки.
</strong>

<br/>
Если найдете решение, как работать с LXC с выключенным selinux, поделитесь со мной и общественностью.


<strong>Включаю selinux</strong>


# sestatus
SELinux status:                 disabled


# sed -i.bkp -e "s/SELINUX=disabled/SELINUX=enforcing/g" /etc/selinux/config

=======================================================



<strong>Установка и настройка</strong>

# yum install -y \
libvirt \
libvirt-client \
python-virtinst

# chkconfig --level 345 libvirtd on
# service libvirtd restart

# chkconfig --level 345 cgconfig on
# service cgconfig restart

# mkdir -p /containers/centos/6/x86_64/test/etc/yum.repos.d/
# cat /etc/yum.repos.d/CentOS-Base.repo |sed s/'$releasever'/6/g > /containers/centos/6/x86_64/test/etc/yum.repos.d/CentOS-Base.repo

# yum groupinstall core -y --nogpgcheck --installroot=/containers/centos/6/x86_64/test/

# yum install -y --nogpgcheck  plymouth libselinux-python --installroot=/containers/centos/6/x86_64/test/


# yum install -y \
--nogpgcheck \
--installroot=/containers/centos/6/x86_64/test/ \
openssh-clients \
vim\
wget  \
bind-utils \
traceroute \
tcpdump \
screen \
telnet \
nc \
lsof \
git

========================================

# chroot /containers/centos/6/x86_64/test

# PS1='test:\w# '

test:/# passwd root

========================================

### Configuring basic networking

test:/# cat > /etc/sysconfig/network << EOF
NETWORKING=yes
HOSTNAME=lxc-test.localdomain

EOF



test:/# cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR=192.168.1.101
NETMASK=255.255.255.0
GATEWAY=192.168.1.11

EOF


test:/# cat > /etc/resolv.conf << END
# Google public DNS
nameserver 8.8.8.8
nameserver 8.8.4.4

END


test:/# chkconfig --level 345 sshd on
test:/# chkconfig --level 345 netfs off
test:/# chkconfig --level 345 postfix off
test:/# chkconfig --level 345 iptables off
test:/# chkconfig --level 345 ip6tables off


==========================================================

### Fix root login on console

test:/# echo "pts/0" >>/etc/securetty

test:/# sed -i s/"session    required     pam_selinux.so close"/"#session    required     pam_selinux.so close"/g /etc/pam.d/login

test:/# sed -i s/"session    required     pam_selinux.so open"/"#session    required     pam_selinux.so open"/g /etc/pam.d/login

test:/# sed -i s/"session    required     pam_loginuid.so"/"#session    required     pam_loginuid.so"/g /etc/pam.d/login

==========================================================

### Fixing root login for sshd

test:/# sed -i s/"session    required     pam_selinux.so close"/"#session    required     pam_selinux.so close"/g /etc/pam.d/sshd

test:/# sed -i s/"session    required     pam_loginuid.so"/"#session    required     pam_loginuid.so"/g /etc/pam.d/sshd

test:/# sed -i s/"session    required     pam_selinux.so open env_params"/"#session    required     pam_selinux.so open env_params"/g /etc/pam.d/sshd


==========================================================

test:/# exit



# cat /proc/mounts | grep cgroup
cgroup /cgroup/cpuset cgroup rw,relatime,cpuset 0 0
cgroup /cgroup/cpu cgroup rw,relatime,cpu 0 0
cgroup /cgroup/cpuacct cgroup rw,relatime,cpuacct 0 0
cgroup /cgroup/memory cgroup rw,relatime,memory 0 0
cgroup /cgroup/devices cgroup rw,relatime,devices 0 0
cgroup /cgroup/freezer cgroup rw,relatime,freezer 0 0
cgroup /cgroup/net_cls cgroup rw,relatime,net_cls 0 0
cgroup /cgroup/blkio cgroup rw,relatime,blkio 0 0


# reboot


==========================================================

Перед тем как выполнить следующую команду, рекомендую создать еще одну ssh сессию к серверу, т.к. сразу после выполнении команды, открывается консоль контейнера и тут же происходит дисконнект. Дальнейшие попытки подключиться к серверу по ssh могут не увенчаться успехом. После создания виртуальной машины и перезагрузки. Все работает нормально.

# virt-install \
--connect lxc:/// \
--name test \
--ram 1024 \
--noautoconsole \
--network bridge:br0 \
--autostart \
--accelerate \
--filesystem /containers/centos/6/x86_64/test/,/


-v, --hvm	Request the use of full virtualization, if both para & full virtualization are available on the host. This parameter may not be available if connecting to a Xen hypervisor on a machine without hardware virtualization support. This parameter is implied if connecting to a QEMU based hypervisor.

# reboot


# virsh -c lxc:/// list --all
 Id    Name                           State
----------------------------------------------------
 1428  test                           running



-- При необходимости запустить
# virsh --connect lxc:/// start test


# virsh -c lxc:/// dominfo test
Id:             1428
Name:           test
UUID:           343be2d0-d9d5-37a7-26ca-aea4c4c099f2
OS Type:        exe
State:          running
CPU(s):         1
CPU time:       2,4s
Max memory:     1048576 KiB
Used memory:    21232 KiB
Persistent:     yes
Autostart:      enable
Managed save:   unknown


# brctl show br0
bridge name	bridge id		STP enabled	interfaces
br0		8000.08002774f2c7	no		eth0
							veth0


# virsh -c qemu:///system iface-list
Name                 State      MAC Address
--------------------------------------------
br0                  active     08:00:27:74:f2:c7
lo                   active     00:00:00:00:00:00



### Подключение к контейнеру

# virsh --connect lxc:/// console test

CentOS release 6.5 (Final)
Kernel 2.6.32-431.3.1.el6.x86_64 on an x86_64

lxc-test login:


=====================================================
=====================================================
=====================================================

### Удаляю настройки сети по умолчанию:

vnet0 - сетевой интерфейс виртуальной машины без него сеть внутри машины работать не будет
virbr0 - создаётся при устаноке по умолчанию. Нужен если планируется использовать NAT.


Просматриваем список виртуальных сетей.

# virsh net-list
Name                 State      Autostart     Persistent
--------------------------------------------------
default              active     yes           yes



Отключаем сеть Default

# virsh -c lxc:/// net-destroy default
Network default destroyed


Удаляем сеть Default

# virsh -c lxc:/// net-undefine default
Network default has been undefined


=====================================================
=====================================================
=====================================================

</pre>

### Настраиваю маршрутизацию для работы LXC в конфигурации route-mode:

<br/>
<br/>

<div align="center">
	<img src="http://img.fotografii.org/images/network/Virtual_network_switch_in_routed_mode.png" border="0" alt="LXC network in routed mode">
</div>

<br/>
<br/>

Вот такая у меня сеть.<br/>
<br/>
Стенд собран для тестирования. Использовать для работы в такой конфигурации не планирую.
<br/>
<br/>

<div align="center">
	<img src="http://img.fotografii.org/images/network/mynetwork.png" border="0" alt="Network for LXC testing">
</div>

<pre>

ROUTER

На роутере добавил статический маршрут:

Destination IP Address: 192.168.1.101
IP Subnet Mask: 255.255.255.0
Gateway IP Address:  192.168.1.11


<strong>HOST</strong>

# echo 1 > /proc/sys/net/ipv4/ip_forward



-- Опционально: можно улучшить быстродействие соединения bridge, поправив настройки в /etc/sysctl.conf

# cat >> /etc/sysctl.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF



<strong>LXC</strong>


[root@lxc-test ~]# ping -c 2 ya.ru
PING ya.ru (213.180.193.3) 56(84) bytes of data.
64 bytes from www.yandex.ru (213.180.193.3): icmp_seq=1 ttl=55 time=2.87 ms
From 192.168.1.11: icmp_seq=2 Redirect Host(New nexthop: 192.168.1.1)
64 bytes from www.yandex.ru (213.180.193.3): icmp_seq=2 ttl=55 time=1.56 ms

--- ya.ru ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1057ms
rtt min/avg/max/mdev = 1.563/2.218/2.874/0.657 ms


===================

Пинг до компьютера в локальной сети не проходит.

[root@lxc-test ~]# ping -c 3 192.168.1.6
PING 192.168.1.6 (192.168.1.6) 56(84) bytes of data.
From 192.168.1.101 icmp_seq=1 Destination Host Unreachable
From 192.168.1.101 icmp_seq=2 Destination Host Unreachable
From 192.168.1.101 icmp_seq=3 Destination Host Unreachable

--- 192.168.1.6 ping statistics ---
3 packets transmitted, 0 received, +3 errors, 100% packet loss, time 3008ms
pipe 3


===================

-- вот уж не подумал бы, что нужно прописывать такой маршрут. т.к. GW и так указан как 192.168.1.11
[root@lxc-test ~]# route add -net 192.168.1.0/24 gw 192.168.1.11

[root@lxc-test ~]# ping -c 3 192.168.1.6
PING 192.168.1.6 (192.168.1.6) 56(84) bytes of data.
From 192.168.1.11: icmp_seq=2 Redirect Host(New nexthop: 192.168.1.6)
From 192.168.1.11: icmp_seq=3 Redirect Host(New nexthop: 192.168.1.6)

--- 192.168.1.6 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 12002ms



===================

<strong>CLIENT</strong>

root@notebook:~# route add -host 192.168.1.101 gw 192.168.1.1

root@notebook:~# ping -c 3 192.168.1.101
PING 192.168.1.101 (192.168.1.101) 56(84) bytes of data.
64 bytes from 192.168.1.101: icmp_req=1 ttl=63 time=1.30 ms
From 192.168.1.11: icmp_seq=2 Redirect Host(New nexthop: 192.168.1.101)
64 bytes from 192.168.1.101: icmp_req=2 ttl=63 time=3.91 ms
From 192.168.1.11: icmp_seq=3 Redirect Host(New nexthop: 192.168.1.101)
64 bytes from 192.168.1.101: icmp_req=3 ttl=63 time=1.27 ms

--- 192.168.1.101 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 1.272/2.163/3.917/1.240 ms


===================


<strong>LXC</strong>


[root@lxc-test ~]# ping -c 3 192.168.1.6
PING 192.168.1.6 (192.168.1.6) 56(84) bytes of data.
64 bytes from 95.31.31.8: icmp_seq=1 ttl=62 time=7.84 ms
From 192.168.1.11: icmp_seq=2 Redirect Host(New nexthop: 192.168.1.6)
64 bytes from 192.168.1.6: icmp_seq=2 ttl=62 time=6.77 ms
From 192.168.1.11: icmp_seq=3 Redirect Host(New nexthop: 192.168.1.6)
64 bytes from 95.31.31.8: icmp_seq=3 ttl=62 time=17.2 ms

--- 192.168.1.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2026ms
rtt min/avg/max/mdev = 6.772/10.618/17.241/4.703 ms


===========================================


###### Проверка ping, чтобы понять в чем проблема.
Что с пакетами и т.д.

### GUEST

# tcpdump -n -vvv -i eth0

### HOST


# tcpdump -n -vvv -i br0 src host 192.168.1.101
# tcpdump -n -vvv -i br0 src host 192.168.1.6

### CLIENT

# tcpdump -n -vvv -i eth0 src host 192.168.1.101

########

# tcpdump -nlUevvp -i any arp or icmp

===========================================



### Я отключал iptables на HOST. Если не отлючать, то чтобы сеть работала, нужно добавить правило.

-- Делаем настройки в iptables, чтобы трафик виртуалок «ходил» через соединение типа bridge

# iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
# service iptables save
# service iptables restart


</pre>

<!--

root@notebook:~# route add -host 192.168.1.101 gw 192.168.1.11
или ?
root@notebook:~# route add -host 192.168.1.101 gw 192.168.1.1

На маршрутизаторе прописать


=======================

iptables -A FORWARD -i eth1 -o eth2 -s 192.168.1.0/24 -d 192.168.2.0/24 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -s 192.168.2.0/24 -d 192.168.1.0/24 -j ACCEPT


=======================

# cat /etc/sysconfig/network-scripts/route-eth0
10.0.0.0/22 via 192.168.1.1 dev eth0


echo "ip route add 192.168.1.101 via 192.168.1.11 dev br0" >> /etc/sysconfig/network-scripts/route-br0

-->

<!--


    bridging work at link layer ("ethernet level") -- and so configuring a bridge between two interfaces is mostly like wiring them through a (virtual) switch
    forwarding work at network layer ("IP level") -- and so configuring forwarding between two interfaces is like connecting them through a (virtual) router



=====================================================


 ip route flush cache
ip link set dev br0 promisc on
ip link set dev eth0 promisc on
ip link set dev virbr0 promisc on



=====================================================

На каком-нибудь linux клиенте в сети добавляю маршрут:
route add -host 192.168.1.101 gw 192.168.1.11



### HOST
route add -host 192.168.1.101 dev br0

=====================================================


# service iptables start


iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT



### Настройка сети




=====================================



# sysctl -p /etc/sysctl.conf
# service libvirtd reload


ip route add 192.168.1.101 via 192.168.1.11 dev br0



### На клиентах
route add -host 192.168.1.21 gw 192.168.1.11


tcpdump -n -vv -i eth1 icmp

$ ping 192.168.1.21


-->

<!--
### Настройка сетевых интерфейсов на хосте

# cat > /etc/libvirt/qemu/networks/network.xml <<EOF
<network>
  <name>network</name>
  <uuid>d2b6aa94-98c8-4528-ba72-e10bc9600fde</uuid>
  <forward dev='eth0' mode='route'>
    <interface dev='eth0'/>
  </forward>
  <bridge name='virbr0' stp='on' delay='0' />
  <mac address='52:54:00:9D:CA:A5'/>
  <ip address='192.168.1.100' netmask='255.255.255.0'>
  </ip>
</network>

EOF


# virsh -c lxc:/// net-define /etc/libvirt/qemu/networks/network.xml
# virsh -c lxc:/// net-start network
# virsh -c lxc:/// net-autostart network

# virsh  -c lxc:/// net-list


# service libvirtd reload


# ip neigh
192.168.1.5 dev br0 lladdr bc:ae:c5:30:13:a5 REACHABLE
192.168.1.202 dev br0 lladdr 08:00:27:77:78:15 STALE
192.168.1.6 dev br0 lladdr 94:39:e5:74:e0:a8 REACHABLE
192.168.1.50 dev br0  INCOMPLETE
192.168.1.201 dev br0 lladdr 08:00:27:d7:46:8e STALE
192.168.1.1 dev br0 lladdr 40:4a:03:6a:fb:f8 REACHABLE
192.168.1.20 dev br0  FAILED


-->

<pre>

### Логи

# less /var/log/libvirt/libvirtd.log
# less /var/log/libvirt/lxc/test.log


### Данные контейнера

#  virsh -c lxc:/// dumpxml test


-- Если нужно внести изменения
#  virsh -c lxc:/// edit test

=====================================================
=====================================================
=====================================================


Еще есть проект создания виртуального свича (openvswitch). Возможно, что в ближайшем будущем он будет использоваться как стандарт для создания виртуальных контейнеров и машин. Но пока я даже не смог его скомпилировать у себя.

(Кривые руки + нужны библиотеки кторорые нужно также компилить, которые ссылаются на другие и сообщения об ошибках, которое лично мне ничего не говорят).

</pre>

<pre>

<strong>Почитать:</strong>
http://wiki.centos.org/HowTos/LXC-on-CentOS6
http://wiki.1tux.org/wiki/Centos6/Installation/Minimal_installation_using_yum
http://wiki.1tux.org/wiki/Lxc/Installation/Guest/Centos/6

Ключи создания контейнера
http://www.techotopia.com/index.php/Installing_a_KVM_Guest_OS_from_the_Command-line_%28virt-install%29


Управление виртуальными машинами с помощью virsh
http://docs.fedoraproject.org/ru-RU/Fedora/12/html/Virtualization_Guide/chap-Virtualization_Guide-Managing_guests_with_virsh.html


http://www.cyberciti.biz/faq/kvm-virtualization-in-redhat-centos-scientific-linux-6/



Virtual Networking
http://wiki.libvirt.org/page/VirtualNetworking

http://blog.gadi.cc/routed-subnet-libvirt-kvm/
http://blog.gadi.cc/single-ip-routing-in-libvirt/


Настройка публичного ip адреса для виртуальных машин под управлением гипервизора KVM
http://openadmins.ru/blog/kvm-network-iptables


Траблшутинг:
http://linuxforum.ru/viewtopic.php?id=33307
http://linuxforum.ru/viewtopic.php?id=34269
</pre>
