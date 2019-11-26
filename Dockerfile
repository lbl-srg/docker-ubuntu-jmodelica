FROM ubuntu:18.04
MAINTAINER Michael Wetter <mwetter@lbl.gov>

##################################################
# Revision numbers from svn
# Get latest revision with
#
#  svn info https://svn.jmodelica.org/trunk | grep "Last Changed Rev:"
#  svn info https://svn.jmodelica.org/assimulo/trunk | grep "Last Changed Rev:"
# or
#  make print_latest_versions_from_svn

ENV REV_JMODELICA 14023
ENV REV_ASSIMULO 898
##################################################

# Set environment variables
ENV SRC_DIR /usr/local/src
ENV MODELICAPATH /usr/local/JModelica/ThirdParty/MSL

##################################################
# Avoid warnings
# debconf: unable to initialize frontend: Dialog
# debconf: (TERM is not set, so the dialog frontend is not usable.)
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install required packages
RUN apt-get update && \
    apt-get install -y \
    ant=1.10.5-3~18.04 \
    autoconf=2.69-11 \
    cmake=3.10.2-1ubuntu2.18.04.1 \
    cython=0.26.1-0.4 \
    g++=4:7.4.* \
    gfortran=4:7.4.0-1ubuntu2.3 \
    libgfortran3 \
    ipython=5.5.0-1 \
    libboost-dev=1.65.1.0ubuntu1 \
    openjdk-8-jdk=8u222-b10-1ubuntu1~18.04.1 \
    pkg-config=0.29.1-0ubuntu2 \
    python-dev=2.7.15~rc1-1 \
    python-jpype=0.6.2+dfsg-2 \
    python-lxml \
    python-matplotlib \
    python-nose \
    python-numpy=1:1.13.3-2ubuntu1 \
    python-pip=9.0.* \
    python-scipy=0.19.1-2ubuntu1 \
    subversion=1.9.7-4ubuntu1 \
    swig=3.0.12-1 \
    wget=1.19.4-1ubuntu2.2 \
    zlib1g-dev=1:1.2.11.dfsg-0ubuntu2 && \
    rm -rf /var/lib/apt/lists/*

# Install jcc-3.0 to avoid error in python -c "import jcc"
RUN pip install --upgrade pip
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-oracle
RUN pip install --upgrade jcc==3.5

RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN export JCC_JDK=/usr/lib/jvm/java-8-openjdk-amd64

# Get Install Ipopt and JModelica, and delete source code with is more than 1GB large
RUN cd $SRC_DIR && \
    wget wget -O - http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.4.tgz | tar xzf - && \
    cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Blas && \
    ./get.Blas && \
    cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Lapack && \
    ./get.Lapack && \
    cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Mumps && \
    ./get.Mumps && \
    cd $SRC_DIR/Ipopt-3.12.4/ThirdParty/Metis && \
    ./get.Metis && \
    cd $SRC_DIR/Ipopt-3.12.4 && \
    ./configure --prefix=/usr/local/Ipopt-3.12.4 && \
    make install && \
    cd $SRC_DIR && \
    svn export -q -r $REV_JMODELICA https://svn.jmodelica.org/trunk JModelica && \
    cd $SRC_DIR/JModelica/external && \
    rm -rf $SRC_DIR/JModelica/external/Assimulo && \
    svn export -q -r $REV_ASSIMULO https://svn.jmodelica.org/assimulo/trunk Assimulo && \
    cd $SRC_DIR/JModelica && \
    rm -rf build && \
    mkdir build && \
    cd $SRC_DIR/JModelica/build && \
    ../configure --with-ipopt=/usr/local/Ipopt-3.12.4 --prefix=/usr/local/JModelica && \
    make install && \
    make casadi_interface && \
    rm -rf $SRC_DIR

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

# Avoid warning that Matplotlib is building the font cache using fc-list. This may take a moment.
# This needs to be towards the end of the script as the command writes data to
# /home/developer/.cache
RUN python -c "import matplotlib.pyplot"
