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
function test(order::Int, Tao::Int, R::Int, instance::Int, num_runs::Int, assim_prob::Float64, swap_div::Int, perm_div::Int, rev_div::Int)
    # order = 50
    # Tao = 1
    # R = 1
    # instance = 1
    n_emp = 5
    eps = 0.3
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
    println("Mean Objective=", obj_sum/num_runs)
    println(time_sum/num_runs, " seconds on average")
    return obj_sum/num_runs
end
function test_parameters()
    probs = [0.2]
    swaps_divs = [10, 20, 30]
    perm_divs = [5, 10, 20]
    rev_divs = [1, 5, 10]
    best_obj = 0.0
    best_swap_div = 0
    best_perm_div = 0
    best_rev_div = 0
    for assim_prob in probs
        for swap_div in swaps_divs
            for perm_div in perm_divs
                for rev_div in rev_divs
                    obj = test(10, assim_prob, swap_div, perm_div, rev_div)
                    if obj > best_obj
                        best_obj = obj
                        best_perm_div = perm_div
                        best_swap_div = swap_div
                        best_rev_div = rev_div
                    end
                end
            end
        end
    end

    println("best swap div: " , best_swap_div)
    println("best perm div: " , best_perm_div)
    println("best rev div: " , best_rev_div)
end

# test_parameters()
for instance=1:10
    test(50,1,9,instance, 1, 0.2, 10, 5, 5)
end