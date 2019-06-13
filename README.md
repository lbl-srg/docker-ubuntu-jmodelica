# Dockerfile for JModelica

This docker file is used for the regression testing
of the [Modelica Buildings library](https://github.com/lbl-srg/modelica-buildings) and
of the [Modelica IBPSA library](https://github.com/lbl-srg/modelica-buildings).

The docker image can be downloaded from
[https://hub.docker.com/r/michaelwetter/ubuntu-1804_jmodelica_trunk](https://hub.docker.com/r/michaelwetter/ubuntu-1804_jmodelica_trunk)

To simulate a model, put the `jm_ipython.sh` file on your system's PATH variable
and run
```
jm_ipython.sh jmodelica.py Buildings.Controls.OBC.CDL.Continuous.Validation.LimPID
```
This will search on the `MODELICAPATH` for the model `Buildings.Controls.OBC.CDL.Continuous.Validation.LimPID`
and simulate it. The first time this command is executed, it will download the docker image.

For interactive simulation, add the `-i` flag.

Open the file `jmodelica.py` to see options for diagnostics and debugging.
