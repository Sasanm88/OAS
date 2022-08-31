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
function test(order::Int, Tao::Int, R::Int, instance::Int, num_runs::Int,
     assim_prob::Float64, swap_div::Int, perm_div::Int, rev_div::Int, n_emp::Int, eps::Float64)
    # order = 50
    # Tao = 1
    # R = 1
    # instance = 1
    # n_emp = 5
    # eps = 0.3
    popsize_multiplier = 4
    stopping_count = 20
    t0 = 10000.0
    tN = 1.0
    Cooling_steps = 1000
    obj_sum = 0.0
    time_sum = 0.0
    for i=1:num_runs
        best , run_time = Simulated_Anealing(order, Tao, R, instance, n_emp, eps, popsize_multiplier,
         stopping_count, t0, tN, Cooling_steps, assim_prob, swap_div, perm_div, rev_div)
        obj_sum += best
        time_sum += run_time
        # println("Objective=", best, " run time=",run_time)
    end
    # println("Assimilation probability: ", assim_prob, " swap div: ", swap_div, " perm div: ", perm_div, " rev div: ", rev_div)
    println("Order:",order," Tao:", Tao, " R=", R , " instance=", instance, " Objective=", obj_sum/num_runs, " Time=", round(time_sum/num_runs, digits=2))
    # println(time_sum/num_runs, " seconds on average")
    return obj_sum/num_runs, time_sum/num_runs
end


function test_parameters(n_emp::Int, eps::Float64)
    assim_prob = 0.2
    swap_div = 10
    perm_div = 10
    rev_div = 10
    orders = [10, 15, 20] #, 25, 50, 100]
    Taos = [1, 3, 5, 7, 9]
    Rs = [1, 3, 5, 7, 9]
    experiment_instances = Vector{Vector{Vector{Vector{Int}}}}()
    for order in orders
        experiments2 = Vector{Vector{Vector{Int}}}()
        for Tao in Taos
            experiments1 = Vector{Vector{Int}}()
            for R_ in Rs
                 push!(experiments1, sample(1:10, 2, replace=false))
            end
            push!(experiments2, experiments1)
        end
        push!(experiment_instances, experiments2)
    end

    for i=1:length(orders)
        for j=1:length(Taos)
            for k=1:length(Rs)
                for instance in experiment_instances[i][j][k]
                    obj, run_time = test(orders[i], Taos[j], Rs[k], instance, 1, assim_prob, swap_div, perm_div, rev_div, n_emp, eps)
                end
            end
        end
    end
end

test_parameters(5, 0.3)
