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
