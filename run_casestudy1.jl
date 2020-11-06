#NOTE: define n_parts, max_imbalance, and n_processes
##################################################
n_parts = 8
max_imbalance = 0.1
n_processes = 2
##################################################

println("Activating Julia Environment")
using Pkg
Pkg.activate(@__DIR__)
using LightGraphs
using KaHyPar
using Plasmo


using Distributed
using MPIClusterManagers

if !(isdefined(Main,:manager))
    manager=MPIManager(np=n_processes)
    addprocs(manager)  # start mpi workers and map them to julia workers
end

#Setup the worker environments
@everywhere begin
    using Pkg
    println("Activating package environment on workers...")
    Pkg.activate(@__DIR__)
    using Plasmo
    using PipsSolver
end

println("\nRunning Gas Network Case Study\n")
include("case_studies/gasnetwork/partition_and_solve.jl")
