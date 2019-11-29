using PushGP: PushInterpreter, execute!, stack, last, length, Add, Mul, Sub, Div, AfromB

@testset "Examples used in PushGP.jl README" begin

@testset "Example 1" begin
    simple_program = [2, 5, Add{Int}()]

    i = PushInterpreter()
    ret = execute!(i, simple_program)
    @test ret === nothing

    intstack = stack(i, Int)
    @test isa(intstack, PushGP.Stack{Int})
    @test last(intstack) == 7
    @test length(intstack) == 1
end

@testset "Example 2" begin
    # We assume we are continuing after example 1 above but to ensure tests
    # can be run out of order we rerun its example
    i = PushInterpreter()
    simple_program = [2, 5, Add{Int}()]
    execute!(i, simple_program)

    # Now we continue with example 2:
    execute!(i, [6.5, 5, Sub{Int}(), 2.0, Mul{Float64}(), 4.0, Div{Float64}(), AfromB{String,Float64}(), 1.7])
    @test last(stack(i, Int)) == 2 # 7 (from before) - 5
    @test length(stack(i, Int)) == 1
    @test last(stack(i, String)) == "3.25" # string((2.0 * 6.5) / 4.0)
    @test length(stack(i, String)) == 1
    @test last(stack(i, Float64)) == 1.7
    @test length(stack(i, Float64)) == 1
end
end # @testset "Examples from PushGP docs" begin
