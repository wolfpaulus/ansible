# TechCasitaProductions 

## Install collections into the collections_path, which is configured in ansible.cfg
ansible-galaxy collection install -r ./requirements.yaml

## Recommended Playboook Order 

1. set_timezone
1. setup_docker
    - The ansible_architecture value originally reported for then Raspberry Pi is `aarch64` which breaks the docker installation. Using `arm64` makes it work. I.e. Putting 
    `deb [arch=arm64] https://download.docker.com/linux/ubuntu noble stable` instead of `deb [arch=aarch64] https://download.docker.com/linux/ubuntu noble stable` into /etc/apt/sources.list.d/docker.list
1. setup_watchtower
1. setup_portainer

