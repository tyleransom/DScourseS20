using Random

Random.seed!(100)

alpha = 0.003
iter = 500
numtimes = 10

function simpleGD(alpha,iter)

    # define the gradient of f(x) = x^4 - 3*x^3 + 2
    gradient(x::Float64) = 4*x^3 - 9*x^2

    # randomly initialize a value to x
    x = floor(rand(Float64)*10) # choose an integer between 0 and 10

    # create a vector to contain all xs for all steps
    xAll = zeros(iter)

    println("Starting value is ",x)
    # gradient descent method to find the minimum
    for i=1:iter
            x -= alpha*gradient(x)
            xAll[i] = x
            # println(x)
    end

    # print result and plot all xs for every iteration
    println("The minimum of f(x) is ", x)

    return nothing
end

for j=1:numtimes
simpleGD(alpha,iter)
end
