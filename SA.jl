function Simulated_Anealing(order::Int, Tao::Int, R::Int, instance::Int, n_emp::Int,
        eps::Float64, popsize_multiplier::Int, stopping_count::Int, t0::Float64, tN::Float64,
         Cooling_steps::Int, assim_prob::Float64, swap_div::Int, perm_div::Int, rev_div::Int)
    r, p, d, d_bar, e, w, S = Read_one_instance(order, Tao, R, instance)
    t1 = time()
    t = t0
    i = 1
    roulette = [100,100,100,100]
    Empires = Vector{Empire}()
    old_obj = 0.0
    best = 0.0
    while t > tN
        Empires, best = Imperialist_Competition(Empires, r, p, d, d_bar, e, w, S, roulette, i,
            Cooling_steps, n_emp, eps, popsize_multiplier, stopping_count, assim_prob, swap_div, perm_div, rev_div)
        if i%50==0
#             println(roulette)
            # println("In step ",i, ", the temperature is ",round(t, digits=2),", the best function is: ", best, " roulet: ", roulette)
# #             println([emp.emperor.power for emp in Empires])
        end
        delete_at = Int[]
        for (i,emp) in enumerate(Empires)
            delta = emp.emperor.power - old_obj
            if delta < 0 
                if rand() > exp(delta/t)
                    push!(delete_at, i)
                end
            end
        end
        deleteat!(Empires, delete_at)
#         println([emp.emperor.power for emp in Empires])
        t = t0 * (tN/t0)^(i/Cooling_steps)
        old_obj = best
        i += 1
    end
    t2 = time()
    return best, t2-t1, Find_best_solution(Empires)
end
