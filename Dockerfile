FROM ubuntu:18.04
MAINTAINER Michael Wetter <mwetter@lbl.gov>

##################################################
# Avoid warnings
# debconf: unable to initialize frontend: Dialog
# debconf: (TERM is not set, so the dialog frontend is not usable.)
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    ant=1.10.5-3~18.04 \
    g++=4:7.4.* \
    gfortran=4:7.4.0-1ubuntu2.3 \
    libgfortran3 \
    python3-pip \
    git \
    ipython3 \
    && \
    rm -rf /var/lib/apt/lists/*


RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -s /usr/bin/ipython3 /usr/bin/ipython

RUN pip3 install scipy
RUN pip3 install numpy
RUN pip3 install matplotlib
RUN pip3 install lxml
RUN pip3 install git+https://github.com/jpype-project/jpype/

# Install jcc-3.0 to avoid error in python -c "import jcc"
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-oracle

RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN export JCC_JDK=/usr/lib/jvm/java-8-openjdk-amd64

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    mkdir -p /etc/sudoers.d && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer

# Get Install Ipopt and JModelica, and delete source code with is more than 1GB large
ADD opt /opt
COPY opt/oct /opt/oct
COPY 0025900A8712.lic /home/developer/.modelon/
ENV MODELON_LICENSE_PATH /home/developer/.modelon

ENV PATH="/opt/oct/bin:${PATH}"

# Avoid warning that Matplotlib is building the font cache using fc-list. This may take a moment.
# This needs to be towards the end of the script as the command writes data to
# /home/developer/.cache
#RUN python3 -c "import matplotlib.pyplot"
