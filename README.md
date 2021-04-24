# Deploy Minecraft, with Ansible

This is an Ansible playbook that:

1. create an instance of the desired type using OVH API;
2. install a Minecraft server on it, alongside a list of required plugins that can be installed either from
   Spigot (using [Spiget](https://spiget.org/)), from a direct link to a JAR file, or from a repository that
   can be installed using `mvn clean install`;
3. start the server on the default port;
4. op listed players;
5. add a DNS record, so the server can be accessed.

The playbook is currently tided to the Zcraft DNS and OVH accounts but that may evolve in the future. There is not
so much to change to have fully-configurable zone, most is already configurable anyway, and everything will eventually
be added to the vault file.

## Create a server

To create a server, clone the repository, then run:

```bash
ansible-playbook playbook.yml --extra-vars="game=ktz dns=game-name" --ask-vault-pass
```

After a while, you'll be given the server IP and players will be able to join using `game-name.games.zcraft.fr` (or
other domain if that was modified).

The `game` var is a configuration file stored in `vars/games/<name>.yml`, containing what need to be done
on the server. See [`vars/games/ktz.yml`](vars/games/ktz.yml) for an example.

The `dns` var is the sub-domain of `games.zcraft.fr` that will be created for this game instance.

## Destroy a server

This playbook cannot delete the server, nor the associated DNS records. You have to do that yourself at the end of the
event, using the OVH Manager.
