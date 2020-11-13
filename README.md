# PlasmoExamples
Example scripts that showcase core functionality of [Plasmo.jl](https://github.com/zavalab/Plasmo.jl).  This repository shows how to:
* use optigraphs to create and solve hierarchical optimization models
* solve a natural gas optimal control problem with [PipsSolver](https://github.com/zavalab/PipsSolver.jl),
* solve a DC optimal power flow problem with [SchwarzSolver](https://github.com/zavalab/SchwarzSolver.jl)


## Requirements

* Julia 1.0.5
* PIPS-NLP with the ma57 linear solver. Use the [PIPS-NLP](https://github.com/Argonne-National-Laboratory/PIPS) installation instructions.
* A working MPI installation for PIPS-NLP.  The scripts in this repository have been tested with [mpich](https://www.mpich.org/downloads/) version 3.3.2
* Ipopt with the ma27 linear solver.  It is recommended to follow the [Ipopt](https://coin-or.github.io/Ipopt/INSTALL.html) installation instructions and install
the HSL codes.


## Installation and Setup
The Julia packages needed to run the examples and case studies can be installed using the provided `Manifest.toml` file.  
To setup this repository, first clone the directory with:

```
git clone https://github.com/jalving/PlasmoExamples.git
```

Once cloned, navigate to the `PlasmoExamples` folder, begin a Julia REPL session, and execute the following commands:

```
julia> ]
(v1.0) pkg> activate .
(PlasmoExamples) pkg> instantiate
```

This will download the necessary Julia packages at the correct versions.  Notably, the included `Manifest.toml` file pins Plasmo to v0.3.0 (PipsSolver.jl has not yet updated to support v0.3.2),
and pins the [MPI.jl](https://github.com/JuliaParallel/MPI.jl) Julia MPI interface to v0.12.0.  Newer versions of MPI.jl are not compatible with Julia 1.0.5 and mpich.

### Confirm MPI functions
If using a custom installation of mpi (such as mpich), it is helpful to verify that the MPIClusterManagers.jl manager works as intended.

## Running Examples
The examples can be run from a shell with:

```
$ julia run_examples.jl
```

This will run 5 example scripts and create corresponding plots in `PlasmoExamples/examples/figures`.

## Running Case Study 1
Case study 1 uses Plasmo.jl to model and partition a gas network optimal control problem and solve it with PIPS-NLP.
Notably, it uses `PipsSolver.jl` to distribute a partitioned optigraph (created with Plasmo.jl) among MPI ranks using `MPIClusterManagers.jl` and Julia's `Distributed` functionality.
The script can be run with the following command:

'''
$ julia run_casestudy1.jl
'''
You should see various print statements that indicate the progress of the script.  They should show up in the following order:
* A message about activating the package environment on the julia workers (MPI ranks).  
* The output of of KaHyPar which partitions the problem.  
* A notification that

## Running Case Study 2

'''
$ julia run_casestudy2.jl
'''

## Other documentation
Documentation describing Plasmo.jl and its underlying functions can be found at the [github pages](https://zavalab.github.io/Plasmo.jl/dev/) site.
