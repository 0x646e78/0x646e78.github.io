---
layout: post
title:  "Checking the security boundaries of a Linux process"
date:   2019-12-14 20:10:00 +1000
categories: jekyll update
---

I've been looking at the varius places to check the isolation of a Linux
Process.  There are various factors that contribute to the security
isolation of a process, which have been summarised well in this [post by Michiel Kalkman](https://michielkalkman.com/posts/isolation-modeling-001/).

I have also gathered these into a single script which is [here](blah).

For this exercise, I'll target  the `dockerd` process.

```
# pgrep dockerd
92019
```

## LSM Modules

    cat /sys/kernel/security/lsm



## SELinux

```
    getenforce
```

```
    ps -eZ | grep 92019 | cut -d" " -f1
```

## AppArmor

```
aa-status
```

## SecComp

```
grep Seccomp /proc/92019/status | cut -f2
```

## UID and GID

```
stat -c "%u,%g" /proc/92019
```

## chroot

```
readlink /proc/92019/root
```

## Namespaces

## Capabilities

```
getpcaps 92019
```