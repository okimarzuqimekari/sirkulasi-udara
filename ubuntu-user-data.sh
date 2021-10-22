#cloud-config

repo_update: true
repo_upgrade: all
packages:
 - cloud-init
 - vim
 - nano
 - screen
 - rsync
 - wget
 - htop
 - bash-completion
 - libwww-perl
 - libdatetime-perl
 - net-tools
 - curl
 - apt-transport-https
 - lsb-release
 - gnupg2

output:
  all: '| tee -a /var/log/cloud-init-output.log'


groups:
  - ubuntu: [root,sys]
  - devops

# Create USER import pub key from github
# https://github.com/GITHUB-USERNAME.keys
users:
  - default
  - name: USERNAME-SYSTEM
    groups: [ devops ]
    sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
    shell: /bin/bash
    ssh_import_id:
    - gh:GITHUB-USERNAME

# Example runcmd
#runcmd:
#  - curl -so FILE.deb https://EXAMPLE.COM/FILE.deb && dpkg -i ./FILE.deb
#  - apt-get install FILE
#  - systemctl enable FILE --now
#  - systemctl start --no-block FILE

final_message: "The system is finally up, after $UPTIME seconds"
