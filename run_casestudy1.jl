#NOTE: define n_parts, max_imbalance, and n_processes
##################################################
n_parts = 8
max_imbalance = 0.1
n_processes = 2
##################################################
using Distributed
using MPIClusterManagers

if !(isdefined(Main,:manager))
    manager=MPIManager(np=n_processes)
    addprocs(manager)  # start mpi workers and map them to julia workers
end

#Setup the worker environments
println("Activating package environment on workers...")
@everywhere using Pkg
@everywhere Pkg.activate(@__DIR__)
@everywhere using Plasmo
@everywhere using PipsSolver

using LightGraphs
using KaHyPar
using Plasmo

println("\nRunning Gas Network Case Study\n")
include("case_studies/gasnetwork/partition_and_solve.jl")
