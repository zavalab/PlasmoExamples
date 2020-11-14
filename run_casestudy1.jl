#NOTE: define n_parts, max_imbalance, and n_processes
##################################################
n_parts = 7    #NOTE: Julia acts as one of the workers
max_imbalance = 0.1
n_processes = 2
##################################################
using Distributed
using MPIClusterManagers

manager=MPIManager(np=n_processes)
addprocs(manager)  # start mpi workers and map them to julia workers

#Setup the worker environments
println("Activating package environment on workers...")
@everywhere using Pkg
@everywhere Pkg.activate(@__DIR__)
@everywhere using Plasmo
@everywhere using PipsSolver

using LightGraphs
using KaHyPar

println("\nRunning Gas Network Case Study\n")
include("case_studies/gasnetwork/partition_and_solve.jl")

#Write out the graph file which can be used for visualization
include("case_studies/gasnetwork/write_graph_file.jl")
