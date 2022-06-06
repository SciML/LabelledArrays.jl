# Example: Nice DiffEq Syntax Without A DSL

LabelledArrays.jl are a way to get DSL-like syntax without a macro. In this case,
we can solve differential equations with labelled components by making use of
labelled arrays, and always refer to the components by name instead of index.

Let's solve the Lorenz equation. Using `@LVector`s, we can do:

```julia
using LabelledArrays, OrdinaryDiffEq

function lorenz_f(du,u,p,t)
  du.x = p.σ*(u.y-u.x)
  du.y = u.x*(p.ρ-u.z) - u.y
  du.z = u.x*u.y - p.β*u.z
end

u0 = @LArray [1.0,0.0,0.0] (:x,:y,:z)
p = @LArray [10.0, 28.0, 8/3]  (:σ,:ρ,:β)
tspan = (0.0,10.0)
prob = ODEProblem(lorenz_f,u0,tspan,p)
sol = solve(prob,Tsit5())
# Now the solution can be indexed as .x/y/z as well!
sol[10].x
```

We can also make use of `@SLVector`:

```julia
LorenzVector = @SLVector (:x,:y,:z)
LorenzParameterVector = @SLVector (:σ,:ρ,:β)

function f(u,p,t)
  x = p.σ*(u.y-u.x)
  y = u.x*(p.ρ-u.z) - u.y
  z = u.x*u.y - p.β*u.z
  LorenzVector(x,y,z)
end

u0 = LorenzVector(1.0,0.0,0.0)
p = LorenzParameterVector(10.0,28.0,8/3)
tspan = (0.0,10.0)
prob = ODEProblem(f,u0,tspan,p)
sol = solve(prob,Tsit5())
```