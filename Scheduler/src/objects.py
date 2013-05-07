__author__ = 'Alexandra Mikhaylova mikhaylova.alexandra.a@gmail.com'

### Objects to be built ###


## ID generators ##


# On start #


VM_ID = 0
PS_ID = 0
PS_LIST = []


# Generators #


def next_vm_id():
    global VM_ID
    VM_ID += 1
    return VM_ID


def next_ps_id():
    global PS_ID
    PS_ID += 1
    return PS_ID


## Server finder ##


def find_ps(ps_id):
    global PS_LIST
    for ps in PS_LIST:
        if ps.id == ps_id:
            return ps
    return None


## VM representation ##


class VM:
    def __init__(self, name="", cpu=0.0, ram=0.0):
        self.id = next_vm_id()
        self.name = name
        self.cpu = cpu  # Floating point number
        self.ram = ram  # Integer

    def update(self, cpu, ram):
        self.cpu = cpu
        self.ram = ram


## Physical server representation ##


class Server:
    def __init__(self, vm_list=None):
        self.id = next_ps_id()
        if vm_list is None:
            self.vm_list = []
        else:
            self.vm_list = vm_list
        global PS_LIST
        PS_LIST.append(self)

    def find_vm(self, vm_id):
        for vm in self.vm_list:
            if vm.id == vm_id:
                return vm
        return None

    def add_vm(self, vm):
        self.vm_list.append(vm)

    # Returns VM if removal was successful, else return false
    def remove_vm(self, vm_id):
        for vm in self.vm_list:
            if vm.id == vm_id:
                self.vm_list.remove(vm)
                return vm
        return False