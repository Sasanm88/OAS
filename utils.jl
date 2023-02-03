using Random
using XLSX

mutable struct Country
    representation::Vector{Int}
    power::Float64
end
        

mutable struct Empire
    emperor::Country
    colonies::Vector{Country}
    power::Float64
end

function Find_best_solution(empires::Vector{Empire})
    best_obj = 0.0
    best_rep = Int[]
    for emp in empires
        if emp.emperor.power > best_obj
            best_obj = emp.emperor.power
            best_rep = emp.emperor.representation
        end
    end
    return Convert_to_sequence(best_rep)
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
        C = max(C, r[new_job]) + S[old_job+1, new_job+1] + p[new_job]
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
    C = 0.0
    old_job = 0
    for i = 1:length(seq)
        new_job = seq[i]
        C = max(C, r[new_job]) + S[old_job+1, new_job+1] + p[new_job]
        T = max(0.0, C-d[new_job])
        total_r += max(0.0, e[new_job]-T*w[new_job])
        old_job = new_job
    end
    return total_r
end


function Calculate_from_sequence(seq::Vector{Int}, r::Vector{Int64}, p::Vector{Int64}, d::Vector{Int64}, d_bar::Vector{Int64}, e::Vector{Int64}, w::Vector{Float64}, S::Matrix{Int64})
    total_r = 0.0
    C = 0.0
    old_job = 0
    for i = 1:length(seq)
        new_job = seq[i]
        C = max(C, r[new_job]) + S[old_job+1, new_job+1] + p[new_job]

        T = max(0.0, C-d[new_job])
        total_r += max(0.0, e[new_job]-T*w[new_job])
        old_job = new_job
    end
    return total_r
end


function Write_to_excel(exfile::String, sheetnumber::Int, row::Int, t0::Float64, tN::Float64, order::Int, Tao::Int, R::Int, best::Float64, time::Float64)

    XLSX.openxlsx(exfile, mode="rw") do xf
        sheet = xf[sheetnumber]
        sheet["A"*string(1)] = "t0"
        sheet["B"*string(1)] = t0
        sheet["C"*string(1)] = "tN"
        sheet["D"*string(1)] = tN
        sheet["A"*string(2)] = "order"
        sheet["B"*string(2)] = "Tao"
        sheet["C"*string(2)] = "R"
        sheet["D"*string(2)] = "Obj"
        sheet["E"*string(2)] = "Time"
        sheet["A"*string(row)] = order
        sheet["B"*string(row)] = Tao
        sheet["C"*string(row)] = R
        sheet["D"*string(row)] = best
        sheet["E"*string(row)] = time
    end
end

function Write_to_excel_new(exfile::String, sheetnumber::Int, row::Int, Tao::Int, R::Int, instance::Int, 
     objs::Vector{Float64}, run_times::Vector{Float64})
    sheetnumber = 1
    obj_chars = ["D", "F", "H", "J", "L", "N", "P", "R", "T", "V"]
    time_chars = ["E", "G", "I", "K", "M", "O", "Q", "S", "U", "W"]
    XLSX.openxlsx(exfile, mode="rw") do xf
        sheet = xf[sheetnumber]
        sheet["A"*string(1)] = "Tao"
        sheet["B"*string(1)] = "R"
        sheet["C"*string(1)] = "Instance"
        sheet["A"*string(row)] = Tao
        sheet["B"*string(row)] = R
        sheet["C"*string(row)] = instance

        for i=1:10
            sheet[obj_chars[i]*string(1)] = "Obj "* string(i)
            sheet[time_chars[i]*string(1)] = "Time "* string(i)
            sheet[obj_chars[i]*string(row)] = objs[i]
            sheet[time_chars[i]*string(row)] = run_times[i]
        end
    end
end


function Calculate_Comp_times(seq::Vector{Int}, r::Vector{Int64}, p::Vector{Int64}, S::Matrix{Int64})
    comp = Float64[]
    C = 0
    old_job = 0
    for i = 1:length(seq)
        new_job = seq[i]
        C = max(C, r[new_job]) + S[old_job+1, new_job+1] + p[new_job]
        old_job = new_job
        push!(comp, C)
    end
    return comp
end