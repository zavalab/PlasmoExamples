using Plasmo
using Plots, PlasmoPlots
using GLPK

graph = OptiGraph()

@optinode(graph,n1)
@variable(n1, y >= 2)
@variable(n1,x >= 0)
@constraint(n1,x + y >= 3)
@objective(n1, Min, y)

@optinode(graph,n2)
@variable(n2, y)
@variable(n2,x >= 0)
@constraint(n2,x + y >= 3)
@objective(n2, Min, y)

@optinode(graph,n3)
@variable(n3, y )
@variable(n3,x >= 0)
@constraint(n3,x + y >= 3)
@objective(n3, Min, y)

#Create a link constraint linking the 3 models
@linkconstraint(graph, n1[:x] + n2[:x] + n3[:x] == 3)
set_optimizer(graph,GLPK.Optimizer)
optimize!(graph)

#Query Solution
println("n1[:x] = ",value(n1[:x]))
println("n2[:x] = ",value(n2[:x]))
println("n3[:x] = ",value(n3[:x]))
println("objective value = ",objective_value(graph))

plt_graph = PlasmoPlots.layout_plot(graph,node_labels = true,markersize = 60,labelsize = 30,
linewidth = 4,layout_options = Dict(:tol => 0.01,:iterations => 2));
plt_matrix = PlasmoPlots.matrix_plot(graph,node_labels = true,markersize = 40,labelsize = 32);

Plots.savefig(plt_graph,"figures/example1_layout.pdf")

Plots.savefig(plt_matrix,"figures/example1_matrix.pdf")
