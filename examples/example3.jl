#Example script that demonstrates how to use hypergraph partitioning to partition an optigraph
using Plasmo, PlasmoPlots, Plots
#NOTE: GR backend fails to render some blocks. You may need to install the pyplot backend to render the correct pdf
#pyplot()

#Create the optigraph which models a simple optimal control problem
T = 100          #number of time points
d = sin.(1:T)    #disturbance vector

graph = OptiGraph()
@optinode(graph,state[1:T])
@optinode(graph,control[1:T-1])

for node in state
    @variable(node,x)
    @constraint(node, x >= 0)
    @objective(node,Min,x^2)
end
for node in control
    @variable(node,u)
    @constraint(node, u >= -1000)
    @objective(node,Min,u^2)
end

@linkconstraint(graph,[i = 1:T-1],state[i+1][:x] == state[i][:x] + control[i][:u] + d[i])
n1 = state[1]
@constraint(n1,n1[:x] == 0)

#plot layout and matrix
plt_graph4 = layout_plot(graph,layout_options = Dict(:tol => 0.1,:C => 2, :K => 4, :iterations => 500),linealpha = 0.2,markersize = 6);
plt_matrix4 = matrix_plot(graph);
Plots.savefig(plt_graph4,"figures/example3_layout.pdf")
Plots.savefig(plt_matrix4,"figures/example3_matrix.pdf")
