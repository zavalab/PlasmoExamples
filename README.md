# PlasmoExamples
Example scripts that showcase the core functionality of [Plasmo.jl](https://github.com/zavalab/Plasmo.jl).  This repository shows how to:
* Use optigraphs to create and solve hierarchical optimization models
* Solve a natural gas optimal control problem with [PipsSolver](https://github.com/zavalab/PipsSolver.jl),
* Solve a DC optimal power flow problem with [SchwarzSolver](https://github.com/zavalab/SchwarzSolver.jl)


## Requirements
* Julia 1.0.5
* The GR plotting backend to create plots for the example scripts.
* PIPS-NLP with the ma57 linear solver. Use the [PIPS-NLP](https://github.com/Argonne-National-Laboratory/PIPS) installation instructions.
* A working MPI installation for PIPS-NLP.  The scripts in this repository have been tested with [mpich](https://www.mpich.org/downloads/) version 3.3.2
* Ipopt with the ma27 linear solver.  It is recommended to follow the [Ipopt](https://coin-or.github.io/Ipopt/INSTALL.html) installation procedure and install
the HSL codes as detailed in the instructions.


## Installation and Setup
The Julia packages needed to run the examples and case studies can be installed using the provided `Manifest.toml` file in this repository.  
To setup the necessary Julia environment, first clone the PlasmoExamples directory with:

```
git clone https://github.com/jalving/PlasmoExamples.git
```

Once cloned, navigate to the `PlasmoExamples` folder and begin a Julia REPL session. The necessary Julia dependencies can then be downloaded as follows:

```
$ julia
julia> ]
(v1.0) pkg> activate .
(PlasmoExamples) pkg> instantiate
```
Note that you must type a `]` to enter the Julia package management tool from the Julia REPL.
This snippet will download the necessary Julia packages at the correct versions.  Notably, the `Manifest.toml` tell Julia to download Plasmo.jl at v0.3.0 (PipsSolver.jl does not yet support the latest v0.3.2), and pins [MPI.jl](https://github.com/JuliaParallel/MPI.jl) to v0.12.0.  Newer versions of MPI.jl are not compatible with Julia 1.0.5 and mpich.

### Confirm MPI works
If using a custom installation of MPI (such as mpich), it is helpful to verify that [MPIClusterManagers.jl](https://github.com/JuliaParallel/MPIClusterManagers.jl)
works as intended for case study 1. The case study uses the `MPIManager` object to setup worker MPI ranks interactively from a Julia session. The following
setup has been found to be necessary to get the `MPIManager` working correctly.

1.) After installing mpich, make sure the library and executable can be found in the system path (i.e. by setting up `$PATH` and `$LD_LIBRARY_PATH` in your .bashrc file).  For instance, if
mpich is installed in `/home/user/app/mpich_install`, then the following need to be added to your .bashrc file:
* `export PATH="${PATH}:/home/mpc-linux-01/app/mpich-install/bin"`
* `export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/home/mpc-linux-01/app/mpich-install/lib"`

2.) Make sure `MPIClusterManagers.jl` is installed in the base Julia environment. We have found that the workers need to find a functional `MPIClusterManagers.jl` package to initialize without using a package environment.

3.) Once your MPI installation is installed, make sure to run the following code snippet in the package manager:

```
julia> ]
(PlasmoExamples) pkg> build MPI
```
This will rebuild the Julia MPI interface to use the library and executable found in the bash environment.

4.) Now try testing the following code using 2 workers:
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
The output should return the worker ids of the newly added workers.  It may also show some deprecation warnings since we're using an older version of `MPIClusterManagers.jl`.
We have found that most issues that arise with the `MPIClusterManagers` have to do with workers finding the wrong mpi libraries, or forgetting to rebuild the Julia interface.

## Running the Example Scripts
The example scripts can be run from a shell with the following command in the `PlasmoExamples` directory:

```
$ julia run_examples.jl
```

This will run the 5 example scripts in the examples folder and create corresponding plots in `PlasmoExamples/examples/figures`. The example scripts perform the following:

* example1.jl creates a simple optigraph, solves it with GLPK, and plots the optigraph structure.
* example2.jl creates a hierarchical optigraph with a shared optiedge (linkconstraint), solves it with GLPK, and plots the optigraph structure.
* example3.jl creates a hierarchical optigraph with a shared optinode, solves it with GLPK, and plots the optigraph structure.
* example4.jl creates an optigraph for an optimal control model, partitions it with KaHyPar, and aggregates the resulting subgraphs into new optinodes.  This example
also creates plots for the optigraph structure corresponding to the original optigraph, the partitioned optigraph, and the aggregated optigraph.
* example5.jl builds on example4.jl and creates overlapping subgraphs.  It also plots the overlapping graph structures.


## Running Case Study 1
Case study 1 uses Plasmo.jl to model and partition a natural gas network optimal control problem and solve it with PIPS-NLP.
Notably, it uses `PipsSolver.jl` to distribute a partitioned optigraph among MPI ranks using `MPIClusterManagers.jl` and Julia's `Distributed` functionality.
The script can be run with the following command:

```
$ julia run_casestudy1.jl
```
The output should display various print statements that indicate the progress of the script.  The most prominent messages that get printed to the console should include:
* A message about activating the package environment on the julia workers (the Julia workers map to MPI ranks).  
* The output of KaHyPar which partitions the problem.  
* A notification that the aggregated partitions are being distributed among the workers (ranks).
* The output of PIPS-NLP.

The case study also writes out `gas_network.csv` (a node-edge list) and `gas_network_attributes.csv` which can be used to visualize the optigraph structure in a graph visualization tool (such as Gephi).

### Modifying parameters
This case study can also be run interactively which allows parameters to be changed without restarting Julia (which requires recompiling).  Instead of running the script from a shell,
simply start a Julia session and execute the case study script as follows:

```
$ julia
julia> include("run_casestudy1.jl")
```
It is now possible to modify partitioning parameters in the `run_casestudy1.jl` script such as `n_parts`, `n_processes`, and `max_imbalance`.
It is also possible to scale the model size with `horizon`, `nt`, and `nx`. We recommend always
keeping `n_parts` the same as `n_processes`.  There have been reported issues with `PipsSolver.jl` and non-uniform sub-problem allocations.


## Running Case Study 2
Case study 2 solves a DC optimal power flow problem with `SchwarzSolver.jl`. The solver can take advantage of multiple threads set with the
`JULIA_NUM_THREADS` environment variable.  Since the case study partitions the problem into 4 partitions, it can benefit from up to 4 threads which solve
the sub-problems in parallel.  The following commands can be used to set the number of threads and execute the case study:

```
$ export JULIA_NUM_THREADS=4
$ julia run_casestudy2.jl
```

The output should be similar to case study 1 before hitting the solver.  You should see the following output printed to the console:
* A message about activating the Julia package environment.
* The output of KaHyPar which partitions the problem.
* A notification about the subproblems being created (which includes subgraph expansion)
* The output of SchwarzSolver.jl.  The solver prints the current objective function, primal feasibility, and dual feasibility at each iteration. By default, the solver runs for 100 iterations.

### Modifying parameters
Like the previous case study, it is possible to run interactively to avoid restarting Julia to test out different parameters.  Simply
start up a Julia session and use the following include statement:

```
$ julia
julia> include("run_casestudy2.jl")
```

It is now possible to modify partitioning parameters in the `run_casestudy2.jl` script such as `n_parts`, `imbalance`, and `overlap`. Keep in mind, that Julia
does not yet support changing the number of threads interactively, which requires setting the `JULIA_NUM_THREADS` environment variable and restarting the session.
We have also found that too many partitions does not always lead to convergence (we have tested up to 4 partitions) and this is possibly due to using using simple overlap schemes.

## Other documentation
Documentation describing Plasmo.jl and its underlying functions can be found at the [github pages](https://zavalab.github.io/Plasmo.jl/dev/) site.
The source code for v0.3.0 can be found at: [https://github.com/zavalab/Plasmo.jl/tree/v0.3.0](https://github.com/zavalab/Plasmo.jl/tree/v0.3.0).

### Overview of source code
The Plasmo.jl source code is defined by a few modules located at [https://github.com/zavalab/Plasmo.jl/tree/v0.3.0/src](https://github.com/zavalab/Plasmo.jl/tree/v0.3.0/src).
Here is a brief overview of the underlying modules:

* hypergraphs/hypergraph.jl - defines the `HyperGraph` type used for working with hypergraphs. Extends a `LightGraphs.AbstractGraph`.
* extras/kahypar.jl - defines a simple partition wrapper for KaHyPar if the package is found.  
* extras/plots.jl - defines special plots for Plasmo.jl if the `Plots.jl` package is found.
* combine.jl - contains functions to aggregate an optigraph into an optinode, or to aggregate optigraph subgraphs into optinodes.
* copy.jl - functions to copy objective and constraint expressions.  Used extensively for the aggregate functions defined in combine.jl.
* graph_functions.jl - defines functions to perform graph operations on an optigraph such as querying the neighborhood around a set of nodes or performing subgraph expansion.
* graph_interface.jl - currently only contains a function to generate a hypergraph object from an optigraph object.
* macros.jl - contains the Julia macros used to build optigraphs.
* optiedge.jl - defines the `OptiEdge` and `LinkConstraint` types, as well as functions that work on these types.
* optigraph.jl - defines the `OptiGraph` type, as well as functions that work on an optigraph.
* optinode.jl - defines the `OptiNode` type, as well as functions that work on optinodes.
* partition.jl - defines the `Partition` type which acts as an interface to partition an optigraph.  The `Partition` is used in the `make_subgraphs!` function to create subgraphs in an optigraph.
* solve.jl - extends JuMP.jl functions to solve an optigraph using JuMP compatible solvers.
* Plasmo.jl - imports and exports functions and defines abstract types.  Both the optigraph and optinode extend the `JuMP.AbstractModel` type.  This is what makes most of the JuMP macros work with Plasmo objects.
