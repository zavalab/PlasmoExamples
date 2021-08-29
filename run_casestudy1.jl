#NOTE: define n_parts, max_imbalance, and n_processes
##################################################
#partitioning data
n_parts = 3         #NOTE: Julia acts as one of the workers when using MPIManager
n_processes = 3
max_imbalance = 0.1

#NOTE: the number of spatial discretization points can be used to adjust problem size
nx = 3 #100              #number of space points per pipeline
include((@__DIR__)*"/case_studies/gasnetwork/gasnetwork.jl")
gas_network = create_gas_network_problem()
##################################################
using Distributed
using MPIClusterManagers
using KaHyPar
#remove previous julia workers if we ran this script before
if isdefined(Main,:manager)
    rmprocs(workers()...)
end
manager=MPIManager(np=n_processes)      # create an MPIManager with n_processes
addprocs(manager)                       # start mpi workers and map them to julia workers

#Setup the worker environments
println("Activating package environment on workers...")
@everywhere using Pkg
@everywhere Pkg.activate(@__DIR__)
@everywhere using Plasmo
@everywhere using PipsNLP

println("\nRunning Gas Network Case Study\n")
include("case_studies/gasnetwork/partition_and_solve.jl")

#Write out the graph file which can be used for visualization
include("case_studies/gasnetwork/write_graph_file.jl")
