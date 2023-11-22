# Dockerfile for JModelica

This docker file is used for the regression testing
of the [Modelica Buildings library](https://github.com/lbl-srg/modelica-buildings) and
of the [Modelica IBPSA library](https://github.com/lbl-srg/modelica-buildings).

The docker image can be downloaded from
[https://hub.docker.com/repository/docker/lbnlblum/ubuntu-1804_jmodelica_trunk/general](https://hub.docker.com/repository/docker/lbnlblum/ubuntu-1804_jmodelica_trunk/general)

To simulate a model, put the `jm_ipython.sh` file on your system's PATH variable
and run from a directory that contains `jmodelica.py` the command
```
jm_ipython.sh jmodelica.py Buildings.Utilities.Psychrometrics.Examples.DewPointTemperature
```
This will search on the `MODELICAPATH` for the model `Buildings.Utilities.Psychrometrics.Examples.DewPointTemperature`
and simulate it. The first time this command is executed, it will download the docker image.

For interactive simulation, add the `-i` flag.

Open the file `jmodelica.py` to see options for diagnostics and debugging.
