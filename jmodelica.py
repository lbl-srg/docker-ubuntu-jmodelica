##########################################################################
# Script to simulate Modelica models with JModelica.
#
##########################################################################
# Import the function for compilation of models and the load_fmu method
from pymodelica import compile_fmu
import traceback
import logging

from pyfmi import load_fmu
import pymodelica

def _simulate(model):
    import os
#    import matplotlib.pyplot as plt

    fmu_name = compile_fmu(model,
                           version="2.0",
                           compiler_log_level='error',
                           compiler_options = {"generate_html_diagnostics" : False})

    # Load model
    mod = load_fmu(fmu_name, log_level=3)

    opts = mod.simulate_options() #Retrieve the default options
    opts['logging'] = False
    opts['solver'] = 'CVode'
    opts['ncp'] = 500
    opts['CVode_options']['atol'] = 1.0e-6 #Options specific for CVode
    opts['CVode_options']['rtol'] = 1.0e-6 #Options specific for CVode

    res = mod.simulate(options=opts)
#        logging.error(traceback.format_exc())

#    plt.plot(res['time'], res['line2.y'])
#    plt.xlabel('time in [s]')
#    plt.ylabel('line2.y')
#    plt.grid()
#    plt.savefig("plot.pdf")


if __name__=="__main__":
    from multiprocessing import Pool
    import multiprocessing

    # Increase memory
    pymodelica.environ['JVM_ARGS'] = '-Xmx4096m'

    models = [
      "Buildings.Controls.OBC.CDL.Continuous.Validation.LimPID",
      "Buildings.Controls.OBC.CDL.Continuous.Validation.Limiter"
    ]
    # Number of parallel processes
    if len(models) == 1:
        _simulate(models[0])
    else:
        nPro = multiprocessing.cpu_count()
        nPro = 20
        po = Pool(nPro)
        po.map(_simulate, models)
