function simple_optigraph()
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
    return graph
end
