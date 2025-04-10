#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd ${SCRIPT_DIR}/SoftHSMv2

[[ -d ${SCRIPT_DIR}/SoftHSMv2/build ]] || \
    (sh autogen.sh && \
        ./configure  --enable-ecc --disable-gost  --disable-eddsa --with-crypto-backend=openssl  && \
        mkdir ${SCRIPT_DIR}/SoftHSMv2/build && \
        cd ${SCRIPT_DIR}/SoftHSMv2/build && \
        cmake ..)

cd ${SCRIPT_DIR}/SoftHSMv2/build && make -j


