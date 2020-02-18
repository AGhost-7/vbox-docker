import yaml
from sys import environ
from os import path

import json
import shutil
from ansible.module_utils.common.collections import ImmutableDict
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase
from ansible import context
import ansible.constants as C


class VboxDocker(object):
    def __init__(self):
        self.ssh_private_key = path.join(
            environ['HOME'], '.local.share/vbox-docker/key')
        self.ssh_user = 'vbox'
        self.config_path = path.join(
            environ['HOME'], '.config/vbox-docker/config.yml')
        self.extra_vars = {}

    def load_extra_vars(self):
        """Loads variables from the configuration file for ansible to use"""
        if path.exists(self.config_path):
            with open(self.config_path) as file:
                config = yaml.safe_load(file)
                for key in (
                        'vm_cpus',
                        'vm_memory',
                        'container_image',
                        'nfs_client_workspace'):
                    if key in config:
                        self.extra_vars[key] = config[key]

    def ssh(self):
        """Logs the user into the container host"""
        pass

    def login(self):
        """Logs the user into the primary development container"""
        pass

    def start(self):
        """Starts up the machine and provisions it if needed."""
        context.CLIARGS = ImmutableDict(connection='local', forks=0, become=None, become_user=None, check=False, become_method=None, diff=False)
        loader = DataLoader() 
        inventory = InventoryManager(loader=loader, sources='localhost')
        variable_manager = VariableManager(loader=loader, inventory=inventory)
        play_source = {
            'name': 'Ansible',
            'hosts': 'localhost',



    def stop(self):
        """Turns off the virtual machine"""
        pass

    def remove(self):
        """Destroy any data associated to the VM. Does not remove configuration
        files"""
        pass


def main():
    vbox = VboxDocker()
    vbox.start()

    pass
