using PushGP: hasstack, stackhas, pop2!

@testset "PushInterpreter" begin

@testset "hasstack" begin
    interp = PushInterpreter()
    @test hasstack(interp, Int)
    @test hasstack(interp, Float64)
    @test hasstack(interp, String)
    @test hasstack(interp, Bool)
    @test !hasstack(interp, Vector{Int})
    @test !hasstack(interp, Regex)
end # @testset "hasstack" begin

@testset "stackhas, execute! and pop2!" begin
    interp = PushInterpreter()
    for T in [Int, Float64, String, Bool]
        @test stackhas(interp, T, 0) == true
        for numelems in 1:10
            @test stackhas(interp, T, numelems) == false
        end
    end

    execute!(interp, [1]) # Should add one to the Int stack
    @test stackhas(interp, Int, 0) == true
    @test stackhas(interp, Int, 1) == true
    @test stackhas(interp, Int, 2) == false

    execute!(interp, [4]) # Should add one to the Int stack, now 2 elements on it
    @test stackhas(interp, Int, 0) == true
    @test stackhas(interp, Int, 1) == true
    @test stackhas(interp, Int, 2) == true
    @test stackhas(interp, Int, 3) == false

    a, b = pop2!(interp, Int)
    @test a == 4
    @test b == 1
end # @testset "stackhas" begin

end # @testset "PushInterpreter" begin
