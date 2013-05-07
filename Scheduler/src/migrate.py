__author__ = 'Alexandra Mikhaylova mikhaylova.alexandra.a@gmail.com'

import objects


### VM migration implementation ###


# Returns true if migration was successful, else return false
def migrate(vm_id, ps_from_id, ps_to_id):
    ps_from = objects.find_ps(ps_from_id)
    ps_to = objects.find_ps(ps_from_id)
    if ps_from is None or ps_to is None:
        return False

    vm = ps_from.remove_vm(vm_id)
    if vm is None:
        return False

    ps_to.add_vm(vm)
    return True
