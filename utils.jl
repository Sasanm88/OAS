using Random

mutable struct Country
    representation::Vector{Int}
    power::Float64
end
        
mutable struct Empire
    emperor::Country
    colonies::Vector{Country}
    power::Float64
end


function Random_representation(n_jobs::Int, selected_percentage::Float64)
    perc = (0.6 + 0.8 * rand())*selected_percentage
    r = min(Int(round(perc*n_jobs)), n_jobs)
    seq = zeros(Int, n_jobs)
    for i=1:r
        seq[i] = i
    end
    return shuffle(seq)
end

function Convert_to_sequence(rep::Vector{Int})
    seq = zeros(Int, maximum(rep))
    for i = 1:length(rep)
        if rep[i]>0
            seq[rep[i]] = i
        end
    end
    return seq
end

function Convert_to_representation(n_jobs::Int, seq::Vector{Int})
    rep = zeros(Int, n_jobs)
    for (i,j) in enumerate(seq)
        rep[j] = i
    end
    return rep
end

function Calculate_C(seq::Vector{Int}, r::Vector{Int64}, p::Vector{Int64}, S::Matrix{Int64})
#     seq = zeros(Int, maximum(rep))
#     for i = 1:length(rep)
#         if rep[i]>0
#             seq[rep[i]] = i
#         end
#     end
    C = 0
    old_job = 0
    for i = 1:length(seq)
        new_job = seq[i]
        C = max(C+ S[old_job+1, new_job+1], r[new_job]) + p[new_job]
        old_job = new_job
    end
    return C
end


function Calculate_from_representation(rep::Vector{Int}, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    seq = zeros(Int, maximum(rep))
    for i = 1:length(rep)
        if rep[i]>0
            seq[rep[i]] = i
        end
    end
    total_r = 0.0
    C = 0
    old_job = 0
    for i = 1:length(seq)
        new_job = seq[i]
        C = max(C+ S[old_job+1, new_job+1], r[new_job]) + p[new_job]
        if C > d_bar[new_job]
            return 0.0
        end
        T = max(0, C-d[new_job])
        total_r += max(0.0, e[new_job]-T*w[new_job])
        old_job = new_job
    end
    return total_r
end


function Calculate_from_sequence(seq::Vector{Int}, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    total_r = 0.0
    C = 0
    old_job = 0
    for i = 1:length(seq)
        new_job = seq[i]
        C = max(C+ S[old_job+1, new_job+1], r[new_job]) + p[new_job]
        if C > d_bar[new_job]
            return 0.0
        end
        T = max(0, C-d[new_job])
        total_r += max(0.0, e[new_job]-T*w[new_job])
        old_job = new_job
    end
    return total_r
end
