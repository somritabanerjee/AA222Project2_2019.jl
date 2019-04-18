import numpy as np


def optimize(f, g, c, x0, n, prob):
    """
    Arguments:
      - `f`: Function to be optimized
      - `g`: Gradient function for `f`
      - `c`: Constraints function. Evaluates all the constraint equations and return a Vector of values
      - `x0`: (Vector) Initial position to start from
      - `n`: (Int) Number of evaluations allowed. Remember `g` costs twice of `f`
      - `prob`: (String) Name of the problem. So you can use a different strategy for each problem
    """
    x_best = x0
    y_best = f(x0)
    cs = c(x0)
    for i in range(n // 3 - 1):
        x_next = x_best + np.random.randn(*x_best.shape) * g(x_best)
        y_next = f(x_next)
        if y_next < y_best and (np.asarray(c(x_next)) <= 0).all():
            x_best, y_best = x_next, y_next

    return x_best
