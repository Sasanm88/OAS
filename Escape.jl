using StatsBase

function N1(c::Vector{Int}, US::Vector{Int})   #Swaps two jobs within S    S: Sequence of selected jobs, NS: Set of Unselected jobs
    S = copy(c)
    i1, i2 = sample(1:length(S), 2, replace = false)
    S[i1], S[i2] = S[i2], S[i1]
    return S
end

function N2(c::Vector{Int}, US::Vector{Int})  #Randomly removes a job in S and randomly puts it somewhere in S 
    S = copy(c)
    n = length(S)
    i1 = rand(1:n)
    temp = S[i1]
    deleteat!(S, i1)
    i2 = rand(1:n)
    insert!(S, i2, temp)
    return S
end

function N3(c::Vector{Int}, US::Vector{Int})  #Randomly removes two consecutive jobs in S, eg. a,b and select a random c in S and puts a and b as (a,b,c) 
    S = copy(c)
    n = length(S)
    i1 = rand(1:n-1)
    temp1, temp2 = S[i1], S[i1+1]
    deleteat!(S, [i1, i1+1])
    i2 = rand(1:n-2)
    insert!(S, i2, temp1)
    insert!(S, i2+1, temp2)
    return S
end

function N4(c::Vector{Int}, US::Vector{Int})  #Randomly removes two consecutive jobs in S, eg. a,b and select a random c in S and puts a and b as (b,a,c) 
    S = copy(c)
    n = length(S)
    i1 = rand(1:n-1)
    temp1, temp2 = S[i1], S[i1+1]
    deleteat!(S, [i1, i1+1])
    i2 = rand(1:n-1)
    insert!(S, i2, temp2)
    insert!(S, i2+1, temp1)
    return S
end

function N5(c::Vector{Int}, US::Vector{Int})  #Randomly removes a job in S 
    S = copy(c)
    n = length(S)
    i1 = rand(1:n)
    deleteat!(S, i1)
    return S
end

function N6(c::Vector{Int}, US::Vector{Int})  #Randomly selects two consecutive jobs in S and reverses them
    S = copy(c)
    n = length(S)
    i1 = rand(1:n-1)
    S[i1+1], S[i1] = S[i1], S[i1+1]
    return S
end

function N7(c::Vector{Int}, US::Vector{Int})  #Randomly selects three consecutive jobs in S and reverses them
    S = copy(c)
    n = length(S)
    i1 = rand(1:n-2)
    S[i1+2], S[i1] = S[i1], S[i1+2]
    return S
end

function N8(c::Vector{Int}, US::Vector{Int})  #Randomly chooses a job from US and randomly puts it somewhere in S 
    S = copy(c)
    n = length(S)
    if length(US)==0
        return S
    end
    new_job = US[rand(1:length(US))]
    i2 = rand(1:n+1)
    insert!(S, i2, new_job)
    return S
end

function N9(c::Vector{Int}, US::Vector{Int})  #Randomly chooses a job from US and randomly puts it between a and b while swapping a and b
    S = copy(c)
    n = length(S)
    if length(US)==0
        return S
    end
    new_job = US[rand(1:length(US))]
    i2 = rand(2:n-1)
    insert!(S, i2, new_job)
    S[i2-1], S[i2+1] = S[i2+1], S[i2-1]
    return S
end

function N10(c::Vector{Int}, US::Vector{Int})  #Randomly chooses a job from US and replaces it with a job in S 
    S = copy(c)
    n = length(S)
    if length(US)==0
        return S
    end
    new_job = US[rand(1:length(US))]
    i2 = rand(1:n)
    S[i2] = new_job
    return S
end

function N11(c::Vector{Int}, US::Vector{Int})  #Randomly removes a job in S while Randomly chooses a job from US and puts it in S 
    S = copy(c)
    n = length(S)
    i1 = rand(1:n)
    deleteat!(S, i1)
    if length(US)==0
        return S
    end
    new_job = US[rand(1:length(US))]
    i2 = rand(1:n)
    insert!(S, i2, new_job)
    return S
end

function Improve(max_iter::Int, max_size::Int, Allowed_diff::Float64, best::Vector{Int}, best_f::Float64, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, 
    d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})

    methods = [N1, N2, N3, N4, N5, N6, N7, N8, N9, N10, N11]
    Substitutes = Vector{Country}()
    push!(Substitutes, Country(best, best_f))
    all_jobs = [i for i=1:length(r)]
    for i=1:max_iter
        country = Substitutes[rand(1:length(Substitutes))]
        rr = rand(1:length(methods))
        Seq = methods[rr](country.representation, collect(setdiff(all_jobs, country.representation)))
        new_f = Calculate_from_sequence(Seq, r, p, d, d_bar, e, w, S)
        if new_f > best_f || (best_f-new_f)/new_f < Allowed_diff
            if length(Substitutes) < max_size
                push!(Substitutes, Country(Seq, new_f))
                best_f = new_f
            else
                sort!(Substitutes, by = x -> x.power, rev = true)
                Substitutes[max_size] = Country(Seq, new_f)
            end
        end
    end
    sort!(Substitutes, by = x -> x.power, rev = true)
    return Substitutes
end


function Improve_Empires(Empires::Vector{Empire}, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, 
    d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    n_jobs = length(r)
    best, best_f = Find_the_local_optima(Empires)
    Substitues = Improve(100000, 50, 0.1,best, best_f, r, p, d, d_bar, e, w, S)
    for (i,emp) in enumerate(Empires)
        emp.emperor.representation = Convert_to_representation(n_jobs, Substitues[i].representation)
        emp.emperor.power = Substitues[i].power
    end
end


function Find_the_local_optima(empires::Vector{Empire})
    best_obj = 0.0
    best_rep = Int[]
    for emp in empires
        if emp.emperor.power > best_obj
            best_obj = emp.emperor.power
            best_rep = emp.emperor.representation
        end
    end
    return Convert_to_sequence(best_rep), best_obj
end