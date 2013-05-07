__author__ = 'Alexandra Mikhaylova mikhaylova.alexandra.a@gmail.com'

import objects

FILENAME = "../data/test/test_objects"


def main():
    # Create servers
    ps1 = objects.Server()
    ps2 = objects.Server()
    assert ps1.id == 1
    assert ps2.id == 2

    # Fill the first server with VMs
    f = open(FILENAME, "r")
    for line in f:
        params = line.strip().split(" ")
        ps1.add_vm(objects.VM(name=params[0],
                              cpu=float(params[1]),
                              ram=int(params[2])))
    assert len(ps1.vm_list) == 5
    f.close()


if __name__ == "__main__":
    main()