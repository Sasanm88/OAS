function Find_Powers_of_Empires(Empires::Vector{Empire}, eps::Float64)
    for emp in Empires
        colony_power = 0.0
        for colony in emp.colonies
            colony_power += colony.power
        end
        emp.power = emp.emperor.power + eps * colony_power
    end
end

function Outer_Competition(Empires::Vector{Empire}, eps::Float64)
    Find_Powers_of_Empires(Empires, eps)
    sort!(Empires, by=x->x.power, rev=true)
    for emp in Empires
        sort!(emp.colonies, by=x->x.power, rev=true)
    end
    n_emp = length(Empires)
    if length(Empires[n_emp].colonies) > 0
        worst_colony = pop!(Empires[n_emp].colonies)
    else
        worst_colony = Empires[n_emp].emperor
        pop!(Empires)
    end
    Empires_powers = [emp.power for emp in Empires]
    Normal_total_cost = Empires_powers .- minimum(Empires_powers)
    Total_P = Normal_total_cost ./ sum(Normal_total_cost)
    R = Total_P - rand(length(Total_P))
    strongest_empire = argmax(Total_P)
    if worst_colony.power > Empires[strongest_empire].emperor.power
        temp = deepcopy(Empires[strongest_empire].emperor)
        Empires[strongest_empire].emperor = worst_colony
        push!(Empires[strongest_empire].colonies, temp)
    else
        push!(Empires[strongest_empire].colonies, worst_colony)
    end
    return Empires, [emp.emperor.power for emp in Empires]
end
