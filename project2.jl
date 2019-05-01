using Random

"""

Arguments:
    - `f`: Function to be optimized
    - `g`: Gradient function for `f`
    - `c`: Constraints function. Evaluates all the constraint equations and return a Vector of values
    - `x0`: (Vector) Initial position to start from
    - `n`: (Int) Number of evaluations allowed. Remember `g` costs twice of `f`
    - `prob`: (String) Name of the problem. So you can use a different strategy for each problem
"""
function optimize(f, g, c, x0, n, prob)
    p = squared_sum_penalty_function(c)
    x_best = penalty_method(f, p, x0, n)
    return x_best
end

function sum_penalty_function(c)
    f = function(x) 
        ceval = c(x)
        sum(ceval[ceval .> 0])
    end
    return f
end

function squared_sum_penalty_function(c)
    f = function(x) 
        ceval = c(x)
        sum(ceval[ceval .> 0].^2)
    end
    return f
end

function penalty_method(f, p, x, n; ρ=1, γ=2)
    numEvalsLeft = n
    hj_max_eval = 10;
    while numEvalsLeft >= hj_max_eval
        x, evalsUsed, feasFound = hooke_jeeves(f, ρ, p, x, hj_max_eval)
        numEvalsLeft = numEvalsLeft - evalsUsed
        ρ *= γ
    end
    return x
end

function last_feasible_x(currXFeas, x, feasFound, last_x_feas)
    if currXFeas
        return x
    else
        if !feasFound 
            return x 
        else
            return last_x_feas
        end
    end
end

basis(i, n) = [k == i ? 1.0 : 0.0 for k in 1 : n]


function hooke_jeeves(f, ρ, p, x, maxEval; α=1, γ=0.5)
    xf = f(x)
    xp = p(x)
    y, m = xf + ρ*xp, length(x)
    evalsUsed = 1
    last_x_feas = x
    if xp==0
        feasFound = true
        currXFeas = true
    else
        feasFound = false
        currXFeas = false
    end    
    while evalsUsed < maxEval
        improved = false
        for i in 1 : m
            x′ = x + α*basis(i, m)
            if evalsUsed >= maxEval
                return last_feasible_x(currXFeas, x, feasFound, last_x_feas), evalsUsed, feasFound
            end
            xf′ = f(x′)
            xp′ = p(x′)
            y′ = xf′ + ρ*xp′
            evalsUsed = evalsUsed + 1
            if y′ < y
                x, y, improved = x′, y′, true
                if xp′==0
                    last_x_feas = x
                    feasFound = true
                    currXFeas = true
                else
                    currXFeas = false
                end
            else
                x′ = x - α*basis(i, m)
                if evalsUsed >= maxEval
                    return last_feasible_x(currXFeas, x, feasFound, last_x_feas), evalsUsed, feasFound
                end
                xf′ = f(x′)
                xp′ = p(x′)
                y′ = xf′ + ρ*xp′
                evalsUsed = evalsUsed + 1
                if y′ < y
                    x, y, improved = x′, y′, true
                    if xp′==0
                        last_x_feas = x
                        feasFound = true
                        currXFeas = true
                    else
                        currXFeas = false
                    end
                end
            end
        end
        if !improved
            α *= γ
        end
    end
    return last_x_feas, evalsUsed, feasFound
end


# function simple1(x::Vector)
#     return -x[1] * x[2]
# end

# function grad(x::Vector)
#     return 0
# end

# function simple1_constraints(x::Vector)
#     return [x[1] + x[2]^2 - 1,
#             -x[1] - x[2]]
# end

# function simple1_init()
#     return rand(2) * 2.0
# end

# optimize(simple1, grad, simple1_constraints, simple1_init(), 1000, "simple_1")
