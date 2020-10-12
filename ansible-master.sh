export ANSIBLE_HOST_KEY_CHECKING=false
ansible-playbook -i inventory.yml -u vagrant playbook-master.yml
