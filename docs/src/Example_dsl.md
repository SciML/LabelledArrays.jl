# Example: Nice DiffEq Syntax Without A DSL

Users of the SciML ecosystem are often solving large models with complicated
states and hundreds or thousands of parameters. These models are implemented
using arrays, and those arrays have traditionally been indexed by integers,
such as `p[1]` or `p[1:5]`. Numerical indexing is wonderful for small
models, but can quickly cause problems as models become bigger. It is easy to
forget which index corresponds to which reaction rate or which diffusion coefficient.
This confusion can lead to difficult to debug problems in a user's code. `LabelledArrays`
can make an important difference here. It is much easier to build a model using parameter
references such as `p.rate_nacl` or `p.probability_birth`, instead
of `p[26]` or `p[1026]`. Labelled arrays make both the development and debugging of models
much faster.

LabelledArrays.jl are a way to get DSL-like syntax without a macro. In this case,
we can solve differential equations with labelled components by making use of
labelled arrays, and always refer to the components by name instead of index.

One key caveat is that users do not need to sacrifice performance when using
labelled arrays. Labelled arrays are as performant as traditional numerically
indexed arrays.

Let's solve the Lorenz equation using an `LVector`s. `LVectors` are
mutable. Hence, we can use the non-allocating form of the `OrdinaryDiffEq`
API.

```julia
using LabelledArrays, OrdinaryDiffEq

function lorenz_f!(du, u, p, t)
    du.x = p.σ * (u.y - u.x)
    du.y = u.x * (p.ρ - u.z) - u.y
    du.z = u.x * u.y - p.β * u.z
end

u0 = @LArray [1.0, 0.0, 0.0] (:x, :y, :z)
p = @LArray [10.0, 28.0, 8 / 3] (:σ, :ρ, :β)
tspan = (0.0, 10.0)
prob = ODEProblem(lorenz_f!, u0, tspan, p)
sol = solve(prob, Tsit5())
# Now the solution can be indexed as .x/y/z as well!
sol[10].x
```

In the example above, we used an `LArray` to define the
initial state `u0` as well as the parameter vector `p`.
The reminder of the ODE solution steps are no different
that the original `DifferentialEquations` [tutorials](https://docs.sciml.ai/DiffEqDocs/stable/tutorials/ode_example/#Example-2:-Solving-Systems-of-Equations).

Alternatively, we can use an immutable `SLVector` to
implement the same equation. In this case, we need to
use the allocating form of the `OrdinaryDiffEq` API when
defining our model equation.

```julia
LorenzVector = @SLVector (:x, :y, :z)
LorenzParameterVector = @SLVector (:σ, :ρ, :β)

function f(u, p, t)
    x = p.σ * (u.y - u.x)
    y = u.x * (p.ρ - u.z) - u.y
    z = u.x * u.y - p.β * u.z
    LorenzVector(x, y, z)
end

u0 = LorenzVector(1.0, 0.0, 0.0)
p = LorenzParameterVector(10.0, 28.0, 8 / 3)
tspan = (0.0, 10.0)
prob = ODEProblem(f, u0, tspan, p)
sol = solve(prob, Tsit5())
```
