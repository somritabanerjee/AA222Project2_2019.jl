using Random
using Plots 
pyplot(size = (600,1100), legend = true)
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
    x_best, xlist,fpvalues = penalty_method(f, p, x0, n)
    return x_best
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
    xlist = Array{Float64}[]
    fpvalues = Array{Float64}[]
    push!(xlist, x)
    while numEvalsLeft >= hj_max_eval
        x, evalsUsed, newFeasFound, fpvalues = hooke_jeeves(f, ρ, p, x, hj_max_eval, fpvalues)
        push!(xlist, x)
        numEvalsLeft = numEvalsLeft - evalsUsed
        # if !newFeasFound
        #     ρ /= γ
        # else
            ρ *= γ
        # end
    end
    return x,xlist,fpvalues
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


function hooke_jeeves(f, ρ, p, x, maxEval, fpvalues; α=0.2, γ=0.1)
    xf = f(x)
    xp = p(x)
    push!(fpvalues,[xf,xp])
    y, m = xf + ρ*xp, length(x)
    evalsUsed = 1
    last_x_feas = x
    newFeasFound = false
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
                return last_feasible_x(currXFeas, x, feasFound, last_x_feas), evalsUsed, newFeasFound, fpvalues
            end
            xf′ = f(x′)
            xp′ = p(x′)
            push!(fpvalues,[xf′,xp′])
            y′ = xf′ + ρ*xp′
            evalsUsed = evalsUsed + 1
            if y′ < y
                x, y, improved = x′, y′, true
                if xp′==0
                    last_x_feas = x
                    newFeasFound = true
                    feasFound = true
                    currXFeas = true
                else
                    currXFeas = false
                end
            else
                x′ = x - α*basis(i, m)
                if evalsUsed >= maxEval
                    return last_feasible_x(currXFeas, x, feasFound, last_x_feas), evalsUsed, newFeasFound, fpvalues
                end
                xf′ = f(x′)
                xp′ = p(x′)
                push!(fpvalues,[xf′,xp′])
                y′ = xf′ + ρ*xp′
                evalsUsed = evalsUsed + 1
                if y′ < y
                    x, y, improved = x′, y′, true
                    if xp′==0
                        last_x_feas = x
                        newFeasFound = true
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
    return last_x_feas, evalsUsed, newFeasFound, fpvalues
end

function grad(x::Vector)
    return 0
end

function simple1(x::Vector)
    return -x[1] * x[2]
end

function simple1_constraints(x::Vector)
    return [x[1] + x[2]^2 - 1,
            -x[1] - x[2]]
end

function simple1_init()
    return rand(2) * 2.0
end

function simple2(x::Vector)
    return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end

function simple2_constraints(x::Vector)
    return [(x[1]-1)^3 - x[2] + 1,
            x[1] + x[2] - 2]
end

function simple2_init()
    return rand(2) .* 2.0 .- 1.0
end

function simple3(x::Vector)
    return x[1] - 2*x[2] + x[3]
end

function simple3_constraints(x::Vector)
    return [x[1]^2 + x[2]^2 + x[3]^2 - 1]
end

function simple3_init()
    b = 2.0 .* [1.0, -1.0, 0.0]
    a = -2.0 .* [1.0, -1.0, 0.0]
    return rand(3) .* (b-a) + a
end

function get_full_list(f, g, c, x0, n, prob)
    p = squared_sum_penalty_function(c)
    x_best, xlist, fpvalues = penalty_method(f, p, x0, n)
    return x_best, xlist, fpvalues
end


function create_path_plot(problemNumber, fn, constr, numConstr, lvls, initial_points, true_min, xMin, xMax, yMin, yMax, lineColors, contourColors)
    pyplot(size = (600,1000), legend = true)
    # Plot function contours
    x = xMin:0.1:xMax
    y = yMin:0.1:yMax
    f(x, y) = begin
            fn([x,y])
        end
    p1 = contour(x, y, f, fill=false, seriescolor=:grays,w=3, label="function")

    # Plot constraint contours
    for i in 1:numConstr
        c(x, y) = begin
            simple1_constraints([x,y])[i]
        end
        scolor = contourColors[i]
        contour!(x, y, c, seriescolor=scolor, w=2,  levels=lvls)
    end

    # Plot true minimum
    scatter!([true_min[1]],[true_min[2]],markercolor=:green,markersize=8,label="true minimum")


    for i in 1:size(initial_points,1)
        x0 = initial_points[i]
        lineColor = lineColors[i]

        # Plot initial point
        scatter!([x0[1]],[x0[2]],marker=:d,markersize=5,markercolor=lineColor,label="initial point")

        # Plot trajectory and final point
        x_best, xlist, _  = get_full_list(simple1, grad, simple1_constraints, x0, 1000, "simple_1")
        xnlist=hcat(xlist...)'
        plot!(xnlist[:,1],xnlist[:,2], color=lineColor, marker=:dot, label="path of feasible points", w=2)
        scatter!([x_best[1]],[x_best[2]],marker=:d,markersize=5,markercolor=:red, label="best found")
    end
    title!("Simple $problemNumber path taken")
    return p1
end


problemNumber = 1
fn = simple1
constr = simple1_constraints
numConstr = 2
lvls = [-2, -1, 0]
initial_points1 = [[1.51183, 1.63151],  
 [0.447248, 0.233549],
 [1.09013, 0.345318]]
# for i in 1:3
#     initial_points[i] = simple1_init()
# end
true_min = [2.0/3.0; 1.0/sqrt(3)]
xMin = -2
xMax = 2
yMin = -2 
yMax = 2
lineColors = [:indigo, :orchid, :lightpink]
contourColors = [:blues, :reds, :greens]

p1 = create_path_plot(problemNumber, fn, constr, numConstr, lvls, initial_points1, true_min, xMin, xMax, yMin, yMax, lineColors, contourColors)



problemNumber = 2
fn = simple2
constr = simple2_constraints
lvls = [-3, -2, -1, 0]
initial_points2 = [[-0.303123, 0.733811], 
 [-0.807351, -0.710301],
 [-0.450702, 0.209268]]
# for i in 1:3
#     initial_points[i] = simple2_init()
# end
true_min = [1;1]
p2 = create_path_plot(problemNumber, fn, constr, numConstr, lvls, initial_points2, true_min, xMin, xMax, yMin, yMax, lineColors, contourColors)

plt1 = plot(p1,p2,layout=(2,1))
gui(plt1)

function create_convergence_plot(fpvalues, problemNumber)
    pyplot(size = (1000,1000), legend = true)
    fp=hcat(fpvalues...)'
    colors = [:green, :red]
    color = fp[2,2] <= 0 ? colors[1] : colors[2]
    firstRed = false
    firstGreen = false
    p1 = plot(fp[:,1], label= "", color = :black)
    # p2=plot([1],[fp[1,1]],marker=:circle, markersize=5, color=(fp[1,2] <= 0 ? colors[1] : colors[2]), label = "")
    for i in 1:size(fp,1)
        lbl = ""
        if !firstRed && fp[i,2] > 0
            lbl = "infeasible"
            firstRed = true
        elseif !firstGreen && fp[i,2] <= 0
            lbl = "feasible"
            firstGreen = true
        end

        plot!([i],[fp[i,1]],marker=:circle, markersize=5, color=(fp[i,2] <= 0 ? colors[1] : colors[2]), label = lbl)  
    end
    # plot(p2)
    xlabel!("Iteration number")
    ylabel!("Value of f(x)")
    title!("Simple $problemNumber convergence")
    return p1
end

# xbest, _, fpvalues  = get_full_list(simple1, grad, simple1_constraints, initial_points1[1], 1000, "simple_1")
# problemNumber = 1
# p1 = create_convergence_plot(fpvalues, problemNumber)

# xbest, _, fpvalues  = get_full_list(simple2, grad, simple2_constraints, initial_points2[1], 1000, "simple_2")
# problemNumber = 2
# p2 = create_convergence_plot(fpvalues, problemNumber)


# init3 = [-1.9022234854723372,
#  -1.3978361756095108,
#   0.0]
# xbest, _, fpvalues  = get_full_list(simple3, grad, simple1_constraints, init3, 1000, "simple_3")
# problemNumber = 3
# p3 = create_convergence_plot(fpvalues, problemNumber)

# plt1 = plot(p1,p2,p3,layout=(3,1))
# gui(plt1)