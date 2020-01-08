using Optim

## initial values
x0 = -5.0*ones(1)

## Our objective function
objfun(x) = x[1]^4 - 3.0*x[1]^3 + 2.0

## Find the optimum!
result = optimize(objfun, x0, LBFGS())
println("minimum value is: ",result.minimizer)
println("obj value at minimum is: ",result.minimum)

## Now do Particle Swarm (derivative-free method)
result = optimize(objfun, x0, ParticleSwarm())
println("minimum value is: ",result.minimizer)
println("obj value at minimum is: ",result.minimum)
