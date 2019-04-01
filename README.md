# Virtualbox Docker
Minimal Alpine virtual machine for running docker on non-linux hosts.

## Motivation
Performance.

### Performance comparison of volume mount within container

|benchmark |docker for mac|virtualbox (nfs)|
|--------- |         ---: |           ---: |
|git status|800ms         |40ms            |


## Installation
Prerequisites:
- Virtualbox
- Ansible
- `passlib`

Clone this repository:
```
git clone git@github.com:AGhost-7/vbox-docker
```

Run the install script in the repo:
```
./install.sh
```

And then you should be able to spin up the vm and log into it:
```
vbox-docker start
vbox-docker login
```

## Configuration
The configuration file is located in `~/.config/vbox-docker/config.yml`.
The following options are available:

```yaml
# How many cores the virtual machine will have of allocated
vm_cpus: 2
# How many MBs of RAM will be reserved for the virtual machine.
vm_memory: 1024
# Location of the workspace on the host machine.
nfs_client_workspace: "{{ansible_env.HOME}}/workspace-vbox"
# Image used for the development environment.
container_image: aghost7/nodejs-dev:bionic-carbon
```
