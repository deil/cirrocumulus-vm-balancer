__author__ = 'Alexandra Mikhaylova mikhaylova.alexandra.a@gmail.com'

import const
import objects

### Cost functions ###


## VM cost functions ##


# Simple VM cost function, can later be expanded or changed
def vm_load_simple(vm):
    return vm.cpu + vm.ram


## Server cost functions ##


# Interface #


# vm_rm, vm_add -- modifications for a priori load calculation
def server_load(ps, vm_load_function=vm_load_simple, vm_rm=None, vm_add=None):
    res = 0 if vm_add is None else vm_load_function(vm_add)
    if vm_rm is not None:
        res -= vm_load_function(vm_rm)
    return reduce(lambda cur_res, vm: cur_res + vm_load_function(vm),
                  ps.vm_list,
                  res)


# Implementations #


# Simple server cost function
def server_load_simple(ps, vm_rm=None, vm_add=None):
    return server_load(ps, vm_rm=vm_rm, vm_add=vm_add)


# More sophisticated server cost function
def server_load_smooth(ps, vm_rm=None, vm_add=None):
    return 0    # TODO


## System cost functions ##


# Interfaces #

# Interface for mean squared error to be minimized for smoother servers load
# The first argument -- a load metric -- is a function of 3 arguments:
# ps -- physical server
# (optional) vm_rm -- VM suggested to remove
# (optional) vm_add -- VM suggested to add
def mse(server_load_impl, ps_from=None, ps_to=None, vm=None):
    p_mean_new = 0
    for ps in objects.PS_LIST:
        if ps == ps_from:
            p_mean_new += server_load_impl(ps, vm_rm=vm)
        elif ps == ps_to:
            p_mean_new += server_load_impl(ps, vm_add=vm)
        else:
            p_mean_new += server_load_impl(ps)
    p_mean_new /= float(const.SERVERS_N)

    res = 0
    for ps in objects.PS_LIST:
        if ps == ps_from:
            res += (server_load_impl(ps, vm_rm=vm) - p_mean_new) ** 2
        elif ps == ps_to:
            res += (server_load_impl(ps, vm_add=vm) - p_mean_new) ** 2
        else:
            res += (server_load_impl(ps) - p_mean_new) ** 2
    return res / float(const.SERVERS_N)


# Implementations #


# Simple implementation of the MSE interface
def mse_simple(ps_from=None, ps_to=None, vm=None):
    return mse(server_load_simple, ps_from=ps_from, ps_to=ps_to, vm=vm)