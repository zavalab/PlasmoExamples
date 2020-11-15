#NOTE: define n_parts, max_imbalance, and overlap
####################################
n_parts = 4          # number of partitions to partition the optigraph into
max_imbalance = 0.1  # maximum partition imbalance (0 to 1)
overlap = 10         # overlap distance (the distance each partition is expanded)
#NOTE: Use the environment variable JULIA_NUM_THREADS to set the number of threads before starting Julia. The Schwarz solver can make use of threads up to the number of partitions
###################################

#Activate the Julia environment in this repo if it hasn't already been activated
println("Activating Julia Environment")
using Pkg
Pkg.activate(@__DIR__)

#Run the case study
println("\nRunning DC OPF Case Study\n")
include("case_studies/dcpowergrid/partition_and_solve.jl")
