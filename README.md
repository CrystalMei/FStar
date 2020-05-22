# ICFP 2020 Artifact

Name: SteelCore: An Extensible Concurrent Separation Logic for Effectful Dependently Typed Programs 

Authors: Nikhil Swamy, Aseem Rastogi, Aymeric Fromherz, Denis Merigoux, Danel Ahman, Guido Martinez 

## Artifact Instructions

This material contains the mechanized proofs for the model presented in the SteelCore paper.
More precisely, we implement here a version of our effectul CSL semantics complete with monotonic state, non-determinism and pre- and post-conditions.

### Installation (skip if using the VM)

All the development is done within the F\* proof assistant, which relies on the Z3 theorem prover
for semi-automated proofs.

The VM comes with F\* and all dependencies already installed.
If you are not using the VM, follow the steps below to setup a working environment.
The steps require a working OPAM setup. OCaml 4.05 to 4.09 should work.

1. Install all OPAM dependencies:
```sh
$ opam install ocamlbuild ocamlfind batteries stdint zarith yojson fileutils pprint menhir ulex ppx_deriving ppx_deriving_yojson process

```
Some of these packages depend on binary packages that you need to install locally. If you encounter such errors, you can use `depext` to install missing packages, for instance:
```sh
$ opam depext -i conf-gmp
```

2. Build F\* from the OCaml snapshot: `make -C src/ocaml-output -j6`

3. Extract the sources of F\* itself to OCaml: `make ocaml -C src -j6`

4. Install the Z3 SMT solver. We recommend you use the Everest tested binaries here: https://github.com/FStarLang/binaries/tree/master/z3-tested, commit hash 1a2c05b

5. Add FStar/bin and z3/bin to your PATH 

### Verification

You can verify any file by calling fstar.exe Module.fst(i).
You can verify the full development by calling `make -C ulib -B`.

### F\* overview

F\*, similarly to OCaml, distinguishes between interface files (`.fsti`) and implementation files (`.fst`).

Pragmas introduced by `#` are used to pass options controlling the SMT encoding and the behaviour of Z3.

The recommended way of scrolling/editing F\* files is through Emacs, using fstar-mode.
Full documentation can be found [online]<https://github.com/FStarLang/fstar-mode.el>, but most widely used key-bindings are C-c C-n for typechecking the next paragraph, and C-c C-RET to typecheck everything up to the current point.

## Code organization

All files relevant to the paper are in `ulib/experimental`. 
All the files in other folders are part of the F\* proof assistant,
ranging from the standard library in `ulib` to compiler code in `src`.

Please refer to Figure 1 of the paper for the dependency between modules.

The core semantics using indexed effectful action trees presented in Section 3, together with
their soundess proof, are available in `Steel.Semantics.Hoare.MST`. They build upon the `MST`
and `NMST` modules, which provide a model of monotonic state as described by Ahman et al. `MSTTotal` and `NMSTTotal` provide as an additional restriction that all functions are total.

`Steel.PCM` encodes partially commutative monoids into F\*, and is used by `Steel.PCM.Memory`
whose goal is to show a proof of concept of a generic memory model depending on an abstract PCM.
As stated by the paper, the rest of our implementation currently relies on a different memory
model that is specialized for the fractional permission PCM.

`Steel.Memory` and `Steel.Actions` define the SteelCore program logic presented in Section 4,
but specialized for the fractional permission PCM. `Steel.Memory` provides the definition of
our separation logic and its connectives, as well as our model of memory as a map from abstract
addresses to heap cells. `Steel.Actions` defines our stored invariants, as well as a variety
of standard actions.

`Steel.Semantics.Instantiate` then builds upon them to instantiate the State Typeclass
presented in section 3.0. `Steel.Memory.Tactics` instantiates the F\* canonical monoid tactic
with our separation logic terms to automate frame resolution.

`Steel.Effect` and `Steel.Effect.Atomic` build upon the SteelCore program logic defined in
`Steel.Memory` and `Steel.Actions` to define two monadic effects, encapsulating respectively
non-atomic and atomic computations.

These effects are then used to define the interface of the SteelCore Program Logic, in the form of a
set of libraries:
* `Steel.HigherReference` and `Steel.Reference` deal with memory references, storing respectively
  values of types contained in universe 1 and 0;
* `Steel.SteelAtomic.Basics` contains helper functions for programming in the
  `SteelAtomic` effect;
* `Steel.SteelT.Basics` contains helper functions for programming in a simplified version of the
   `Steel` effect where pre- and post- conditions are trivial.

Using these libraries, we present the implementation of the examples from section 5:
* `Steel.SpinLock` is the spinlock using CAS of 5.1;
* `Steel.Primitive.ForkJoin` is the fork/join parallelism structure of 5.2;
* `Steel.Channel.*` is the implementation of the simplex channels protocols of 5.3.

Finally, `MParIndex` contains the code presented in section 2 of the paper, which is only
there for presentation purposes and is not used in the `SteelCore` development.

## QEmu Instructions

The ICFP 2020 Artifact Evaluation Process is using a Debian QEmu image as a
base for artifacts. The Artifact Evaluation Committee (AEC) will verify that
this image works on their own machines before distributing it to authors.
Authors are encouraged to extend the provided image instead of creating their
own. If it is not practical for authors to use the provided image then please
contact the AEC co-chairs before submission.

QEmu is a hosted virtual machine monitor that can emulate a host processor
via dynamic binary translation. On common host platforms QEmu can also use
a host provided virtualization layer, which is faster than dynamic binary
translation.

QEmu homepage: https://www.qemu.org/

### Installation

#### OSX
``brew install qemu``

#### Debian and Ubuntu Linux
``apt-get install qemu-kvm``

On x86 laptops and server machines you may need to enable the
"Intel Virtualization Technology" setting in your BIOS, as some manufacturers
leave this disabled by default. See Debugging.md for details.


#### Arch Linux

``pacman -Sy qemu``

See https://wiki.archlinux.org/index.php/QEMU for more info.

See Debugging.md if you have problems logging into the artifact via SSH.


#### Windows 10
Download and install QEmu via the links on https://www.qemu.org/download/#windows.
Ensure that qemu-system-x86_64.exe is in your path.
Start Bar -> Search -> "Windows Features"
          -> enable "Hyper-V" and "Windows Hypervisor Platform".
Restart your computer.

#### Windows 8

See Debugging.md for Windows 8 install instructions.



### Startup

The base artifact provides a `start.sh` script to start the VM on unix-like
systems and `start.bat` for Windows. Running this script will open a graphical
console on the host machine, and create a virtualized network interface.
On Linux you may need to run with 'sudo' to start the VM. If the VM does not
start then check `Debugging.md`

Once the VM has started you can login to the guest system from the host using:

```
$ ssh -p 5555 artifact@localhost             (password is 'password')
```

You can also copy files to and from the host using scp, eg:

```
$ scp -P 5555 artifact@localhost:somefile .  (password is 'password')
```

The root account password is ``password``.

The default user is username:```artifact``` password:```password```.


### Shutdown

To shutdown the guest system cleanly, login to it via ssh and use:

```
$ sudo shutdown now
```


### Artifact Preparation

Authors should install software dependencies into the VM image as needed,
preferably via the standard Debian package manager. For example, to install
GHC and cabal-install, login to the host and type:

```
$ sudo apt update
$ sudo apt install ghc
$ sudo apt install cabal-install
```

If you really need a GUI then you can install X as follows, but we prefer
console-only artifacts whenever possible.

```
$ sudo apt-get install xorg
$ sudo apt-get install xfce4   # or some other window manager
$ startx
```

See Debugging.md for advice on resolving other potential problems,
particularly when installing the current version of Coq via opam.

If your artifact needs lots of memory you may need to increase the value
of the ```QEMU_MEM_MB``` variable in the ```start.sh``` script.

When preparing your artifact, please also follow the guidelines at:
 https://icfp20.sigplan.org/track/icfp-2020-artifact-evaluation#Forms-of-Artifacts

