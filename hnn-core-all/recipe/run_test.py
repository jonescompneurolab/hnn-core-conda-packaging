from hnn_core import jones_2009_model, MPIBackend, simulate_dipole

simulate_dipole(jones_2009_model(), tstop=20)

with MPIBackend(n_procs=2):
    simulate_dipole(jones_2009_model(), tstop=20)
