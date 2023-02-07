function Swap_n(colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int, swap_div::Int)
    n_jobs = length(p)
    rep = copy(Convert_to_representation(n_jobs, colony.representation))
    n_swap = max(Int(floor(n_jobs*(1-n_iter/max_iter)/swap_div)), 1)
    # n_swap = 1
    swap_pairs = sample(1:n_jobs, 2*n_swap, replace=false)
    for i=1:n_swap
        rep[swap_pairs[i]], rep[swap_pairs[n_swap+i]] = rep[swap_pairs[n_swap+i]], rep[swap_pairs[i]]
        seq = Convert_to_sequence(rep)
        power = Calculate_from_sequence(seq, r, p, d, d_bar, e, w, S)
        if power > colony.power
#         print("S")
            colony.representation = seq
            colony.power = power
            roulette[1] += 1
            break
        end
    end
    return colony
end


function Perm_n(colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int, perm_div::Int)
    n_jobs = length(r)
    rep = copy(Convert_to_representation(n_jobs, colony.representation))
    n_perm = max(Int(floor(n_jobs*(1-n_iter/max_iter)/perm_div)), 3)
    perm_jobs = sample(1:n_jobs, n_perm, replace=false)
    perm_jobs_shuffled = shuffle(perm_jobs)
    rep[perm_jobs] = rep[perm_jobs_shuffled]
    seq = Convert_to_sequence(rep)
    power = Calculate_from_sequence(seq, r, p, d, d_bar, e, w, S)
    if power > colony.power
#         print("P")
        colony.representation = seq
        colony.power = power
        roulette[2] += 1
    end
    return colony
end


function Revolution(colony::Country, chance::Float64, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, n_iter::Int, max_iter::Int, rev_div::Int)
    chance = chance * max(0.1, (1-n_iter/max_iter)/rev_div)
    n_jobs = length(p)
    rep = copy(Convert_to_representation(n_jobs, colony.representation))
    max_job = maximum(rep)
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
    seq = Convert_to_sequence(rep)
    power = Calculate_from_sequence(seq, r, p, d, d_bar, e, w, S)
    if power > colony.power
#         print("R")
        colony.representation = seq
        colony.power = power
        roulette[3] += 1
#         return Country(rep, power)
    end
    return colony
end


function Assimilate(colony::Country, emperor::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64},
    e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, prob::Float64)  
    max_job = length(colony.representation)
    n_job = length(r)
    emperor_representation = copy(Convert_to_representation(n_job, emperor.representation))
    colony_representation = copy(Convert_to_representation(n_job, colony.representation))
    for i = 1:n_job
        if emperor_representation[i]>0
            if colony_representation[i]>0 
                if emperor_representation[i] < colony_representation[i]
                    for j = 1:n_job
                        if emperor_representation[i] <= colony_representation[j] < colony_representation[i]
                            colony_representation[j] += 1
                        end
                    end
                    colony_representation[i] = emperor_representation[i]
                end
                if emperor_representation[i] > colony_representation[i]
                    for j = 1:n_job
                        if colony_representation[i] < colony_representation[j] <= emperor_representation[i]
                            colony_representation[j] -= 1
                        end
                    end
                    colony_representation[i] = min(emperor_representation[i], max_job)
                end
            elseif rand() < prob
                for j = 1:n_job
                    if colony_representation[j] >= emperor_representation[i]
                        colony_representation[j] += 1
                    end
                end
                max_job += 1
                colony_representation[i] = min(emperor_representation[i], max_job)
            end
        end
    end
    seq = Convert_to_sequence(colony_representation)
    colony.representation = seq
    colony.power = Calculate_from_sequence(seq, r, p, d, d_bar, e, w, S)
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
        e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64}, roulette::Vector{Int}, methods::Vector{Function}, n_iter::Int, max_iter::Int,
         assim_prob::Float64, swap_div::Int, perm_div::Int, rev_div::Int)
    all_jobs = [i for i=1:length(r)]
    probs = Compute_Cumulative_Probabilities(roulette)

    for emp = 1:length(Empires)
        for c = 1:length(Empires[emp].colonies)
#             

            Assimilate(Empires[emp].colonies[c], Empires[emp].emperor, r, p, d, d_bar, e, w, S, assim_prob)
        
            ii = rand(1:length(probs))
            Seq = methods[ii](Empires[emp].colonies[c].representation, collect(setdiff(all_jobs, Empires[emp].colonies[c].representation)))
            new_f = Calculate_from_sequence(Seq, r, p, d, d_bar, e, w, S)
            if new_f > Empires[emp].colonies[c].power
                Empires[emp].colonies[c].representation = Seq
                Empires[emp].colonies[c].power = new_f
            end

            if rand() < 0.3
                Empires[emp].colonies[c] = Swap_n(Empires[emp].colonies[c], r, p, d, d_bar, e, w, S, roulette, n_iter, max_iter,swap_div)
            end
            if rand() < 0.3
                Empires[emp].colonies[c] = Perm_n(Empires[emp].colonies[c], r, p, d, d_bar, e, w, S, roulette, n_iter, max_iter,perm_div)
            end
            if rand() < 0.1
                Empires[emp].colonies[c] = Revolution(Empires[emp].colonies[c], 0.5*(Empires[emp].emperor.power-Empires[emp].colonies[c].power)/Empires[emp].emperor.power,
                 r, p, d, d_bar, e, w, S, roulette, n_iter, max_iter,rev_div)
            end
            
            if Empires[emp].colonies[c].power > Empires[emp].emperor.power
#                 println("method ", which, "  ",  Empires[emp].emperor.power, "  ", colony.power)
#                 temp_rep = emp.emperor.representation
#                 temp_power = emp.emperor.power
#                 emp.emperor = colony
#                 colony.representation = temp_rep
#                 colony.power = temp_power
                temp = deepcopy(Empires[emp].emperor)
                Empires[emp].emperor = Empires[emp].colonies[c]
                Empires[emp].colonies[c] = temp
            end
        end
    end
    return Empires
end
