function Imperialist_Competition(prev_empires::Vector{Empire}, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int,
        n_emp::Int, eps::Float64, popsize_multiplier::Int, stopping_count::Int, assim_prob::Float64, swap_div::Int, perm_div::Int, rev_div::Int)
    n_jobs = length(p)
    popsize = popsize_multiplier * n_jobs
    world = Generate_initial_world(popsize,prev_empires, r, p, d, d_bar, e, w, S)
    Empires = Generate_empires(n_emp, world, eps)
    non_improving_count = 0
    last_objective = 0.0
    best_objective = 0.0
    methods = [N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11]
    while length(Empires) > 1 && non_improving_count < stopping_count
        Empires = Inner_Competition(Empires, r, p, d, d_bar, e, w, S, roulette, methods, n_iter, max_iter, assim_prob, swap_div, perm_div, rev_div)
#         println("inner: ", [emp.emperor.power for emp in Empires])
        Empires, emperor_powers = Outer_Competition(Empires, eps)
#         println("outer: ", [emp.emperor.power for emp in Empires])
        best_objective = maximum(emperor_powers)
        if best_objective > last_objective
            last_objective = best_objective
            non_improving_count = 0
        else
            non_improving_count += 1
        end
#         println("nonimprove: ", non_improving_count, "last: ", best_objective)
    end
    return Empires, best_objective
end
