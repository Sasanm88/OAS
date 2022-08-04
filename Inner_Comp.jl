function Swap_n(colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int)
    rep = copy(colony.representation)
    n_jobs = length(p)
    n_swap = max(Int(floor(n_jobs*(1-n_iter/max_iter)/20)), 1)
    # n_swap = 1
    swap_pairs = sample(1:n_jobs, 2*n_swap, replace=false)
    for i=1:n_swap
        rep[swap_pairs[i]], rep[swap_pairs[n_swap+i]] = rep[swap_pairs[n_swap+i]], rep[swap_pairs[i]]
        power = Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)
        if power > colony.power
#         print("S")
            colony.representation = rep
            colony.power = power
            roulette[1] += 1
            break
        end
    end
    
    
    return colony
end


function Perm_n(colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int)
    rep = copy(colony.representation)
    n_jobs = length(rep)
    n_perm = max(Int(floor(n_jobs*(1-n_iter/max_iter)/5)), 3)
    perm_jobs = sample(1:n_jobs, n_perm, replace=false)
    perm_jobs_shuffled = shuffle(perm_jobs)
    rep[perm_jobs] = rep[perm_jobs_shuffled]
    power = Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)
    if power > colony.power
#         print("P")
        colony.representation = rep
        colony.power = power
        roulette[2] += 1
    end
    return colony
end

function Crossover(emp::Country, colony::Country)
    parent1 = Convert_to_sequence(emp.representation)
    parent2 = Convert_to_sequence(colony.representation)
    p1 = copy(parent1)
    p2 = copy(parent2)
    child1 = Int[]
    l = rand(min(length(p1),length(p2)):max(length(p1),length(p2)))

    priority = 1
    next1 = 1
    next2 = 1
    while length(child1) < l
        if next1 > length(p1)
            push!(child1, p2[next2])
            next2 += 1
        elseif next2 > length(p2)
            push!(child1, p1[next1])
            next1 += 1
        else
            if priority == 1 
                push!(child1, p1[next1])
                i = findfirst(x->x==p1[next1], p2)
                if !isnothing(i)
                    deleteat!(p2, i)
                end
                priority = 2
                next1 += 1
            else
                push!(child1, p2[next2])
                i = findfirst(x->x==p2[next2], p1)
                if !isnothing(i)
                    deleteat!(p1, i)
                end
                priority = 1
                next2 += 1
            end
        end
    end

    p1 = copy(parent1)
    p2 = copy(parent2)
    child2 = Int[]
    l = rand(min(length(p1),length(p2)):max(length(p1),length(p2)))

    priority = 2
    next1 = 1
    next2 = 1
    while length(child2) < l
        if next1 > length(p1)
            push!(child2, p2[next2])
            next2 += 1
        elseif next2 > length(p2)
            push!(child2, p1[next1])
            next1 += 1
        else
            if priority == 1 
                push!(child2, p1[next1])
                i = findfirst(x->x==p1[next1], p2)
                if !isnothing(i)
                    deleteat!(p2, i)
                end
                priority = 2
                next1 += 1
            else
                push!(child2, p2[next2])
                i = findfirst(x->x==p2[next2], p1)
                if !isnothing(i)
                    deleteat!(p1, i)
                end
                priority = 1
                next2 += 1
            end
        end
    end
    return child1, child2
end

function Crossover_(emp::Country, colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int})
    child1, child2 = Crossover(emp, colony)
    power1 = Calculate_from_sequence(child1, r, p, d, d_bar, e, w, S)
    power2 = Calculate_from_sequence(child2, r, p, d, d_bar, e, w, S)
    if power1 > colony.power
        colony.representation = Convert_to_representation(length(p), child1)
        colony.power = power2
        roulette[4] += 1
    end
    if power2 > colony.power
        colony.representation = Convert_to_representation(length(p), child2)
        colony.power = power2
        roulette[4] += 1
    end
    return colony
end

function Revolution(colony::Country, chance::Float64, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int)
    chance = chance * max(0.1, 1-n_iter/max_iter)
#     if n_iter%50==0
#         println(chance)
#     end
    rep = copy(colony.representation)
    max_job = maximum(rep)
    n_jobs = length(p)
    zero = count(x->x==0, rep)
    nonzero = n_jobs - zero
    P_init = 0.9
    P_zn = 0.0
    P_nz = 0.0
    if zero < nonzero
        P_zn = P_init
        P_nz = P_zn * zero/nonzero
    else
        P_nz = P_init
        P_zn = P_nz * nonzero/zero
    end
    zero_rev= Int[]
    nonzero_to_zero_rev = Int[]
    nonzero_to_nonzero_rev = Int[]
    
    for (i, j) in enumerate(rep)
        if rand() < chance
            if j==0
                if rand() < P_zn
                    push!(zero_rev, i)
                end
            else
                if rand() < P_nz
                    push!(nonzero_to_zero_rev, i)
                else
                    push!(nonzero_to_nonzero_rev, i)
                end
            end
        end
    end

    for i in zero_rev
        new = rand(1:max_job+1)
        if new >= max_job
            max_job +=1
        end
        for j=1:n_jobs
            if rep[j] >= new
                rep[j] += 1
            end
        end
        rep[i] = new
    end

    for i in nonzero_to_zero_rev

        max_job -= 1

        for j=1:n_jobs
            if rep[j] > rep[i] 
                rep[j] -= 1
            end
        end
        rep[i] = 0
    end

    for i in nonzero_to_nonzero_rev
        new = rand(1:max_job)
        if new > rep[i]
            for j=1:n_jobs
                if rep[j] > rep[i] && rep[j] <= new
                    rep[j] -= 1
                end
            end
        end
        if new < rep[i]
            for j=1:n_jobs
                if rep[j] < rep[i] && rep[j] >= new
                    rep[j] += 1
                end
            end
        end
        rep[i] = new
    end
    power = Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)
    if power > colony.power
#         print("R")
        colony.representation = rep
        colony.power = power
        roulette[3] += 1
#         return Country(rep, power)
    end
    return colony
end


function Assimilate(colony::Country, emperor::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
    e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, prob::Float64)  
    max_job = maximum(colony.representation)
    n_job = length(colony.representation)
    for i = 1:n_job
        if emperor.representation[i]>0
            if colony.representation[i]>0 
                if emperor.representation[i] < colony.representation[i]
                    for j = 1:n_job
                        if emperor.representation[i] <= colony.representation[j] < colony.representation[i]
                            colony.representation[j] += 1
                        end
                    end
                    colony.representation[i] = emperor.representation[i]
                end
                if emperor.representation[i] > colony.representation[i]
                    for j = 1:n_job
                        if colony.representation[i] < colony.representation[j] <= emperor.representation[i]
                            colony.representation[j] -= 1
                        end
                    end
                    colony.representation[i] = min(emperor.representation[i], max_job)
                end
            elseif rand() < prob
                for j = 1:n_job
                    if colony.representation[j] >= emperor.representation[i]
                        colony.representation[j] += 1
                    end
                end
                max_job += 1
                colony.representation[i] = min(emperor.representation[i], max_job)
            end
        end
    end
    
    colony.power = Calculate_from_representation(colony.representation, r, p, d, d_bar, e, w, S)
end

function Assimilate2(colony::Country, emperor::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
    e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})  
    new_colony = copy(emperor.representation)
    max_job = maximum(new_colony)
    n_job = length(colony.representation)
    for i = 1:n_job
        if colony.representation[i]>0
            if new_colony[i]>0 
                if colony.representation[i] < new_colony[i]
                    for j = 1:n_job
                        if colony.representation[i] <= new_colony[j] < new_colony[i]
                            new_colony[j] += 1
                        end
                    end
                    new_colony[i] = colony.representation[i]
                end
                if colony.representation[i] > colony.representation[i]
                    for j = 1:length(colony.representation)
                        if new_colony[i] < new_colony[j] <= colony.representation[i]
                            new_colony[j] -= 1
                        end
                    end
                    new_colony[i] = min(colony.representation[i], max_job)
                end
            end
        end
    end
    colony.representation = new_colony
    colony.power = Calculate_from_representation(colony.representation, r, p, d, d_bar, e, w, S)
end

function Assimilate_effecient(colony::Country, emperor::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
    e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})  
    n_jobs = length(emperor.representation)
    justC = zeros(Int, n_jobs)
    newC = zeros(Int, n_jobs)
    for i=1:n_jobs
        if colony.representation[i]>0 
            if emperor.representation[i]>0
                newC[emperor.representation[i]] = i
            else
                justC[colony.representation[i]] = i
            end
        end
    end
    deleteat!(justC, findall(x->x==0,justC))
    index = findfirst(x->x==0, newC)
    for job in justC
        newC[index] = job
        while index <= n_jobs && newC[index] != 0
            index +=1
        end
    end
    deleteat!(newC, findall(x->x==0,newC))
    colony.representation = Convert_to_representation(n_jobs, newC)
    colony.power = Calculate_from_representation(colony.representation, r, p, d, d_bar, e, w, S)
end


function Inner_Competition(Empires::Vector{Empire}, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int)
    for emp = 1:length(Empires)
        for c = 1:length(Empires[emp].colonies)
#             probs = roulette/sum(roulette)
            Assimilate(Empires[emp].colonies[c], Empires[emp].emperor, r, p, d, d_bar, e, w, S, 0.2)
            Assimilate2(Empires[emp].colonies[c], Empires[emp].emperor, r, p, d, d_bar, e, w, S)
            probs = [0.4, 0.2, 0.4, 0.0]
            random_number = rand()
            which = 0
            if random_number < probs[1]
                which = 1
                colony = Swap_n(Empires[emp].colonies[c], r, p, d, d_bar, e, w, S, roulette, n_iter, max_iter)
            elseif random_number < probs[2]+probs[1]
                which = 2
                colony = Perm_n(Empires[emp].colonies[c], r, p, d, d_bar, e, w, S, roulette, n_iter, max_iter)
            elseif random_number < probs[2]+probs[1]+probs[3]
                which = 3
                colony = Revolution(Empires[emp].colonies[c], 0.5*(Empires[emp].emperor.power-Empires[emp].colonies[c].power)/Empires[emp].emperor.power, r, p, d, d_bar, e, w, S, roulette, n_iter, max_iter)
            else
                colony = Crossover_(Empires[emp].emperor, Empires[emp].colonies[c], r, p, d, d_bar, e, w, S, roulette)
            end
            
            if colony.power > Empires[emp].emperor.power
#                 println("method ", which, "  ",  Empires[emp].emperor.power, "  ", colony.power)
#                 temp_rep = emp.emperor.representation
#                 temp_power = emp.emperor.power
#                 emp.emperor = colony
#                 colony.representation = temp_rep
#                 colony.power = temp_power
                temp = deepcopy(Empires[emp].emperor)
                Empires[emp].emperor = colony
                Empires[emp].colonies[c] = temp
            end
        end
    end
    return Empires
end
