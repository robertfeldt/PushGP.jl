using PushGP: BoolOr, Dup

@testset "Examples from PushGP docs" begin

@testset "Example 1 from Push3 docs" begin
    # Simple example from the page https://faculty.hampshire.edu/lspector/push3-description.html
    # ( 2 3 INTEGER.* 4.1 5.2 FLOAT.+ TRUE FALSE BOOLEAN.OR )
    interp = PushInterpreter()
    p = [2, 3, Mul{Int}(), 4.1, 5.2, Add{Float64}(), true, false, BoolOr()]
    execute!(interp, p)
    @test length(stack(interp, Bool)) == 1
    @test last(stack(interp, Bool)) == true
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == 9.3
    @test length(stack(interp, Int)) == 1
    @test last(stack(interp, Int)) == 6
end # @testset "Example 1 from Push3 docs" begin

@testset "Example 2 from Push3 docs" begin
    # Example 2 from the page https://faculty.hampshire.edu/lspector/push3-description.html
    # ( 5 1.23 INTEGER.+ ( 4 ) INTEGER.- 5.67 FLOAT.* )
    interp = PushInterpreter()
    p = [5, 1.23, Add{Int}(), [4], Sub{Int}(), 5.67, Mul{Float64}()]
    execute!(interp, p)
    @test length(stack(interp, Int)) == 1
    @test last(stack(interp, Int)) == 1
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == 6.9741
end # @testset "Example 2 from Push3 docs" begin

@testset "Example 3 from Push3 docs" begin
    # Example 3 from the page https://faculty.hampshire.edu/lspector/push3-description.html
    # ( 5 INTEGER.DUP INTEGER.+ )
    interp = PushInterpreter()
    p = [5, Dup{Int}(), Add{Int}()]
    execute!(interp, p)
    @test length(stack(interp, Int)) == 1
    @test last(stack(interp, Int)) == 10
end

end # @testset "Examples from PushGP docs" begin
