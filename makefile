DOCKER_USERNAME=michaelwetter
MAC_ADDRESS=00:25:90:0a:87:12

IMG_NAME=travis-ubuntu-1804-oct
OCT_VERSION=oct-r12473


NAME=${DOCKER_USERNAME}/${IMG_NAME}

COMMAND_RUN=docker run \
	  --name jmodelica \
	  --detach=false \
	  -e DISPLAY=${DISPLAY} \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
	  --rm \
	  -v `pwd`/shared:/mnt/shared \
	  ${DOCKER_USERNAME}/${IMG_NAME} /bin/bash -c


COMMAND_START=docker run \
	  --name jmodelica \
	  --detach=false \
	  --rm \
	  --interactive \
	  -t \
	  -v `pwd`/shared:/mnt/shared \
	  ${DOCKER_USERNAME}/${IMG_NAME} \
	  /bin/bash -c -i

DOCKER_FLAGS=\
	--mac-address=${MAC_ADDRESS} \
	--detach=false \
	--rm \
	--user=developer \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=${DISPLAY} \
	-v ${MODELICA_LIB}:/mnt/modelica_lib \
	-v `pwd`/shared:/mnt/shared \
	${NAME}

COMMAND_RUN=docker run ${DOCKER_FLAGS} /bin/bash -c

COMMAND_START=docker run -t --interactive ${DOCKER_FLAGS} /bin/bash -c -i

build:
	@echo Extracting ${OCT_VERSION}.tar.gz
	@rm -rf opt
	tar xzf ${HOME}/inst/modelon/${OCT_VERSION}.tar.gz
	mv opt/${OCT_VERSION} opt/oct
	cp ~/.modelon/0025900A8712.lic .
	@echo Building docker image ${NAME}
	docker build --no-cache --rm -t ${DOCKER_USERNAME}/${IMG_NAME} .
	rm 0025900A8712.lic
	rm -rf opt

verify: verify-buildings-master verify-buildings-spawn

#push:
#	docker push ${DOCKER_USERNAME}/${IMG_NAME}


verify-buildings-master:
	$(eval TMPDIR := $(shell mktemp -d -t tmp-ubuntu-jmodelica-verification-buildings-master-XXXX))
	@echo "Running Modelica Buildings Library verification in $(TMPDIR)"
	@echo "Setting path to include current directory that contains jm_ipython.sh"
	$(eval export PATH=$(shell pwd):${PATH})
	@echo "Exporting mac address for docker"
	$(eval export MAC_ADDRESS=${MAC_ADDRESS})
	cd ${TMPDIR} && git clone --depth 1 --recurse-submodules --quiet https://github.com/lbl-srg/BuildingsPy.git
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/lbl-srg/modelica-buildings.git
	$(eval PYTHONPATH := ${TMPDIR}/BuildingsPy:${TMPDIR}/modelica-buildings/Buildings/Resources/Python-Sources)
	cd ${TMPDIR}/modelica-buildings/Buildings && ../bin/runUnitTests.py --skip-verification -t jmodelica -n 44
	rm -rf ${TMPDIR}

verify-buildings-spawn:
	$(eval TMPDIR := $(shell mktemp -d -t tmp-ubuntu-jmodelica-verification-buildings-spawn-XXXX))
	@echo "Running Spawn verification in $(TMPDIR)"
	@echo "Setting path to include current directory that contains jm_ipython.sh"
	$(eval export PATH=$(shell pwd):${PATH})
	@echo "Exporting mac address for docker"
	$(eval export MAC_ADDRESS=${MAC_ADDRESS})
	cd ${TMPDIR} && git clone --depth 1 --recurse-submodules --quiet https://github.com/lbl-srg/BuildingsPy.git
	cd ${TMPDIR} && git clone --depth 1 --quiet -b issue1129_energyPlus_zone https://github.com/lbl-srg/modelica-buildings.git
	$(eval PYTHONPATH := ${TMPDIR}/BuildingsPy:${TMPDIR}/modelica-buildings/Buildings/Resources/Python-Sources)
	cd ${TMPDIR}/modelica-buildings/Buildings && ../bin/runUnitTests.py --skip-verification -t jmodelica -n 44 -s Buildings.Experimental.EnergyPlus
	rm -rf ${TMPDIR}

remove-image:
	docker rmi ${DOCKER_USERNAME}/${IMG_NAME}

start_bash:
	$(COMMAND_START) \
	   "export MODELICAPATH=/opt/oct/ThirdParty/MSL:. && \
            cd /mnt/shared && bash"

start_ipython:
	$(COMMAND_START) \
	   "export MODELICAPATH=/oct/ThirdParty/MSL:. && \
            cd /mnt/shared && \
	    /opt/oct/bin/jm_ipython.sh"

clean_output:
	rm `pwd`/shared/{*.txt,*.fmu}
