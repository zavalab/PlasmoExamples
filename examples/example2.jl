using Plasmo
using Plots, PlasmoPlots

#Defines the function `create_optigraph`
include((@__DIR__)*"/create_optigraph.jl")

#Create multiple optigraphs
graph1 = simple_optigraph()
graph2 = simple_optigraph()
graph3 = simple_optigraph()

#Create high-level graph0
graph0 = OptiGraph()
@optinode(graph0,n0)
@variable(n0,x)
@constraint(n0,x >= 0)

#Add subgraphs to graph0
add_subgraph!(graph0,graph1)
add_subgraph!(graph0,graph2)
add_subgraph!(graph0,graph3)

n3 = graph1[1]; n5 = graph2[2]; n7 = graph3[1]

#Create linking constraints on graph0 connecting a global node
@linkconstraint(graph0,n0[:x] + n3[:x] == 3)
@linkconstraint(graph0,n0[:x] + n5[:x] == 5)
@linkconstraint(graph0,n0[:x] + n7[:x] == 7)

#Add linking constraint to graph0 connecting a global edge
@linkconstraint(graph0,n3[:x] + n5[:x] + n7[:x] == 10)

#Set node labels for plotting
for (i,node) in enumerate(all_nodes(graph0))
    node.label = "n$(i-1)"
end

plt_graph = PlasmoPlots.layout_plot(graph0,node_labels = true,markersize = 60,labelsize = 30,linewidth = 4,subgraph_colors = true,
layout_options = Dict(:tol => 0.01,:C => 2, :K => 1, :iterations => 5))
Plots.savefig(plt_graph,"figures/example2_layout.pdf")

plt_matrix = PlasmoPlots.matrix_plot(graph0,node_labels = true,subgraph_colors = true,markersize = 16);
Plots.savefig(plt_matrix,"figures/example2_matrix.pdf")
