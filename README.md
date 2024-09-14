
[Ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html) is an open-source automation tool used for configuration management, application deployment, and task automation. It simplifies complex IT operations by allowing you to define infrastructure as code. Ansible operates without requiring agents on remote systems, making it lightweight and easy to deploy.

### Key Features of Ansible

- **Agentless**: No need to install software on client machines.
- **Declarative**: You describe the desired state of the systems, and Ansible ensures that state is achieved.
- **Modules**: Tasks in Ansible are executed using modules, which are reusable scripts that handle specific tasks (like installing software, managing services, etc.).
- **Playbooks**: These are [YAML](https://www.w3schools.io/file/yaml-introduction/) files, defining tasks and configurations to automate operations.

Ansible is commonly used in DevOps environments for automating infrastructure management, provisioning cloud resources, and orchestrating software updates across multiple servers.

The cool thing about Ansible is that it is an __agentless__ automation tool that you install on a single host (referred to as the control node). For me that's my iMac, were I installed Ansible like so: ```brew install ansible```

Ansible will create a hidden `.ansible` folder in your home directory, but I don't think I'm taking advantage / using it at all. Instead I'm using an `ansible.cfg` file, stored at a project's root-level, as well as a `requirements.yaml` file.

Ansible has the notion of an **inventory**, which is a list of the machines (or "hosts") that Ansible manages. The inventory can be as simple as a plain text file, listing IP addresses or hostnames, or it can be more complex, dynamically generated from cloud platforms or other sources.

### Types of Inventories:
- **Static Inventory**: A predefined list of hosts stored in a file (usually `hosts` or `inventory`). Hosts can be grouped together, which makes it easier to target specific sets of machines.
- **Dynamic Inventory**: Instead of a static list, the inventory is generated dynamically using scripts or cloud APIs. This is useful when managing resources in dynamic environments like AWS, Azure, or GCP.

### My Static Inventory:
Maybe a little unexpected, but I'm looking at ansible just like another VSCode project, so I have this folder on my iMac `~/VSCodeProjects/ansible`. My _inventory_ is a simple `hosts.yaml` file, which looks something like this (simplified and shorted version):

```yaml
all:
  vars:
    ansible_connection: ssh
    ansible_user: wolf
    key_file=/home/wolf/: ssh/id_rsa
    timezone: America/Phoenix

  hosts:
    alpha: # Intel Core i5-425 CPU 1.3 GHz, 16 GB RAM, 256 GB SSD
      ansible_host: 192.168.200.16
      hostname: alpha.techcasitaproductions.com

    gamma: # Raspberry Pi 5 BCM2712 Quad-Core 64-bit Arm Cortex-A76 CPU 2.4GHz, 8 GB RAM, 256 GB SSD
      ansible_host: 192.168.200.18
      hostname: gamma.techcasitaproductions.com
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

### Variables 
Besides storing globale varables in the `hosts.yaml` file, ansible can discover a lot about a host by itself and those variable can be used when writing playbook.  
For example, with my `hosts.yaml` file setup, this command shows information about the Raspberry Pi 5: `ansible gamma -m ansible.builtin.setup`

### Syntax check, linting, and dry-run

- `ansible-playbook ./playbooks/set_timezone.yaml --sytax-check`
- `ansible-lint ./playbooks/set_timezone.yaml`
- `ansible-playbook foo.yml --check` 

allows to try a playbook, without making any changes on remote systems. E.g. trying out setting the timezone on all hosts mentioned in `hosts.yaml` file would look like this:

```text
PLAY [Set timezone] 

TASK [Gathering Facts] 
ok: [alpha]
ok: [gamma]

TASK [Set tz] 
ok: [alpha]
ok: [gamma]

PLAY RECAP 
alpha                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
gamma                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

### Playbooks

The _playbooks_ folder contains a few more _"manuals"_ to perform essential tasks, like

- Installing [Docker](https://www.docker.com) : ./playbooks/setup_docker.yaml
- Installing [Portainer](https://www.portainer.io) : ./playbooks/setup_portainer.yaml
- Installing [WatchTower](https://containrrr.dev/watchtower/) : ./playbooks/setup_watchtower.yaml

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

##### ./paybooks/docker_all_in.yaml

```yaml
#
# Running the playbooks in sequence
#
- name: Running the playbook setting the time zone
  ansible.builtin.import_playbook: set_timezone.yaml
- name: Running the playbook installing docker etc
  ansible.builtin.import_playbook: setup_docker.yaml
- name: Runningun the playbook installing portainer
  ansible.builtin.import_playbook: setup_portainer.yaml  
- name: Runningun the playbook installing watchtower
  ansible.builtin.import_playbook: setup_watchtower.yaml  
```

Running this playbook will 

- set the timezone
- install docker
- install portainer
- install watchtower

on all hosts in the _hosts.yaml_ file, and doing so in very little time.
