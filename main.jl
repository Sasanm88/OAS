include("utils.jl")
include("Imperialist.jl")
include("Initial.jl")
include("Inner_Comp.jl")
include("Outer_Comp.jl")
include("Read_data.jl")
include("SA.jl")



# r, p, d, d_bar, e, w, S = Read_one_instance(10, 1, 1, 1)
# Empires_prev = Empire[]
# world = Generate_initial_world(100, Empires_prev, r, p , d, d_bar, e, w, S)

# Empires = Generate_empires(5, world, 0.3)

# for i in Empires[4].emperor.representation
#     print(i, " ")
# end
# println()
# for i in Empires[4].colonies[5].representation
#     print(i, " ")
# end

# Assimilate(Empires[4].colonies[5], Empires[4].emperor, r, p, d, d_bar, e, w, S )
# println()
# for i in Empires[4].colonies[5].representation
#     print(i, " ")
# end
function test()
    order = 50
    Tao = 3
    R = 5
    instance = 5
    n_emp = 5
    eps = 0.3
    popsize_multiplier = 4
    stopping_count = 20
    t0 = 10000.0
    tN = 1.0
    Cooling_steps = 1000
    obj_sum = 0.0
    time_sum = 0.0
    for i=1:10
        best , run_time = Simulated_Anealing(order, Tao, R, instance, n_emp, eps, popsize_multiplier, stopping_count, t0, tN, Cooling_steps)
        obj_sum += best
        time_sum += run_time
        println("Objective=", best, " run time=",run_time)
    end
    println("Mean Objective=", obj_sum/10)
    println(time_sum/10, " seconds on average")
end

test()