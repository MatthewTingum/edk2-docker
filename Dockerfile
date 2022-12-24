FROM debian:11.6

RUN apt-get update      \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        acpica-tools        \
        build-essential     \
        ca-certificates     \
        git                 \
        nasm                \
        python3             \
        uuid-dev            \
 && apt-get clean           \
 && rm -rf /var/lib/apt/lists/*

# python-is-python3
RUN ln -s $(which python3) /usr/bin/python

RUN git clone --recurse-submodules -j `nproc` https://github.com/tianocore/edk2.git \
  && cd edk2 \
  && git checkout edk2-stable202211

RUN cd edk2 \
  && make -j `nproc` -C BaseTools
  
# source edksetup.sh
ENV WORKSPACE="/edk2"
ENV EDK_TOOLS_PATH="/edk2/BaseTools"
ENV PATH="/edk2/BaseTools/BinWrappers/PosixLike:${PATH}"
ENV CONF_PATH="/edk2/Conf"
ENV EDK_TOOLS_PATH_BIN="/edk2/BaseTools/Bin/Linux-x86_64"
ENV PATH="/edk2/BaseTools/Bin/Linux-x86_64:${PATH}"
ENV OUTPUT_FILE="/edk2/Conf/BuildEnv.sh"
RUN cp /edk2/BaseTools/Conf/build_rule.template /edk2/Conf/build_rule.txt
RUN cp /edk2/BaseTools/Conf/tools_def.template /edk2/Conf/tools_def.txt
RUN cp /edk2/BaseTools/Conf/target.template /edk2/Conf/target.txt
ENV PYTHON_COMMAND="/usr/bin/python3"
