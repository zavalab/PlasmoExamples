using Plasmo, PlasmoPlots, Plots
using KaHyPar

#Create the optigraph which models a simple optimal control problem
include((@__DIR__)*"/create_dynamic_problem.jl")
graph = create_dynamic_problem()
#partition with KaHyPar
hgraph,proj_map = hyper_graph(graph)
partition_vector = KaHyPar.partition(hgraph,8,configuration = :connectivity,imbalance = 0.01)
partition = Partition(partition_vector,proj_map)
apply_partition!(graph,partition)

#plot partition
plt_graph1 = layout_plot(graph,layout_options = Dict(:tol => 0.01, :iterations => 500),linealpha = 0.2,markersize = 6,subgraph_colors = true);
plt_matrix1 = matrix_plot(graph,subgraph_colors = true);
Plots.savefig(plt_graph1,"figures/example4_layout_1.pdf")
Plots.savefig(plt_matrix1,"figures/example4_matrix_1.pdf")

#aggregate subgraphs
combined_graph,reference_map = aggregate(graph,0)

#plot combined graph layout and matrix
plt_graph2 = layout_plot(combined_graph,layout_options = Dict(:tol => 0.01,:iterations => 10),node_labels = true,markersize = 30,labelsize = 20,node_colors = true);
plt_matrix2 = matrix_plot(combined_graph,node_labels = true,node_colors = true);
Plots.savefig(plt_graph2,"figures/example4_layout_2.pdf")
Plots.savefig(plt_matrix2,"figures/example4_matrix_2.pdf")

#expand subgraphs
subgraphs = getsubgraphs(graph)
expanded_subs = expand.(graph,subgraphs,2)

#plot the expanded subgraphs
plt_graph3 = layout_plot(graph,expanded_subs,layout_options = Dict(:tol => 0.01,:iterations => 1000),markersize = 6,linealpha = 0.2);
plt_matrix3 = matrix_plot(graph,expanded_subs);
Plots.savefig(plt_graph3,"figures/example4_layout_3.pdf")
Plots.savefig(plt_matrix3,"figures/example4_matrix_3.pdf")
