module AA222Project2_2019

using JSON
using PyCall
using Random
using Statistics
using ForwardDiff

const project2 = PyNULL()
const err = Ref{String}("")


function append_to_python_search_path(str::AbstractString)
    pushfirst!(PyVector(pyimport("sys")."path"), str)
end

const COUNTERS = Dict{String, Int}()
const PROBS = Dict{String, Dict{Int, Any}}()

"""
Count the number of times a function was evaluated
"""
macro counted(f)
    name = f.args[1].args[1]
    name_str = String(name)
    body = f.args[2]
    update_counter = quote
        if !haskey(COUNTERS, $name_str)
            COUNTERS[$name_str] = 0
        end
        COUNTERS[$name_str] += 1
    end
    insert!(body.args, 1, update_counter)
    return f
end

function check_constraints(c, x::Vector)
    vals = c(x)
    COUNTERS[String(typeof(c).name.mt.name)] -= 1
    return all(vals .<= 0)
end

"""
    get_score(f, g, x_star_hat, n)

Arguments
    - `f`: function
    - `g`: gradient of function
    - `c`: constraint function
    - `x_star_hat`: Found optima
    - `n`: Number of evaluations allowed (f+2g)
Returns
    - `num_evals`
    - `score`
"""
function get_score(f, g, c, x_star_hat, n)
    f_name = String(typeof(f).name.mt.name)
    g_name = String(typeof(g).name.mt.name)
    c_name = String(typeof(c).name.mt.name)

    if haskey(COUNTERS, f_name)
        f_evals = COUNTERS[f_name]
    else
        f_evals = 0
    end

    if haskey(COUNTERS, g_name)
        g_evals = COUNTERS[g_name]
    else
        g_evals = 0
    end

    if haskey(COUNTERS, c_name)
        c_evals = COUNTERS[c_name]
    else
        c_evals = 0
    end

    score = typemin(Int32)
    num_evals = (f_evals + 2*g_evals)
    if check_constraints(c, x_star_hat)
        if num_evals <= n && c_evals <= n
            score = -f(x_star_hat)
            COUNTERS[f_name] -= 1
        end
    else
        err[] = "Constraints not satisfied!"
    end
    return num_evals, c_evals, score
end

if isfile(joinpath(@__DIR__, "simple.jl"))
    include(joinpath(@__DIR__, "simple.jl"))
    PROBS["simple"] = simple_problems
end

"""
    main(mode, pidx, repeat)

Arguments:
    - `mode`: simple or secret
    - `pidx`: problem index
    - `repeat`: Number of Monte Carlo evaluations
Returns:
    - nothing
"""
function main(mode::String, pidx::Int, repeat::Int)
    if mode ∉ ["simple", "secret"]
        err[] = "Invalid mode = $(mode)"
    end
    inseed = 42
    if mode == "simple"
        inseed = 1337
    end

    scores = Float64[]
    errors = String[]
    nevals = Int[]
    cevals = Int[]
    score = 0
    neval = 0
    ceval = 0
    if err[] == ""
        # Repeat the optimization with a different initialization
        for i in 1:repeat
            Random.seed!(inseed + i)
            prob = PROBS[mode][pidx]
            try
                if project2 != PyNULL()
                    opt_func = project2.optimize
                else
                    opt_func = optimize
                end
                if mode == "secret"
                    # Reset the affine_function
                    sz = size(prob.x0(), 1)
                    A[] = randn(sz, sz)
                    b[] = abs.(randn(sz))
                end

                x_star_hat = opt_func(prob.f, prob.g, prob.c, prob.x0(), prob.n, "$(mode)_$(pidx)")
                neval, ceval, score = get_score(prob.f, prob.g, prob.c, x_star_hat, prob.n)
                push!(errors, err[])
            catch e
                push!(errors, "$(e)")
                x_star_hat = typemin(Int32)
                score = typemin(Int32)
                neval = typemin(Int32)
                ceval = typemin(Int32)
            end

            push!(nevals, neval)
            push!(cevals, ceval)
            push!(scores, score)

            for k in keys(COUNTERS)
                delete!(COUNTERS, k)
            end
        end

        # So that we know if there was a problem with a particular seed
        enerrs = enumerate(errors)
        # Filter out empty
        enerrs = filter(x -> x[2] != "", collect(enerrs))
        err[] = join(enerrs, " \n")
    else
        push!(nevals, typemin(Int32))
        push!(cevals, typemin(Int32))
    end
    result = Dict("score" => mean(scores), "error"=> err[])

    open(".results_$(mode)_$(pidx).json", "w") do io
        write(io, JSON.json(result))
    end

    final_score = result["score"]
    max_evals = maximum(nevals)
    max_cevals = maximum(cevals)
    println("===================")
    println("Mode: $(mode)")
    println("Problem: $(pidx)")
    println("-------------------")
    if err[] != ""
        println("Error: $(err[])")
    end
    println("Max Num Function (and Gradient) Evals: $(max_evals)")
    println("Max Num Constraint Function Evals: $(max_cevals)")
    println("Avg Score: $(final_score)")
    println("===================")
end



function __init__()
    if length(ARGS) < 1
        filepath = "project2.jl"
    else
        filepath = ARGS[1]
    end

    if isfile(filepath)
        if filepath[end-1:end] == "jl"
            @info("Including Julia file")
            try
                include(filepath)
            catch e
                err[] = "$(e)"
            end
        elseif filepath[end-1:end] == "py"
            @info("Importing Python file")
            try
                dir = dirname(filepath)
                append_to_python_search_path(dir)
                copy!(project2, pyimport("project2"))
            catch e
                err[] = "$(e)"
            end
        else
            err[] = "Not a correct file type"
        end
    else
        err[] = "File: $(filepath) doesn't exist"
    end
end

end # module
