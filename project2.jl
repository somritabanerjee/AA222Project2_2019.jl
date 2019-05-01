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
    x_best = penalty_method(f, p, x0, n) # TODO CHANGE TO n
    # y_best = f(x_best)
    # cs = c(x_best)
    # if all(cs.<=0)
    #     print("Constraints satisfied\n")
    # end

    # for i in 1 : floor(n/3)-1
    #     x_next = x_best + randn(length(x_best)) .* g(x_best)
    #     y_next = f(x_next)
    #     if y_next < y_best && all(c(x_next) .<= 0)
    #         x_best, y_best = x_next, y_next
    #     end
    # end
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
    hj_max_eval = 10
    pen_max_eval = n/(2*hj_max_eval)
    for k in 1 : pen_max_eval
        new_f = x -> f(x) + ρ*p(x)
        x = hooke_jeeves(new_f, p, x, hj_max_eval)
        # x = minimize(x -> f(x) + ρ*p(x), x)
        ρ *= γ
    end
    return x
end

function optimizeHookeJeeves(f, g, x0, n, prob)
    α = 1;
    x_best = hooke_jeeves(f, x0, α, n)
    return x_best
end

basis(i, n) = [k == i ? 1.0 : 0.0 for k in 1 : n]

function hooke_jeeves(f, p, x, maxEval; α=1, γ=0.5)
    y, n = f(x), length(x)
    last_x_feas = x
    if p(x)==0
        feasFound = true
        currXFeas = true
    else
        feasFound = false
        currXFeas = false
    end
    evalsLeft = maxEval - 1
    while evalsLeft > 0
        improved = false
        for i in 1 : n
            x′ = x + α*basis(i, n)
            if evalsLeft <= 0
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
            y′ = f(x′)
            evalsLeft = evalsLeft - 1
            if y′ < y
                x, y, improved = x′, y′, true
                if p(x)==0
                    last_x_feas = x
                    feasFound = true
                    currXFeas = true
                else
                    currXFeas = false
                end
            else
                x′ = x - α*basis(i, n)
                if evalsLeft <= 0
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
                y′ = f(x′)
                evalsLeft = evalsLeft - 1
                if y′ < y
                    x, y, improved = x′, y′, true
                    if p(x)==0
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
    return last_x_feas
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
# optimize(rosenbrock,rosenbrock_gradient,[2,2],20,"simple_1")
