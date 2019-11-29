using PushGP: Stack

@testset "PushStack" begin

@testset "Stack{Int}" begin
    ist = Stack{Int}()
    @test length(ist) == 0

    @test push!(ist, 1) == Int[1]
    @test length(ist) == 1
    @test last(ist) == 1

    push!(ist, 2)
    push!(ist, 3)
    @test length(ist) == 3

    a, b = pop2!(ist)
    @test a == 3
    @test b == 2

    # Can't push a Float on an Int stack
    @test_throws ErrorException push!(ist, 1.0)
end

@testset "Stack{Float64}" begin
    fst = Stack{Float64}()
    @test length(fst) == 0

    @test push!(fst, 3.14) == Float64[3.14]
    @test length(fst) == 1
    @test last(fst) == 3.14

    push!(fst, 2e-3)
    push!(fst, 3.1e2)
    @test length(fst) == 3

    a, b = pop2!(fst)
    @test a == 3.1e2
    @test b == 2e-3

    # Can't push a Float on an Int stack
    @test_throws ErrorException push!(fst, 1)
end # @testset "Stack{Float64}" begin

@testset "Stack{Bool}" begin
    bst = Stack{Bool}()
    @test length(bst) == 0

    push!(bst, false)
    push!(bst, false)
    push!(bst, true)
    @test length(bst) == 3

    a, b = pop2!(bst)
    @test a === true
    @test b === false

    # Can't push a Float on an Int stack
    @test_throws ErrorException push!(bst, 1)
    @test_throws ErrorException push!(bst, 3.14)
end # @testset "Stack{Bool}" begin

@testset "Stack{String}" begin
    sst = Stack{String}()
    @test length(sst) == 0

    push!(sst, "ab")
    push!(sst, "cde")
    push!(sst, "f")
    @test length(sst) == 3

    a, b = pop2!(sst)
    @test a === "f"
    @test b === "cde"
    
    @test length(sst) == 1
    empty!(sst)
    @test length(sst) == 0

    # Can't push a Float on an Int stack
    @test_throws ErrorException push!(sst, 1)
    @test_throws ErrorException push!(sst, 3.14)
    @test_throws ErrorException push!(sst, true)
end # @testset "Stack{String}" begin

end # @testset "PushStack" begin