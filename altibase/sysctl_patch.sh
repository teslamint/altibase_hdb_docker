#!/bin/bash

echo '# Controls the default maxmimum size of a mesage queue
kernel.msgmnb = 65536
# Controls the maximum size of a message, in bytes
kernel.msgmax = 65536
# Controls the maximum shared segment size, in bytes
kernel.shmmax = 68719476736000
# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 4294967296
fs.suid_dumpable = 1
fs.aio-max-nr = 1048576
fs.file-max = 6815744
# semaphores: semmsl, semmns, semopm, semmni
kernel.sem = 1024 32000 1024 1024
net.ipv4.ip_local_port_range = 32768 61000
net.core.rmem_default = 4194304
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
# core filename pattern (core.execution_file_name.time)
kernel.core_uses_pid = 0
kernel.core_pattern = core.%e.%t
' | tee -a /etc/sysctl.conf
