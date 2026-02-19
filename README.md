
[Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html) is an open-source automation tool used for configuration management, application deployment, and task automation. It simplifies complex IT operations by allowing you to define infrastructure as code. Ansible operates without requiring agents on remote systems, making it lightweight and easy to deploy.

### Key Features of Ansible

- **Agentless**: No need to install software on client machines.
- **Declarative**: You describe the desired state of the systems, and Ansible ensures that state is achieved.
- **Modules**: Tasks in Ansible are executed using modules, which are reusable scripts that handle specific tasks (like installing software, managing services, etc.).
- **Playbooks**: These are [YAML](https://www.w3schools.io/file/yaml-introduction/) files, defining tasks and configurations to automate operations.

Ansible is commonly used in DevOps environments for automating infrastructure management, provisioning cloud resources, and orchestrating software updates across multiple servers.

The cool thing about Ansible is that it is an __agentless__ automation tool that you install on a single host (referred to as the control node). You could install Ansible like so: ```brew install ansible``` but it is implemented in Python and needs several configuration files. I.e., turning this simply into a VSCode Projects seems to be the way to go.

## Kickoff 

- Create a new VSCode Project
- Create a virtual environment
- Pip install ansible
- Create an `ansible.cfg` file
- Create a `requirements.yml` file
- Create a `playbooks` directory
- Create an `inventory` directory
- Install the collection mentioned in the requirements.yml file: `$ ansible-galaxy install -r requirements.yml`

***ansible.cfg***

You can generate a fully commented-out example ansible.cfg file like so: `$ ansible-config init --disabled > ansible.cfg`

Here is the ansible.cfg that I'm currently using:
```text
[defaults]
home = ./.ansible
inventory = ./inventory/hosts.yml
host_key_checking = False
interpreter_python = auto_silent
collections_path = ./.ansible/collections
playbook_dir = ./playbooks

[persistent_connection]
ssh_type = paramiko # paramiko python ssh implementation
```

***requirements.yml***

```yaml
collections:
  - name: ansible.posix
  - name: community.general
  - name: community.docker
```
- [ansible.posix](https://docs.ansible.com/ansible/latest/collections/ansible/posix/index.html)
- [community.general](https://docs.ansible.com/ansible/latest/collections/community/general/index.html)
- [community.docker](https://docs.ansible.com/ansible/latest/collections/community/docker/index.html)

Ansible has the notion of an **inventory**, which is a list of the machines (or "hosts") that Ansible manages. The inventory can be as simple as a plain text file, listing IP addresses or hostnames, or it can be more complex, dynamically generated from cloud platforms or other sources.

### Types of Inventories:
- **Static Inventory**: A predefined list of hosts stored in a file (usually `hosts` or `inventory`). Hosts can be grouped together, which makes it easier to target specific sets of machines.
- **Dynamic Inventory**: Instead of a static list, the inventory is generated dynamically using scripts or cloud APIs. This is useful when managing resources in dynamic environments like AWS, Azure, or GCP.

### My Static Inventory:
Looking at ansible as just like another VSCode project, my `~/VSCodeProjects/ansible` project has an _inventory_ folder, containing a simple `hosts.yml` file, which looks something like this:

```yaml
all:
  vars: # global variables
    command_timeout: 60 
    ansible_connection: ssh
    ansible_user: wolf
    key_file: /home/wolf/.ssh/id_rsa
    timezone: America/Phoenix
    account_tag: ... # Cloudflare account tag
    domain: wolfpaulus.com

  hosts:
    alpha: # Intel Core i5-425 CPU 1.3 GHz, 16 GB RAM, 240 GB SSD
      hostname: alpha.{{ domain }}
      architecture: "{{ansible_architecture}}"
      cloudflared_pkg: cloudflared-linux-amd64.deb
      tunnel_name: ...
      tunnel_id: ...
      tunnel_secret: ...

    beta:  # Intel Core i3-321 CPU, 1.8 GHz, 16 GB RAM, 128 GB SSD
      hostname: beta.{{ domain }}
      architecture: "{{ansible_architecture}}"
      cloudflared_pkg: cloudflared-linux-amd64.deb
      tunnel_name: ...
      tunnel_id: ...
      tunnel_secret: ...

    gamma: # RPi 5 BCM2712 Arm Cortex-A76 64bit CPU, 2.4GHz, 8 GB RAM, 256 GB SSD
      hostname: gamma.{{ domain }}
      architecture: arm64
      cloudflared_pkg: cloudflared-linux-arm64.deb
      tunnel_name: ...
      tunnel_id: ...
      tunnel_secret: ...

    delta: # RPi 5 BCM2712 Arm Cortex-A76 64bit CPU, 2.4GHz, 16 GB RAM, 500 GB SSD
      hostname: delta.{{ domain }}
      architecture: arm64
      tunnel_name: ...
      tunnel_id: ...
      tunnel_secret: ...
```

I guess, by now, you already get the idea that Ansible does all its _"magic"_ via _ssh_. To make this all work, the hosts need to have [sshd](https://www.ssh.com/academy/ssh/sshd) installed and running. Moreover, the public key (id_rsa.pub), belonging to your id_rsa private key needs to be configured (in ~/.ssh/authorized_keys) on the remote hosts.

### Ansible Playbooks

__Declarative Programming__ is a paradigm in which developers specify *what* the program should accomplish, rather than *how* to accomplish it. The focus is on describing the desired result or state, and the underlying system determines the steps needed to achieve that result.

Ansible Playbooks are [YAML](https://www.w3schools.io/file/yaml-introduction/) files that define a set of tasks to be executed on managed hosts. These tasks can configure systems, deploy applications, and automate various IT tasks. Playbooks provide a __declarative__ way to orchestrate complex workflows with minimal scripting, focusing on the *what* rather than the *how.*

#### Key Concepts:

- **Tasks**: Individual actions executed on the managed hosts, like installing a package or modifying a file.
- **Modules**: Reusable Ansible code units that perform specific tasks (e.g., `apt`).
- **Handlers**: Triggered by tasks to run at the end of a play, often used for restarting services after configuration changes.
- **Variables**: Allow customization of tasks, enabling parameterization and reuse.
- **Roles**: Group related tasks, variables, and handlers, making playbooks more modular and reusable.

#### Example Playbook for setting the timezone
```yaml
- name: Set timezone
  hosts: all
  become: true
  tasks:
    - name: Set tz
      community.general.timezone:
        name: "{{ timezone }}"
```

### Variables 
Besides storing globale varables in the `hosts.yml` file, ansible can discover a lot about a host by itself and those variable can be used when writing playbook.  
For example, with my `hosts.yml` file setup, this command shows information about the Raspberry Pi 5: `ansible gamma -m ansible.builtin.setup`.


> To see all ansible's magic variables in one place, run this command: `ansible all -m setup > facts.json`

### Syntax check, linting, dry-run, and run

- `ansible-playbook --syntax-check ./playbooks/init.yml`
- `ansible-lint ./playbooks/init.yml`
- `ansible-playbook -C ./playbooks/init.yml`
- `ansible-playbook ./playbooks/init.yml`


Setting the timezone on all hosts mentioned in `hosts.yml` file would look like this:

```text
ansible-playbook ./playbooks/init.yml

PLAY [Set timezone] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [alpha]
ok: [gamma]
ok: [beta]
ok: [delta]

TASK [Set tz] ******************************************************************
ok: [alpha]
ok: [gamma]
ok: [beta]
ok: [delta]

PLAY RECAP *********************************************************************
alpha                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
beta                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
gamma                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
delta                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

If not all hosts are in the same timezone, a new variable set on that host can override the global value:

```yaml
all:
  vars:
    ansible_connection: ssh
    ansible_user: wolf
    key_file=/home/wolf/: ssh/id_rsa
    timezone: America/Phoenix

  hosts:
    alpha: # Intel Core i5-425 CPU 1.3 GHz, 16 GB RAM, 240 GB SSD
      hostname: alpha.wolfpaulus.com
      timezone: America/Denver
    
    beta:  # Intel Core i3-321 CPU, 1.8 GHz, 16 GB RAM, 128 GB SSD, Ubuntu 24.04.1 LTS
      hostname: beta.wolfpaulus.com      
```
### Playbooks

The _playbooks_ folder contains a few more _playbooks_ to perform essential tasks, like

- Installing [Docker](https://www.docker.com) : ./playbooks/setup_docker.yml
- Installing [Portainer](https://www.portainer.io) : ./playbooks/setup_portainer.yml
- Installing [WatchTower](https://watchtower.nickfedor.com/) : ./playbooks/setup_watchtower.yml

**Docker** is an open-source platform designed to automate the deployment, scaling, and management of applications in lightweight, portable containers. Containers allow developers to package applications along with all their dependencies (libraries, configurations, and binaries), ensuring consistent behavior across different environments.

##### Key Concepts in Docker

- **Containers**: Lightweight, standalone units that package an application and its dependencies. They can run on any environment that supports Docker, providing consistency across development, testing, and production environments.
  
- **Images**: Immutable templates that define the contents of a container. Images are built from Dockerfiles, which specify how to set up the environment, install dependencies, and run the application.

- **Dockerfile**: A script with instructions for building a Docker image, such as the base image, dependencies, and how to run the application.

- **Docker Hub**: A public repository where Docker images can be stored, shared, and downloaded.

- **Volumes**: Persistent storage that can be attached to containers, allowing data to persist even if a container is removed or stopped.

##### Why Use Docker?

- **Portability**: Docker containers can run on any machine with Docker installed, regardless of the underlying OS.
  
- **Efficiency**: Containers are more lightweight than virtual machines because they share the host system’s kernel, leading to faster startup times and lower resource consumption.

- **Consistency**: With containers, developers can ensure that an application will behave the same in every environment (development, testing, production).

- **Isolation**: Each Docker container runs in its own isolated environment, ensuring that applications don’t interfere with each other.

Docker is widely used in DevOps, continuous integration/continuous deployment (CI/CD) pipelines, microservices architecture, and cloud-based application development.

**Portainer** is a management UI that simplifies the process of managing Docker, Kubernetes, and other containerized environments. It provides an easy-to-use web interface, reducing the need to use the command line for container management.


##### Key Features of Portainer

- **User-Friendly Interface**: A graphical dashboard that makes it easy to manage Docker and Kubernetes environments.
- **Container Management**: Create, start, stop, and remove containers with ease.
- **Image Management**: Pull, manage, and deploy images from Docker Hub or other registries.
- **Network and Volume Management**: Simplifies the management of networks and volumes for containers.
- **Container Logs and Stats**: Monitor container logs and resource usage such as CPU, memory, and storage.
- **Access Control**: Role-based access management for users and teams, ensuring secure operations.
- **Multi-Environment Support**: Manage multiple Docker hosts or Kubernetes clusters from a single Portainer instance.

Portainer is designed for both beginners and experienced users, making it easier to manage simple or complex container setups.

__Watchtower__ is a tool that automatically updates Docker containers when new versions of their images are available. It monitors running containers, checks for updated images, and seamlessly applies updates. This ensures that your containerized applications stay up to date with security patches, bug fixes, and new features.

##### How Watchtower Works

1. **Monitor Containers**: Watchtower continuously checks the Docker registry for updated image versions of your running containers.
2. **Pull New Images**: When it detects an update, Watchtower pulls the latest image from the registry.
3. **Recreate Containers**: It stops the running container, removes it, and recreates it using the updated image while preserving the original configurations (e.g., environment variables, volume mounts).
4. **Automatic Restart**: Once the updated container is running, the application resumes operations without manual intervention.

Watchtower is useful for automating updates in self-hosted environments, commonly for services like web apps, databases, and utility containers.

#### One Playbook to play them all
After experimenting with all the before mentioned playbooks and verifying that they all work, we can easily create a playbook the plays them all:

##### ./playbooks/docker_all_in.yml

```yaml
#
# Running the playbooks in sequence
#
- name: upgrade Ubuntu/Debian servers and reboot if needed
  ansible.builtin.import_playbook: update.yml
- name: Running the playbook setting the time zone
  ansible.builtin.import_playbook: init.yml
- name: Running the playbook installing docker etc
  ansible.builtin.import_playbook: setup_docker.yml
- name: Runningun the playbook installing portainer
  ansible.builtin.import_playbook: setup_portainer.yml  
- name: Runningun the playbook installing watchtower
  ansible.builtin.import_playbook: setup_watchtower.yml  
```

Running this playbook will 
- upgrade Debian servers and reboot if needed
- init set the timezone and installs essential packages
- install docker
- install portainer
- install watchtower

on all hosts in the _hosts.yml_ file, and doing so in very little time.

## Private Registries and Watchtower
This still needs some work. I'm using GHCR. If a repo is private, so is the container image. To pull a private image, you need to authenticate with the registry. This can be done by creating a `config.json` file with the necessary credentials and mounting it into the Watchtower container. The `config.json` file should contain the authentication details for your private registry.

Not totally automized but here is the quick and dirty way to do it:
After creating a PAT on GitHub, yes I store it in my host.yml file.
And after setting up the host with the docker_all_in.yml playbook, I can create the config.json file on the target host.
ssh into the target host and run the following command with the following content:
`docker login ghcr.io -u USERNAME_HERE --password-stdin`

This will create a config.json file in the ~/.docker directory on the target host, which contains the necessary authentication details for pulling images from the private registry. It will look something like this:


```json
{
  "auths": {
    "ghcr.io": {
      "auth": "..."}}}
```
... all nicely base64 encoded. Now we can mount this file into the Watchtower container, allowing it to pull private images from GHCR.

```yaml
  tasks:
    - name: Install Watchtower
      community.docker.docker_container:
        name: watchtower
        image: nickfedor/watchtower:latest
        labels:
          com.centurylinklabs.watchtower.enable: "true"
        state: started
        restart_policy: unless-stopped
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - /home/wolf/.docker/config.json:/config.json
```


### DCA
Here is another playbook: _setup_dca.yml_. This is a demo app that I install on some hosts found in the hosts.yml file.  
_DCA_ short for _Dollar Cost Average_ is a Github repo that comes with a pre-built docker image. This particular docker image is also a multi-platform image, built for the amd64 and arm64/v8 platforms. I.e., it can easly be deployed on "standard" X86 and Raspberry Pi 5 hardware.

```shell
ansible-playbook ./playbooks/setup_dca.yml
```

## Limiting Ansible playbooks
If a playbook is setup to run on all hosts, it can still be installed selectively, by creating a new inventory on the commandline. E.g.:

```shell
ansible-playbook ./playbooks/setup_dca.yml -i epsilon,
```

This would run the setup_dca.yml playbook on the epsilon host. __Notice the comma at the end!__ The inventory needs to be a list.

## Pulling a Docker Image from a Private Registry
If you want to pull a Docker image from a private registry, you can use the `community.docker.docker_login` module to authenticate with the registry before pulling the image. Here is an example playbook: 
[setup_app_retireetax.yml](./playbooks/setup_app_retireetax.yml)


### PAT
A Personal Access Token (PAT) is a secure way to authenticate with a service, such as GitHub, without using your password. It is a string of characters that grants specific permissions to access resources on the platform. PATs are often used for automation, scripting, and API access, allowing you to perform actions on behalf of your account without exposing your password.
1. To create a PAT for GitHub, follow these steps:
2. Log in to your GitHub account.
3. Go to your profile settings. (Not the repository settings, but your account settings)
4. Navigate to your GitHub Developer settings. (Bottom left corner)
5. Select Personal access tokens > Tokens (classic) > Generate new token (classic).
6. Give the token a descriptive note and set an expiration.
7. Specify the required permissions (scopes): select the read:packages scope (and read:org if the image belongs to an organization).
8. Click Generate token and copy the token immediately; you will not be able to see it again


## Ansible Docker Container vs Docker Compose
*community.docker.docker_container vs community.docker.docker_compose_v2*

If an application already provides with a pre-built Docker Compose file, it's often easier to use just that. I use this approach, deploying a MySQL container.

```yaml title="setup_mysql.yml"
- name: Setup mysql_db
  hosts: beta
  become: true
  tasks:
    - name: Copy Docker Compose files
      ansible.builtin.template: # using Ansible's template modules instead of copy!
        src: ./compose/mysql.yml
        dest: ./docker-compose.yml
    - name: Start docker compose project
      community.docker.docker_compose_v2:
        project_src: ./
        files:
          - docker-compose.yml
```

After replacing variables with their values, this will copy the `./compose/mysql.yml` file to target host(s) and name it `docker-compose.yml`.
Next it will execute the file on the target. E.g.:

```yaml title="mysql.yml"
services: # This Docker Compose YAML deploys a MySQL database container.
  mysql_db:
    container_name: mysql-db # Name of the container
    image: mysql # Official MySQL image from Docker Hub
    labels:
      com.centurylinklabs.watchtower.enable: "true"
    network_mode: host # Container uses host's network directly
    hostname: localhost
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_HOST="%" # Allow connections from any host
      - MYSQL_ROOT_PASSWORD={{ mysql_root_pw }}
      - MYSQL_DATABASE={{ mysql_db }}
      - MYSQL_USER={{ mysql_user }}
      - MYSQL_PASSWORD={{ mysql_pw }}
    volumes:
      - ./volumes/mysql-mnt:/var/lib/mysql    

```


# Cloudflare
Follow the fist couple of steps [here](https://wolfpaulus.com/flare) to create _Tunnel Name_, _ID_, and _Secret_

E.g.: .. on the iMac
- brew install cloudflared
- rm -rf ~/.cloudflared
- cloudflared tunnel login (selecting the retireetax.com domain)
- cloudflared tunnel create alpha (naming the tunnel after the hostname)

Now we have: 
- ~/.cloudflared/cert.pem which goes into ./certs/alpha.pem
- and from ~/.cloudflared/{tunnel_id}.json. we store the tunnel_id and tunnel_secret in the host inventory.

Running the setup_cloudflare playbook will install cloudflared, end put files into /etc/cloudflared. The tunnel will not start until the cnames and ingress rules are setup.
...


```yaml
alpha: 
  domain: 
  hostname: 
  architecture: 
  cloudflared_pkg: cloudflared-linux-..
  tunnel_name: alpha
  tunnel_id: ...tunnel_id...
  tunnel_secret: ...tunnel_secret...
```
we can run the following playbook:
setup_cloudflare.yml
There is no route setup to the tunnel will not start.


```shellansible

1. The *setup_cloudflare* playbook, is used to install cloudflared, tunnel credentials, and certificates on the hosts.
2. The *setup_cnames* playbook is used to create the cnames on Cloudflare and connect the cname to a tunnel.
  - I always create at least two per host: _host name_ and _ssh-host name_. I.e. if epsilon is the hosthame and foo.com the domain, then _epsilon.foo.com_ and _ssh-epsilon.foo.com_ would be registered in the DNS
3.  Finally the *setup_ingress_rules* playbook will create the ingress rules on cloudflare.  Everytime an ingress rules is changed or added, the playbook needs to be re-run. 

> Please Note: The tunnel will only work after running all three playbooks: setup_cloudflare, setup_cnames, setup ingress_rules. The final step of the 3rd playbook will restart the cloudflared service, resulting in a __healthy__ tunnel status.

## Ingress Rules
Ingress rules map cnames to ports. The cloudflared service, running on the host, receives an incoming request, and tries to find a [maching ingress rule](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/configuration-file/).

E.g. this ingress rule for epsilon:
```yaml
- hostname: wordgame.{{ domain }}  # CNAME wordgame needs to be configured in Cloudflare/DNS
  service: http://localhost:8001   # wordgame server 8001 -> 443
- hostname: ssh-{{ hostname }}     # CNAME ssh-{hostname} needs to be configured in Cloudflare/DNS
  service: ssh://localhost:22      # must be proxied using cloudflared on the client
- hostname: mysql.{{ domain }}     # CNAME mysql needs to be configured in Cloudflare/DNS
  service: tcp://localhost:3306    # must be proxied using cloudflared on the client  
- service: http_status:404  
```

Only http/https connections can be made from the public internet directly. **Everything else need to proxied.** 
While this is now considered [legacy](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/), I still find simply installing cloudflared on a client computer the easiest way to [ssh into a host](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/ssh-cloudflared-authentication/). 
E.g., with cloudflared installed, I only need to add this to my `~/.ssh/config` to ssh into `ssh-epsilon`:

```yaml
Host ssh-epsilon
    HostName ssh-epsilon.wolfpaulus.com
    User wolf
    Port 11
    ProxyCommand cloudflared access ssh --hostname %h
    IdentityFile ~/.ssh/id_rsa
```

### MySQL Server

Maybe you spotted this above:

```yaml
- hostname: mysql.{{ domain }}     # CNAME mysql needs to be configured in Cloudflare/DNS
  service: tcp://localhost:3306    # must be proxied using cloudflared on the client  
```  

Yes, this is a MySQL server running on epsilon, well it's running inside a docker-container. Still, the question is how can we access it?
Once again, I still find simply installing cloudflared on a client computer the easiest way to access the MySQL server.

E.g.: running this command on a client computer:

```shell
cloudflared access tcp -T mysql.wolfpaulus.com -L 127.0.0.1:3306
```

allows you to connect to the remote MySQL server mapped to localhost.
