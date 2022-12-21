# Create Multipass Hosts

##### Requirements

- Multipass

### Create Host

```bash
$ multipass find
$ multipass launch -n HOSTNAME -m 2G -d 30G -c 2 jammy
```

Replace HOSTNAME with unique host name

### Open Shell

```bash
$ multipass shell HOSTNAME
```

### Start/Stop Host

```bash
$ multipass start [HOSTNAME]
$ multipass stop [HOSTNAME]
```

`HOSTNAME` is optional. If not specified it will start/stop all available instances
