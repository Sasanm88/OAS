function Read_one_instance(order::Int, Tao::Int, R::Int, instance::Int)
    filename = joinpath(@__DIR__, "Dataset_OAS/$(order)orders/Tao$(Tao)/R$(R)/Dataslack_$(order)orders_Tao$(Tao)R$(R)_$instance.txt")
    f = open(filename, "r")
    lines = readlines(f)
    r_ = split(lines[1], ",")
    n_jobs = length(r_) - 2
    r = parse.(Int, r_[2:n_jobs+1])
    p = parse.(Int, split(lines[2], ",")[2:n_jobs+1])
    d = parse.(Int, split(lines[3], ",")[2:n_jobs+1])
    d_bar = parse.(Int, split(lines[4], ",")[2:n_jobs+1])
    e = parse.(Int, split(lines[5], ",")[2:n_jobs+1])
    w = parse.(Float64, split(lines[6], ",")[2:n_jobs+1])
    S= zeros(Int, (n_jobs+2,n_jobs+2))
    for i=7:length(lines)
        S[i-6,:] = parse.(Int, split(lines[i], ","))
    end
    return r, p, d, d_bar, e, w, S
end


function Read_and_print(order::Int, Tao::Int, R::Int, instance::Int)
    filename = joinpath(@__DIR__, "Dataset_OAS/$(order)orders/Tao$(Tao)/R$(R)/Dataslack_$(order)orders_Tao$(Tao)R$(R)_$instance.txt")
    f = open(filename, "r")
    lines = readlines(f)
    r_ = split(lines[1], ",")
    n_jobs = length(r_) - 2
    r = parse.(Int, r_[2:n_jobs+1])
    p = parse.(Int, split(lines[2], ",")[2:n_jobs+1])
    d = parse.(Int, split(lines[3], ",")[2:n_jobs+1])
    d_bar = parse.(Int, split(lines[4], ",")[2:n_jobs+1])
    e = parse.(Int, split(lines[5], ",")[2:n_jobs+1])
    w = parse.(Float64, split(lines[6], ",")[2:n_jobs+1])
    S= zeros(Int, (n_jobs+2,n_jobs+2))
    for i=7:length(lines)
        S[i-6,:] = parse.(Int, split(lines[i], ","))
    end
    names = ["r", "p", "d", "d_bar", "e", "w"]
    for (i,seq) in enumerate([r, p, d, d_bar, e, w])
        println()
        print(names[i],": ")
        for j in seq
            print(j,", ")
        end
    end
    println()
    println("S=")
    for i=1:n_jobs+2
        for j = 1:n_jobs+2
            print(S[i,j], "  ")
        end
        println()
    end

end