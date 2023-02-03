include("utils.jl")
include("Imperialist.jl")
include("Initial.jl")
include("Inner_Comp.jl")
include("Outer_Comp.jl")
include("Read_data.jl")
include("SA.jl")
include("Escape.jl")



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

function test(order::Int, Tao::Int, R::Int, instance::Int, run_num::Int,
     assim_prob::Float64, swap_div::Int, perm_div::Int, rev_div::Int, n_emp::Int, eps::Float64, t0::Float64, tN::Float64)
    popsize_multiplier = 4
    stopping_count = 20

    Cooling_steps = 1000
    Objs = Float64[]
    times = Float64[]
    println("Order:",order," Tao:", Tao, " R=", R , " instance=", instance)
    for i=1:run_num
        best , run_time = Simulated_Anealing(order, Tao, R, instance, n_emp, eps, popsize_multiplier,
        stopping_count, t0, tN, Cooling_steps, assim_prob, swap_div, perm_div, rev_div)
        push!(Objs, best)
        push!(times, run_time)
        println("Run:", i, ", Objective=", best, ", Time=", round(run_time, digits=2))
    end
    println("Order:",order," Tao:", Tao, " R=", R , " instance=", instance, ", Average objective= ", mean(Objs), ", Average run times= ", mean(times))
    return Objs, times
end


function Solve_all()
    n_emp = 15
    eps = 0.2
    swap_div = 10
    perm_div = 10
    rev_div = 10
    assim_prob = 0.2
    num_runs = 10
    t0 = 1000.0
    tN = 1.0
    orders = [10, 15, 20, 25, 50, 100]
    Taos = [1, 3, 5, 7, 9]
    Rs = [1, 3, 5, 7, 9]
    for (sheet, order) in enumerate(orders)
        row = 2
        for Tao in Taos
            for R in Rs
                for instance=1:10
                    objs, run_times = test(order, Tao, R, instance, num_runs, assim_prob, swap_div, perm_div, rev_div, n_emp, eps, t0, tN)
                    file_name = "Results" * string(order) * ".xlsx"
                    Write_to_excel_new(file_name, sheet, row, Tao, R, instance, objs, run_times)
                    row +=1 
                end
            end
        end
    end
end

Solve_all()


function test_parameters(sheet_num::Int, experiment_instances::Vector{Vector{Vector{Vector{Int}}}}, n_emp::Int, eps::Float64, t0::Float64, tN::Float64)
    assim_prob = 0.2
    swap_div = 10
    perm_div = 10
    rev_div = 10
    orders = [10, 15, 20, 25, 50, 100]
    Taos = [1, 3, 5, 7, 9]
    Rs = [1, 3, 5, 7, 9]

    row = 3
    for i=1:6
        println("t0=", t0, " tN=", tN)
        for j=1:5
            for k=1:5
                for instance in experiment_instances[i][j][k]
                    obj, run_time = test(orders[i], Taos[j], Rs[k], instance, 1, assim_prob, swap_div, perm_div, rev_div, n_emp, eps, t0, tN)
                    Write_to_excel("results3.xlsx", sheet_num, row, t0, tN, orders[i], Taos[j], Rs[k], obj, run_time)
                    row += 1
                end
            end
        end
    end
end


function test_single(order::Int, Tao::Int, R::Int, instance::Int)
    n_emp = 15
    eps = 0.2
    swap_div = 10
    perm_div = 10
    rev_div = 10
    assim_prob = 0.2
    t0 = 1000.0
    tN = 1.0
   popsize_multiplier = 4
   stopping_count = 20

   Cooling_steps = 1000

   println("Order:",order," Tao:", Tao, " R=", R , " instance=", instance)
   
#    Read_and_print(order, Tao, R, instance)
    best , run_time, solution = Simulated_Anealing(order, Tao, R, instance, n_emp, eps, popsize_multiplier,
       stopping_count, t0, tN, Cooling_steps, assim_prob, swap_div, perm_div, rev_div)
       
    println()
    println("It took ", run_time, " seconds")
   println("Before Improvement:")
   println("Best Objective is: ", best)
   println("Solution is: ")
   for i in solution
        print(i, ", ")
   end
   r, p, d, d_bar, e, w, S = Read_one_instance(order, Tao, R, instance)
   t1 = time()
   final_solution = Improve(500000, 20, 0.1, solution, best, r, p , d, d_bar, e, w, S)
   t2 = time()
   println()
   println()
   println("After Improvement:")
   println("Best Objective is: ", final_solution[1].power)
   println("Solution is: ")
   for i in final_solution[1].representation
        print(i, " ")
   end
   println()
   println("It took ", t2-t1, " seconds")
end

# test_single(50, 9, 9, 4)

# function test_Improvement()
#     solution = [54, 18, 24, 93, 81, 75, 60, 13, 73, 32, 87, 58, 33, 43, 23, 19, 98, 17, 88, 96, 76, 16, 86, 89, 79, 35, 77, 25, 100, 5, 39, 
#     65, 41, 11, 31, 44, 59, 4, 2, 64, 72, 48, 15, 61, 83, 70, 12, 69, 94, 47, 6, 80, 90, 78, 20, 95, 91, 62, 21, 97, 28, 46, 68, 8, 82, 22, 
#     92, 38, 84, 66, 71, 85, 55, 99, 9, 45, 63, 34, 40, 36, 57, 1, 29, 42, 74, 30, 26, 37, 10, 50, 3, 51, 7, 56, 14, 67, 27, 49, 53, 52]
#     r, p, d, d_bar, e, w, S = Read_one_instance(100, 9 , 1, 6)
#     best = 838.0
#     a = [50, 100 , 200, 300, 500]
#     b = [0.01, 0.02, 0.05, 0.1, 0.15]
#     for x in a
#         for y in b
#             final_solution = Improve(100000, x, y, solution, best, r, p , d, d_bar, e, w, S)
#             println("Buffer size=", x, " ,allowed difference=",y, " ,Obj=", final_solution.power)
#         end
#     end
# end

# test_Improvement()

# function compare_parameters()
#     orders = [10, 15, 20, 25, 50, 100]
#     Taos = [1, 3, 5, 7, 9]
#     Rs = [1, 3, 5, 7, 9]
#     experiment_instances = Vector{Vector{Vector{Vector{Int}}}}()
#     for order in orders
#         experiments2 = Vector{Vector{Vector{Int}}}()
#         for Tao in Taos
#             experiments1 = Vector{Vector{Int}}()
#             for R_ in Rs
#                  push!(experiments1, sample(1:10, 2, replace=false))
#             end
#             push!(experiments2, experiments1)
#         end
#         push!(experiment_instances, experiments2)
#     end
#     tNs = [0.1, 1.0, 10.0, 100.0]
#     t0s = [10000.0, 5000.0, 1000.0, 500.0]

#     n_emp = 15
#     eps = 0.2 #or 0.1
#     sheet_num = 0
#     for t0 in t0s
#         for tN in tNs
#             sheet_num +=1 
#             test_parameters(sheet_num, experiment_instances, n_emp, eps, t0, tN)
#         end
#     end
# end

# compare_parameters()