---
layout: post
title:  "Nftables set with CIDR"
date:   2019-07-05 18:10:00 +1000
categories: jekyll update
---

A few weeks back I decided to try running a system with nftables as it's firewall, with no iptables, and with docker. This proved successful, but only after hunting through various blogs, man pages and wikis to put it together.  The complete result of this I will publish at another time, but one of the issues I had, which I've just now come back to and solved was how to include CIDR notation into a named set.

By default if a set appears to expect single addresses only, and loading the table would fail.

This is outlined by the error recieved when trying to load a set containing a cidr or range specification:

```
Jul 07 18:19:37 debian nft[24557]: /etc/nftables.conf:22:54-58: Error: Set member cannot be prefix, missing interval flag on declaration
```

It turns out I was missing a crucial piece - the `interval` flag. This is documented in the man page, and the sets page of the [nftables wiki](https://wiki.nftables.org/wiki-nftables/index.php/Sets) so I should have seen it earlier, it goes to show that when you've been at something for a while, give it a break and come back to it, an answer may be very close to you.

The following is an example using a named set to whitelist [Uptime Robot](https://uptimerobot.com/locations) primary IPs. Really these should also be whitelisted only for the port you need, this is just here as an example.


```
#!/usr/sbin/nft -f
define uptimerobot_dallas_1 = 69.162.124.224/28
define uptimerobot_dallas_2 = 63.143.42.240/28
define uptimerobot_dallas_3 = 216.245.221.80/28

flush ruleset

table inet filter {
  set uptimerobot {
    type ipv4_addr
    flags constant, interval
    elements = { $uptimerobot_dallas_1, $uptimerobot_dallas_2, $uptimerobot_dallas_3 }
  }
  chain base_checks {
    ct state {established, related} accept
    ct state invalid drop
    ip saddr @uptimerobot_ips accept
  }
  chain input {
  type filter hook input priority 0; policy drop;
  jump base_checks
  iifname lo accept
  ##Insert rules here
  drop
  }
}
```
