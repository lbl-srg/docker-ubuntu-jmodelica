IMG_NAME=ubuntu-1804_jmodelica_trunk
DOCKER_REPONAME=lbnlblum

COMMAND_RUN=docker run \
	  --name jmodelica \
	  --detach=false \
	  -e DISPLAY=${DISPLAY} \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  --rm \
	  -v `pwd`/shared:/mnt/shared \
	  ${DOCKER_REPONAME}/${IMG_NAME} /bin/bash -c


COMMAND_START=docker run \
	  --name jmodelica \
	  --detach=false \
	  --rm \
	  --interactive \
	  -t \
	  -v `pwd`/shared:/mnt/shared \
	  ${DOCKER_REPONAME}/${IMG_NAME} \
	  /bin/bash -c -i

print_latest_versions_from_svn:
	svn log -l 1 https://svn.jmodelica.org/trunk
	svn log -l 1 https://svn.jmodelica.org/assimulo/trunk

build:
	docker build --no-cache --rm -t ${DOCKER_REPONAME}/${IMG_NAME} .

verify: verify-buildings-master verify-buildings-spawn verify-boptest


push:
	docker push ${DOCKER_REPONAME}/${IMG_NAME}


verify-buildings-master:
	$(eval TMPDIR := $(shell mktemp -d -t tmp-ubuntu-jmodelica-verification-buildings-master-XXXX))
	@echo "Running Modelica Buildings Library verification in $(TMPDIR)"
	cd ${TMPDIR} && git clone --depth 1 --recurse-submodules --quiet https://github.com/lbl-srg/BuildingsPy.git
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/lbl-srg/modelica-buildings.git
	$(eval PYTHONPATH := ${TMPDIR}/BuildingsPy:${TMPDIR}/modelica-buildings/Buildings/Resources/Python-Sources)
	cd ${TMPDIR}/modelica-buildings/Buildings && ../bin/runUnitTests.py --skip-verification -t jmodelica -n 44
	rm -rf ${TMPDIR}

verify-buildings-spawn:
	$(eval TMPDIR := $(shell mktemp -d -t tmp-ubuntu-jmodelica-verification-buildings-spawn-XXXX))
	@echo "Running Spawn verification in $(TMPDIR)"
	cd ${TMPDIR} && git clone --depth 1 --recurse-submodules --quiet https://github.com/lbl-srg/BuildingsPy.git
	cd ${TMPDIR} && git clone --depth 1 --quiet -b issue1129_energyPlus_zone https://github.com/lbl-srg/modelica-buildings.git
	$(eval PYTHONPATH := ${TMPDIR}/BuildingsPy:${TMPDIR}/modelica-buildings/Buildings/Resources/Python-Sources)
	cd ${TMPDIR}/modelica-buildings/Buildings && ../bin/runUnitTests.py --skip-verification -t jmodelica -n 44 -s Buildings.Experimental.EnergyPlus
	rm -rf ${TMPDIR}

verify-boptest:
	$(eval PWD := $(shell pwd))
	$(eval TMPDIR := $(shell mktemp -d -t tmp-ubuntu-jmodelica-verification-boptest-XXXX))
	@echo "Running BOPTEST verification in $(TMPDIR)"
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/ibpsa/project1-boptest.git
	$(eval NEW_PYPA := ${TMPDIR}/project1-boptest)
	@echo "Silently try to remove the old image"
	cd ${TMPDIR}/project1-boptest/testing && make -s remove_jm_image 2> /dev/null | true
	@echo "Running BOPTEST CI tests, stdout and stderr redirected to verify-boptest.log"
	cd ${TMPDIR}/project1-boptest/testing && export PYTHONPATH=${NEW_PYPA} && make -s test_all > ${PWD}/verify-boptest.log 2>&1
	@echo "Silently try to remove the BOPTEST images"
	cd ${TMPDIR}/project1-boptest/testing && make -s remove_jm_image 2> /dev/null | true
	rm -rf ${TMPDIR}

remove-image:
	docker rmi ${DOCKER_REPONAME}/${IMG_NAME}

start_bash:
	$(COMMAND_START) \
	   "export MODELICAPATH=/usr/local/JModelica/ThirdParty/MSL:. && \
            cd /mnt/shared && bash"

start_ipython:
	$(COMMAND_START) \
	   "export MODELICAPATH=/usr/local/JModelica/ThirdParty/MSL:. && \
            cd /mnt/shared && \
	    /usr/local/JModelica/bin/jm_ipython.sh"

clean_output:
	rm `pwd`/shared/{*.txt,*.fmu}
