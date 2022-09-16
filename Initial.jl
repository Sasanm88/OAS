include("utils.jl")
using StatsBase

function Update_time(seq::Vector{Int}, job::Int, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    n = length(seq)
    best = Int[]
    best_f = 0.0
    
    for i=1:n+1
        seq_ = copy(seq)
        insert!(seq_, i, job)
        f = Calculate_from_sequence(seq_, r,p,d,d_bar, e,w,S)
        if f > best_f
            best_f = f
            best = seq_
        end
    end
    C = Calculate_C(best, r, p, S)
    return C, best, best_f, best[n+1]  #last_job
end


function Heuristic_Initial(r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    f_times_e = (d-r).*e./p
    n = length(p)
    T = 0
    seq = Int[]
    jobs = [i for i=1:n]
    max_dbar = maximum(d_bar)
    last_job = 0
    best_f = 0.0
    while T <= max_dbar
        best_fte = 0.0
        best_job = 0
        best_index = 0
        Is_there_a_job = false
        for (index,j) in enumerate(jobs)
            if r[j] <= T
                if T + S[last_job+1, j+1] + p[j] <= d_bar[j]
                    if f_times_e[j] > best_fte
                        best_fte = f_times_e[j]
                        best_job = j
                        best_index = index
                        Is_there_a_job = true
                    end
                end
            end
        end
        if Is_there_a_job
            deleteat!(jobs, best_index)
            T, seq, best_f, last_job = Update_time(seq, best_job, r, p , d, d_bar, e, w, S)
        else
            T += 1
        end
    end
#     println("hueristic: ", best_f)
    return Country(Convert_to_representation(n, seq), best_f)
end


function Swap_one_heuristic(colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    rep = copy(colony.representation)
    i, j = sample(1:length(p), 2, replace = false)
    rep[i], rep[j] = rep[j], rep[i]
    power = Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)
    return Country(rep, power)
end


function Swap_two_heuristic(colony::Country, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    rep = copy(colony.representation)
    i, j, k, l = sample(1:length(p), 4, replace = false)
    rep[i], rep[j] = rep[j], rep[i]
    rep[k], rep[l] = rep[l], rep[k]
    power = Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)
    return Country(rep, power)
end


function Revolution_heuristic(colony::Country, chance::Float64, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    rep = copy(colony.representation)
    max_job = maximum(rep)
    n_jobs = length(p)
    zero = count(x->x==0, rep)
    nonzero = n_jobs - zero
    P_init = 0.85
    P_zn = 0.0
    P_nz = 0.0
    if zero > nonzero
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
#     println("start")
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
#     println(rep, max_job)
    for i in nonzero_to_zero_rev

        max_job -= 1

        for j=1:n_jobs
            if rep[j] > rep[i] 
                rep[j] -= 1
            end
        end
        rep[i] = 0
    end
#     println(rep, max_job)
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
#     println(rep, max_job)
    power = Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)
    return Country(rep, power)
end

function Generate_initial_world(num_countries::Int, prev_empires::Vector{Empire}, r::Vector{Int64},
        p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    n_jobs = length(p)
    chance = 0.1
    if length(prev_empires) == 0
        world = Vector{Country}()
        heuristic = Heuristic_Initial(r, p, d, d_bar, e, w, S)
        push!(world, heuristic)
        for i = 1:div(num_countries,3)
            push!(world, Swap_one_heuristic(heuristic, r, p, d, d_bar, e, w, S))
        end
#         for i = 1:div(num_countries,6)
#             push!(world, Swap_two_heuristic(heuristic, r, p, d, d_bar, e, w, S))
#         end
        for i = 1:div(num_countries,3)
            push!(world, Revolution_heuristic(heuristic, chance, r, p, d, d_bar, e, w, S))
        end
        for i=1:num_countries-length(world)
            rep = Random_representation(n_jobs, maximum(heuristic.representation)/n_jobs)
            push!(world, Country(rep, Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)))
        end
    else
        n_emp = length(prev_empires)
        world = Vector{Country}()
        perc = 0.0
        for Empire in prev_empires
            perc = maximum(Empire.emperor.representation)/n_jobs
            push!(world, Empire.emperor)
            for i = 1:div(num_countries, n_emp+1)-1
                if rand() < 0.5
                    push!(world, Swap_one_heuristic(Empire.emperor, r, p, d, d_bar, e, w, S))
                else
                    push!(world, Revolution_heuristic(Empire.emperor, chance, r, p, d, d_bar, e, w, S))
                end
            end
        end
        for i=1:num_countries-length(world)
            rep = Random_representation(n_jobs, perc)
            push!(world, Country(rep, Calculate_from_representation(rep, r, p, d, d_bar, e, w, S)))
        end
    end
    sort!(world, by=x->x.power, rev = true)
    return world
end

function Generate_empires(num_emp::Int, world::Vector{Country}, eps::Float64)
    powers = Float64[]
    for i=1:num_emp
        push!(powers, world[i].power)
    end
    temp = length(world)*powers./sum(powers)
    num_colonies = Int[]
    for i=1:num_emp-1
        push!(num_colonies, Int(round(temp[i])))
    end
    push!(num_colonies, length(world)-sum(num_colonies))
    Empires = Vector{Empire}()
    index = num_emp
    for i=1:num_emp
#         colony_power = 0.0
        emp = Empire(world[i], Country[], 0.0)
        for j=1:num_colonies[i]-1
            index += 1
            if index <= length(world)
                push!(emp.colonies, world[index])
            end
#             colony_power += world[index].power
        end
#         emp.power += eps * colony_power
        push!(Empires, emp)
    end
#     println("generate: ", [emp.emperor.power for emp in Empires])
    return Empires
end