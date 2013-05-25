__author__ = 'Alexandra Mikhaylova mikhaylova.alexandra.a@gmail.com'

import const
import load
import migrate
import objects


### Servers load balancing ###


## Checks and decision making ##


# Check simple system load
def check_mse_simple():
    if load.mse_simple() >= const.SIMPLE_MSE_THRESHOLD:
        print "PANIC!"


## Migration map building ##


# Helper function for building the optimal solution
# Result: lists of tuples (server_id, [vm_id_list])
def optimum():
    return []


# List of triples (vm_id, ps_from_id, ps_to_id) TODO make Action class
# Build using optimum
def build_migration_map():
    result = []
    for server_info in optimum():
        server = objects.find_ps(server_info[0])
        for vm_id in server_info[1]:
            if not server.find_vm(vm_id):
                result.append(())
        for vm_id in server.vm_list:
            if not vm_id in server_info[1]:
                result.append(())
    return result


## Logically implement load balancing ##
def balance(migration_map):
    for action in migration_map:
        if not migrate.migrate(action[0], action[1], action[2]):
            print "Migration error %i from %i to %i" % (action[0], action[1], action[2])


## Periodically check and update ##
def load_poll():
    return