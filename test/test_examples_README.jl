using PushGP: PushInterpreter, execute!, stack, last, length, Add

@testset "Examples used in PushGP.jl README" begin

@testset "Example 1: [2, 5, Add{Int}()]" begin
    simple_program = [2, 5, Add{Int}()]

    i = PushInterpreter()
    ret = execute!(i, simple_program)
    @test ret === nothing

    intstack = stack(i, Int)
    @test isa(intstack, PushGP.Stack{Int})
    @test last(intstack) == 7
    @test length(intstack) == 1
end

end # @testset "Examples from PushGP docs" begin
