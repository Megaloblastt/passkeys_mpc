# passkeys_mpc

`passkeys_mpc` is a demo project showcasing how to integrate **FIDO2/WebAuthn** registration and authentication using **Multi-Party Computation (MPC)**. It leverages Fireblocks' `mpc-lib` to perform secure **Key Generation** and **ECDSA Signature** operations, allowing credential handling without exposing private key material.

This project adapts:
- [`softfido`](https://github.com/ellerh/softfido) – emulating a FIDO2 authenticator in software
- [`SoftHSMv2`](https://github.com/softhsm/SoftHSMv2) – for PKCS#11-based credential storage
- Fireblocks' `mpc-lib` – to perform MPC-based cryptographic operations

> ✅ The demo interacts with [Yubico’s WebAuthn demo server](https://demo.yubico.com/webauthn-technical/registration) to showcase FIDO registration and login.

---

## 🔧 Build Instructions

### Prerequisites

- `cmake` (>= 3.14)
- `gcc` / `clang` with C++17 support
- `make`
- `git`
- Fireblocks' `mpc-lib` (you’ll need access to it)
- `libtool`, `autoconf`, `automake`
- Development libraries: `libssl-dev`, `libsqlite3-dev`, etc.

### Clone and Build

```bash
git clone https://github.com/Megaloblastt/passkeys_mpc.git
cd passkeys_mpc

git submodule init
git submodule update --recursive
```

### Build mpc-lib
Clone and build Fireblocks' mpc-lib:

```bash
git clone https://github.com/fireblocks/mpc-lib.git
cd mpc-lib
mkdir build && cd build
cmake ..
make -j$(nproc)
cd ../..
```

After building `mpc-lib`, set the following environment variables to point to the library and include directories:
```bash
export MPC_LIB_BUILD_LIB=</full/path/to>/mpc-lib/build/src/common
export MPC_LIB_INCLUDE=</full/path/to>/mpc-lib/include
```
Example:
```bash
export MPC_LIB_BUILD_LIB=$HOME/dev/passkeys_mpc/mpc-lib/build/src/common
export MPC_LIB_INCLUDE=$HOME/dev/passkeys_mpc/mpc-lib/include
```

And make sure `MPC_LIB_BUILD_LIB` is included in your `LD_LIBRARY_PATH`
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MPC_LIB_BUILD_LIB
```

For more detailed instructions, refer to the official [mpc-lib build guide](https://github.com/fireblocks/mpc-lib).


### Build the SoftHSMv2 module
```
./build_softhsm.sh
```

### Install the SoftHSMv2 module (will ask for sudo password)
```
./install_softhsm.sh
```
On Linux machines, it will install it under `/usr/local/lib/softhsm`, so make sure it's included into your `LD_LIBRARY_PATH` too.

### Create a token for the Fido Client
```
softhsm2-util --init-token --slot 0 --label "softfido"
```

You will be prompted to choose a user PIN, and SO (aka Security Officer) PIN. Make sure to remember them!

### Build the FIDO client
```bash
./build_softfido.sh
```

# Running the demo

## Start the FIDO client

```
./softfido/target/debug/softfido --token-label softfido
```

## Attach a virtual USB to it (might require sudo)

```
modprobe vhci-hcd
usbip attach -r 127.0.0.1 -d 1-1
```

## Register on Yubikey's demo server
Go to https://demo.yubico.com/webauthn-technical/registration and click the green `NEXT` button.  You will be promted to allow the FIDO client to access to the request.

You will see in the log of the FIDO client colorized outputs depending on which cosigner is doing what.

You can customize colors by modifying the following map `passkeys_mpc/SoftHSMv2/src/lib/crypto/OSSLMPCECDSA_mpclib_wrapper.h::colorized_outputs`

# Troubleshooting