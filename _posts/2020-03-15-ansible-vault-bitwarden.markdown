---
layout: post
title:  "Ansible Vault key retrieval from Bitwarden'
date:   2020-03-08 10:10:00 +1000
categories: ansible
---

I use [Bitwarden](https://bitwarden.com/) as my password manager. It is really good and I highly recommend it. I also use Ansible a whole lot, and make heavy use of [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

I've recently started using [Invoke](http://www.pyinvoke.org/) as my orchestrator after [crgm](https://crgm.net/) suggested it, which has got me thinking more about streamlining my processes.
Today I hooked bitwarden into the mix. This is a first pass and can get a lot better (such as supporting multiple Vault IDs and adding retrieval of a sudo cred etc, but I'm happy with the result.

First up, I installed the [bitwarden cli](https://help.bitwarden.com/article/cli/). See their docs for install and login steps.

Once that is working and I found that I could retrieve a password, I configured my orchestration.

You can't just print the key in the command arguments to ansible-playbook. The available options are to provide a password file (`--vault-password-file`), or to have ansible ask for the key to be typed (`--ask-vault-pass`).
One could probably pipe the key in, but that feels pretty yucky to me, but not as yuk as writing cleartext creds to a file on disk. Fortunately `--vault-password-file` will also accept an executable that prints the key to stdout.

`vault-pass.py`:
```
#!/usr/bin/env python3

import subprocess

def get_vault_key(search='ansible vault key'):
    command = 'bw get password %s' % search
    key = subprocess.run(command.split(), check=True, stdout=subprocess.PIPE)
    return key.stdout.decode('utf-8')

print(get_vault_key())
```

`chmod u+x vault-pass.py`

And in invokes `tasks.py`:
```
from invoke import task

@task
def deploy(c, verbose=False):
    options = ''
    if verbose:
        options += ' -vvv'
    c.run('ansible-playbook play.yml -i inventory --ask-become-pass --vault-password-file vault-pass.py' + options)
```

Now I can run `invoke deploy` and not have to type the vault key. I want to get rid of the become password next, but will be focusing on moving this approach toward a python module and ansible-runner before then.
