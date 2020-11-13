# PlasmoExamples
Example scripts that showcase core functionality of [Plasmo.jl](https://github.com/zavalab/Plasmo.jl).  This repository shows how to:
* Use optigraphs to create and solve hierarchical optimization models
* Solve a natural gas optimal control problem with [PipsSolver](https://github.com/zavalab/PipsSolver.jl),
* Solve a DC optimal power flow problem with [SchwarzSolver](https://github.com/zavalab/SchwarzSolver.jl)


## Requirements
* Julia 1.0.5
* PIPS-NLP with the ma57 linear solver. Use the [PIPS-NLP](https://github.com/Argonne-National-Laboratory/PIPS) installation instructions.
* A working MPI installation for PIPS-NLP.  The scripts in this repository have been tested with [mpich](https://www.mpich.org/downloads/) version 3.3.2
* Ipopt with the ma27 linear solver.  It is recommended to follow the [Ipopt](https://coin-or.github.io/Ipopt/INSTALL.html) installation instructions and install
the HSL codes as detailed in the instructions.


## Installation and Setup
The Julia packages needed to run the examples and case studies can be installed using the provided `Manifest.toml` file in this repository.  
To setup the necessary Julia environment, first clone the PlasmoExamples directory with:

```
git clone https://github.com/jalving/PlasmoExamples.git
```

Once cloned, navigate to the `PlasmoExamples` folder and begin a Julia REPL session as follows:

```
$ julia
julia> ]
(v1.0) pkg> activate .
(PlasmoExamples) pkg> instantiate
```
Note that you must type a `]` to enter the package management tool from a Julia session.

This will download the necessary Julia packages at the correct versions.  Notably, the `Manifest.toml` file downloads Plasmo at v0.3.0 (PipsSolver.jl does not yet support the latest v0.3.2),
and pins [MPI.jl](https://github.com/JuliaParallel/MPI.jl) to v0.12.0.  Newer versions of MPI.jl are not compatible with Julia 1.0.5 and mpich.

### Confirm MPI works
If using a custom installation of MPI (such as mpich), it is helpful to verify that [MPIClusterManagers.jl](https://github.com/JuliaParallel/MPIClusterManagers.jl)
works as intended for case study 1. The case study uses the contained manager object to setup worker MPI ranks interactively.

* After installing mpich, make sure the library and executable can be found using `$PATH` and `$LD_LIBRARY_PATH`
* Make sure `MPIClusterManagers.jl` is installed in the base Julia environment

```
julia> ]
(PlasmoExamples) pkg> build MPI
```

Now test the following code using 2 workers:
```
julia> using MPIClusterManagers
julia> using Distributed
julia> manager = MPIManager(np=2)
MPI.MPIManager(np=2,launched=false,mode=MPI_ON_WORKERS)
julia> addprocs(manager)
2-element Array{Int64,1}:
 2
 3
```
The output should return the worker ids of the newly added workers.  It may also show some deprecation warnings since we're using an older version of `MPIClusterManagers.jl`

## Running the Example Scripts
The example scripts can be run from a shell with the following command in PlasmoExamples directory:

```
$ julia run_examples.jl
```

This will run the 5 example scripts in the examples folder and create corresponding plots in `PlasmoExamples/examples/figures`. The example scripts perform the following:

* example1.jl creates a simple optigraph, solves it with GLPK, and plots the optigraph structure.
* example2.jl creates a hierarchical optigraph with a shared optiedge (linkconstraint), solves it with GLPK, and plots the optigraph structure.
* example3.jl creates a hierarchical optigraph with a shared optinode, solves it with GLPK, and plots the optigraph structure.
* example4.jl creates an optigraph for an optimal control model, partitions it with KaHyPar, and aggregates the resulting subgraphs into new optinodes.  This example
also creates plots for the optigraph structure corresponding to the original optigraph, the partitioned optigraph, and the aggregated optigraph.
* example5.jl builds on example4.jl and creates overlapping subgraphs.  It also plots the overlapping structure.

## Running Case Study 1
Case study 1 uses Plasmo.jl to model and partition a natural gas network optimal control problem and solve it with PIPS-NLP.
Notably, it uses `PipsSolver.jl` to distribute a partitioned optigraph among MPI ranks using `MPIClusterManagers.jl` and Julia's `Distributed` functionality.
The script can be run with the following command:

```
$ julia run_casestudy1.jl
```
The output should display various print statements that indicate the progress of the script.  The following messages should print to the console:
* A message about activating the package environment on the julia workers (the Julia workers map to MPI ranks).  
* The output of KaHyPar which partitions the problem.  
* A notification that the aggregated partitions are being distributed among the workers (ranks).
* The output of PIPS-NLP.

### Modifying parameters
This case study can also be run interactively which allows parameters to be changed.  Instead of running the script from a shell,
simple start a Julia session and execute the case study script as follows:

```
julia> include("run_casestudy1.jl")
```

## Running Case Study 2
Case study 2 solves a DC optimal power flow problem with `SchwarzSolver.jl`. The solver can take advantage of multiple threads set with the
`JULIA_NUM_THREADS` environment variable.  Since the case study partitions the problem into 4 partitions, it can benefit from up to 4 threads which solve
the subproblems in parallel.  The following commands can be used to set the number of threads and execute the case study:

```
$ export JULIA_NUM_THREADS=4
$ julia run_casestudy2.jl
```

### Modifying parameters

```
julia> include("run_casestudy1.jl")
```

## Other documentation
Documentation describing Plasmo.jl and its underlying functions can be found at the [github pages](https://zavalab.github.io/Plasmo.jl/dev/) site.
