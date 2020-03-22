# -*- coding: utf-8 -*-
# vim: ft=sls

# Keep BPF JIT compiler disabled
#net.core.bpf_jit_enable:
#  sysctl.present:
#    - value: 0

# Restrict access to dmesg
kernel.dmesg_restrict:
  sysctl.present:
    - value: 1

## Prevent TOCTOU vulnerabilities
fs.protected_hardlinks:
  sysctl.present:
    - value: 1

fs.protected_symlinks:
  sysctl.present:
    - value: 1

#Hide kernel symbol addresses
kernel.kptr_restrict:
  sysctl.present:
    - value: 1

#### ipv4 networking ####

## source address verification (sanity checking)
## helps protect against spoofing attacks
net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1

## disable ALL packet forwarding (not a router, disable it)
#net.ipv4.ip_forward:
#  sysctl.present:
#    - value: 0

## log martian packets
net.ipv4.conf.all.log_martians:
  sysctl.present:
    - value: 1

## ignore echo broadcast requests to prevent being part of smurf attacks
net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1

## optionally, ignore all echo requests
## this is NOT recommended, as it ignores echo requests on localhost as well
#net.ipv4.icmp_echo_ignore_all:
#  sysctl.present:
#    - value: 1

## ignore bogus icmp errors
net.ipv4.icmp_ignore_bogus_error_responses:
  sysctl.present:
    - value: 1

## IP source routing (insecure, disable it)
net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0

## send redirects (not a router, disable it)
net.ipv4.conf.all.send_redirects:
  sysctl.present:
    - value: 0

## ICMP routing redirects (only secure)
net.ipv4.conf.all.accept_redirects:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.secure_redirects:
  sysctl.present:
    - value: 1

# Enable IPv6 Privacy Extensions
net.ipv6.conf.all.use_tempaddr:
  sysctl.present:
    - value: 2

net.ipv6.conf.default.use_tempaddr:
  sysctl.present:
    - value: 2

# Network tuning

# Increase max connections
net.core.somaxconn:
  sysctl.present:
    - value: 1024

# Change TCP keepalive parameters
#net.ipv4.tcp_keepalive_time = 60
#net.ipv4.tcp_keepalive_intvl = 10
#net.ipv4.tcp_keepalive_probes = 6

# Enable MTU probing
net.ipv4.tcp_mtu_probing:
  sysctl.present:
    - value: 1


# VM and Filesystem tuning

# Contains, as a percentage of total system memory, the number of pages at which
# a process which is generating disk writes will start writing out dirty data.
vm.dirty_ratio:
  sysctl.present:
    - value: 3

# Contains, as a percentage of total system memory, the number of pages at which
# the background kernel flusher threads will start writing out dirty data.
vm.dirty_background_ratio:
  sysctl.present:
    - value: 2

# Reduce swappiness.
vm.swappiness:
  sysctl.present:
    - value: 1

# Favor filesystem caches.
vm.vfs_cache_pressure:
  sysctl.present:
    - value: 50

# Increase number of user inotify watches.
fs.inotify.max_user_watches:
  sysctl.present:
    - value: 524288

{% if grains['osarch'] != 'armv7l' %}

# Restrict ptrace scope
kernel.yama.ptrace_scope:
  sysctl.present:
    - value: 1

## TCP SYN cookie protection
## helps protect against SYN flood attacks
## only kicks in when net.ipv4.tcp_max_syn_backlog is reached
net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

## protect against tcp time-wait assassination hazards
## drop RST packets for sockets in the time-wait state
## (not widely supported outside of linux, but conforms to RFC)
net.ipv4.tcp_rfc1337:
  sysctl.present:
    - value: 1

## tcp timestamps
## + protect against wrapping sequence numbers (at gigabit speeds)
## + round trip time calculation implemented in TCP
## - causes extra overhead and allows uptime detection by scanners like nmap
## enable @ gigabit speeds
net.ipv4.tcp_timestamps:
  sysctl.present:
    - value: 0

# Increase the size of the receive queue
net.core.netdev_max_backlog:
  sysctl.present:
    - value: 100000

net.core.netdev_budget:
  sysctl.present:
    - value: 50000

net.core.netdev_budget_usecs:
  sysctl.present:
    - value: 5000

# Increase memory dedicated to the network interfaces
net.core.rmem_default:
  sysctl.present:
    - value: 1048576

net.core.rmem_max:
  sysctl.present:
     - value: 16777216

net.core.wmem_default:
  sysctl.present:
    - value: 1048576

net.core.wmem_max:
  sysctl.present:
    - value: 16777216

net.core.optmem_max:
  sysctl.present:
    - value: 65536

net.ipv4.tcp_rmem:
  sysctl.present:
    - value: 4096 1048576 2097152

net.ipv4.tcp_wmem:
  sysctl.present:
    - value: 4096 65536 16777216

# Increase UDP limits
net.ipv4.udp_rmem_min:
  sysctl.present:
    - value: 8192

net.ipv4.udp_wmem_min:
  sysctl.present:
    - value: 8192

# TCP Fast Open
net.ipv4.tcp_fastopen:
  sysctl.present:
    - value: 3

# Tweak pending connection handling
net.ipv4.tcp_max_syn_backlog:
  sysctl.present:
    - value: 30000

net.ipv4.tcp_max_tw_buckets:
  sysctl.present:
    - value: 2000000

net.ipv4.tcp_tw_reuse:
  sysctl.present:
    - value: 1

net.ipv4.tcp_fin_timeout:
  sysctl.present:
    - value: 10

net.ipv4.tcp_slow_start_after_idle:
  sysctl.present:
    - value: 0


{% endif %}
