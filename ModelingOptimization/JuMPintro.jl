
using JuMP, GLPK


# wrap all of our code inside a function (for better performance)
function example_basic()
    
    # define model and optimizer
    model = Model(GLPK.Optimizer)
    
    # define variables
    @variable(model, 0 <= x <= 2)
    @variable(model, 0 <= y <= 30)

    # define objective function
    @objective(model, Max, 5x + 3y)
    
    # add additional constraints
    @constraint(model, 1x + 5y <= 3.0)

    # display the model
    print(model)
    
    # optimize the model
    JuMP.optimize!(model)

    # return and print objective function and optimal values of variables
    obj_value = JuMP.objective_value(model)
    x_value = JuMP.value(x)
    y_value = JuMP.value(y)
    println("Objective value: ", obj_value)
    println("x = ", x_value)
    println("y = ", y_value)
end


# call the function defined above
example_basic()

using JuMP, GLPK
function example_sudoku()
    
    # input the initial puzzle board (0s mean blanks)
    initial_grid = [
                    3 1 0 0 5 8 0 0 4;
                    0 0 9 3 2 0 0 0 0;
                    0 2 5 1 0 4 0 9 0;
                    0 0 0 0 0 0 3 8 9;
                    0 0 8 0 0 0 5 0 0;
                    5 4 6 0 0 0 0 0 0;
                    0 8 0 2 0 3 6 5 0;
                    0 0 0 0 7 1 4 0 0;
                    7 0 0 4 8 0 0 2 1
                    ]

    # use GLPK Optimizer
    model = Model(GLPK.Optimizer)
    
    # Set up the variables: each one can only take on binary values, so we add "Bin" to the end as a constraint
    @variable(model, x[1:9, 1:9, 1:9], Bin)

    # Add the constraints
    @constraints(model, begin
                     # Constraint 1 - Only one value appears in each cell
                     cell[i in 1:9, j in 1:9], sum(x[i, j, :]) == 1
                     # Constraint 2 - Each value appears in each row once only
                     row[i in 1:9, k in 1:9], sum(x[i, :, k]) == 1
                     # Constraint 3 - Each value appears in each column once only
                     col[j in 1:9, k in 1:9], sum(x[:, j, k]) == 1
                     # Constraint 4 - Each value appears in each 3x3 subgrid once only
                     subgrid[i=1:3:7, j=1:3:7, val=1:9], sum(x[i:i + 2, j:j + 2, val]) == 1
                 end)

    # Add additional constraints that reflect the starting point of the puzzle board
    # (i.e. don't attempt to update the numbers that were given as part of the puzzle)
    for row in 1:9, col in 1:9
        if initial_grid[row, col] != 0
            @constraint(model, x[row, col, initial_grid[row, col]] == 1)
        end
    end

    # Solve it
    JuMP.optimize!(model)

    term_status = JuMP.termination_status(model)
    primal_status = JuMP.primal_status(model)
    is_optimal = term_status == MOI.OPTIMAL

    # Check solution
    if is_optimal
        mip_solution = JuMP.value.(x)
        sol = zeros(Int, 9, 9)
        for row in 1:9, col in 1:9, val in 1:9
            if mip_solution[row, col, val] >= 0.9
                sol[row, col] = val
            end
        end
        return sol
    else
        error("The solver did not find an optimal solution.")
    end
end

function print_sudoku_solution(solution)
    println("Solution:")
    println("[-----------------------]")
    for row in 1:9
        print("[ ")
        for col in 1:9
            print(solution[row, col], " ")
            if col % 3 == 0 && col < 9
                print("| ")
            end
        end
        println("]")
        if row % 3 == 0
            println("[-----------------------]")
        end
    end
end

sol = example_sudoku()
print_sudoku_solution(sol)

using HTTP, JuliaDB, JuMP, GLPK

# first function: read in the player data from the class GitHub repository
function read_in_data(url)
    newtable  = csvread(IOBuffer(HTTP.get(url).body), skiplines_begin=0, header_exists=true)
    players   = newtable[1][2]
    salaries  = newtable[1][4]./1000000
    ppg       = newtable[1][11]
    return players,salaries,ppg
end

function SolveModel(players,salary,points)
    N = length(salary) 
    
    m = Model(GLPK.Optimizer)

    # define the variables: they are 0 if the player did not make the team, 1 if the player did make the team
    @variable(m, picked[1:N], Bin)

    # categories: 
    @objective(m, Max, sum( points[i] * picked[i] for i in 1:N)) 

    @constraints m begin
        # Constraint 1 - payroll <= 132.6m
        sum(salary[i] * picked[i] for i in 1:N) <= 132.6
        # Constraint 2 - must have exactly 15 players on roster
        sum(picked[i] for i in 1:N) == 15
    end

    # Solve it
    JuMP.optimize!(m);
    pck     = convert(BitArray,JuMP.value.(picked))
    lineup  = players[pck]
    points  = JuMP.objective_value(m)
    payroll = sum(salary[pck])
    return lineup,points,payroll
end

# call first function (to import data)
players,salaries,pts = read_in_data("https://raw.githubusercontent.com/tyleransom/DScourseS20/master/WebData/playerSalaryStats.csv")

# pass data into second function to get optimal lineup
lineup,total_points,payroll = SolveModel(players,salaries,pts)
println("team: ",lineup)
println("total points scored per game: ",total_points)
println("payroll: ",payroll)

# first function: read in the player data from the class GitHub repository
function read_in_data(url)
    newtable = csvread(IOBuffer(HTTP.get(url).body), skiplines_begin=0, header_exists=true)
    players  = newtable[1][2]
    salaries = newtable[1][4]./1000000
    mpg      = newtable[1][5]
    fgaG5    = 1.0.*((newtable[1][9]).>5)
    fga      = newtable[1][9]
    ppg      = newtable[1][11]
    return players,salaries,mpg,fgaG5,fga,ppg
end

function SolveModel(players,salary,minutes,field_goals_over5,field_goals,points)
    N = length(salary) 
    
    m = Model(GLPK.Optimizer)

    # define the variables: they are 0 if the player did not make the team, 1 if the player did make the team
    @variable(m, picked[1:N], Bin)

    # categories: 
    @objective(m, Max, sum( points[i] * picked[i] for i in 1:N)) 

    @constraints m begin
        # Constraint 1 - payroll <= 132.6m
        sum(salary[i] * picked[i] for i in 1:N) <= 132.6
        # Constraint 2 - must have exactly 15 players on roster
        sum(picked[i] for i in 1:N) == 15
        # Constraint 3 - total minutes must not exceed 240
        sum(minutes[i] * picked[i] for i in 1:N) <= 240
        # Constraint 4 - total shot attempts must be lower than 80
        sum(field_goals[i] * picked[i] for i in 1:N) <= 80
    end

    # Solve it
    JuMP.optimize!(m);
    pck      = convert(BitArray,JuMP.value.(picked))
    lineup   = players[pck]
    totmin   = sum(minutes[pck])
    payroll  = sum(salary[pck])
    totshots = sum(field_goals[pck])
    points   = JuMP.objective_value(m)
    return lineup,points,totmin,payroll,totshots
end

# call first function (to import data)
players,salaries,minutes,over5fg,fga,pts = read_in_data("https://raw.githubusercontent.com/tyleransom/DScourseS20/master/WebData/playerSalaryStats.csv")

# pass data into second function to get optimal lineup
lineup,total_points,total_minutes,payroll,totshots = SolveModel(players,salaries,minutes,over5fg,fga,pts)
println("team: ",lineup)
println("total points scored per game: ",total_points)
println("payroll: ",payroll)
println("total shots per game: ",totshots)
println("total minutes per game: ",total_minutes)

using HTTP, JuliaDB, JuMP, Ipopt
function import_auto(url)
    newtable  = csvread(IOBuffer(HTTP.get(url).body), skiplines_begin=0, header_exists=true)
    depvar    = log.(newtable[1][2]) # log price
    indepvars = cat(ones(size(depvar)),newtable[1][3],newtable[1][5],newtable[1][6]; dims=2) # constant, mpg, headroom, trunk
    return depvar,indepvars
end

Y,X = import_auto("https://tyleransom.github.io/teaching/MetricsLabs/auto.csv")


function jumpOLS(Y,X,startval=zeros(size(X,2),1))
    OLS = Model(Ipopt.Optimizer)
    
    # Declare the variables you are optimizing over
    @variable(OLS, b[i=1:size(X,2)], start = startval[i])
    
    # Write your objective function
    @NLobjective(OLS, Min, sum( (Y[i]-sum( X[i,k]*b[k] for k in 1:size(X,2) ))^2 for i in 1:size(X,1) ) )
    
    # Solve the objective function
    JuMP.optimize!(OLS)
    
    SSR = JuMP.objective_value(OLS)
    b_value = JuMP.value.(b)
    println("Objective value: ", SSR)
    println("beta hat = ", b_value)
    println("RMSE = ", sqrt(SSR/(size(X,1)-size(X,2))))
end

jumpOLS(Y,X)

