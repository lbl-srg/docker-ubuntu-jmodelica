IMG_NAME=ubuntu-1604_jmodelica_trunk
DOCKER_USERNAME=michaelwetter

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

build:
	docker build --no-cache --rm -t ${DOCKER_USERNAME}/${IMG_NAME} .

push:
	docker push ${DOCKER_USERNAME}/${IMG_NAME}

verify-image:
	$(eval TMPDIR := $(shell mktemp -d -t ubuntu-jmodelica-verification-XXXX))
	@echo "Running verification in $(TMPDIR)"
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/lbl-srg/BuildingsPy.git
	$(eval PYTHONPATH := ${TMPDIR}/BuildingsPy)
	cd ${TMPDIR} && git clone --depth 1 --quiet https://github.com/lbl-srg/modelica-buildings.git
	cd ${TMPDIR}/modelica-buildings/Buildings && ../bin/runUnitTests.py -t jmodelica -n 16
	rm -rf ${TMPDIR}

remove-image:
	docker rmi ${DOCKER_USERNAME}/${IMG_NAME}

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
