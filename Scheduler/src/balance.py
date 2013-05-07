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
    return []


## Logically implement load balancing ##
def balance(migration_map):
    for action in migration_map:
        if not migrate.migrate(action[0], action[1], action[2]):
            print "PANIC!"


## Periodically check and update ##
def load_poll():
    return