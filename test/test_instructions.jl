using PushGP: PushInstruction, inputtypes, outputtypes, neededstacks, hasstacks
using PushGP: numoutputs, arity, name, opname, execute!, oldname, oldopname, desc
using PushGP: PushInstructionA1tA1, Lit, Add, names, Sub, Mul, Div
using PushGP: PushInterpreter, stack

struct EmptyInstr <: PushInstruction end
struct EmptyA1tA1{T} <: PushInstructionA1tA1{T} end

@testset "Instructions: basic" begin
    ei = EmptyInstr()
    @test inputtypes(ei) == DataType[]
    @test outputtypes(ei) == DataType[]
    @test neededstacks(ei) == DataType[]
    @test arity(ei) == 0
    @test numoutputs(ei) == 0
    @test name(ei) == "emptyinstr"
    @test desc(ei) == "emptyinstr"
    @test opname(ei) == "emptyinstr"
    @test oldname(ei) == "EMPTYINSTR"
    @test oldopname(ei) == "EMPTYINSTR"
    
    interp = PushInterpreter()
    @test hasstacks(interp, ei) == true
    @test execute!(ei, interp) === nothing # Default behavior is to be a No-Op

    eia1a1 = EmptyA1tA1{Int}()
    @test inputtypes(eia1a1) == DataType[Int]
    @test outputtypes(eia1a1) == DataType[Int]
    @test neededstacks(eia1a1) == DataType[Int]
    @test arity(eia1a1) == 1
    @test numoutputs(eia1a1) == 1
    @test name(eia1a1) == "int64_emptya1ta1"
    @test desc(eia1a1) == "int64_emptya1ta1"
    @test opname(eia1a1) == "emptya1ta1"
    @test oldname(eia1a1) == "INT64.EMPTYA1TA1"
    @test oldopname(eia1a1) == "EMPTYA1TA1"

    eia1a1_b = EmptyA1tA1{String}()
    @test name(eia1a1_b) == "string_emptya1ta1"
    @test desc(eia1a1_b) == "string_emptya1ta1"
    @test opname(eia1a1_b) == "emptya1ta1"
    @test oldname(eia1a1_b) == "STRING.EMPTYA1TA1"
    @test oldopname(eia1a1_b) == "EMPTYA1TA1"
    @test sort(names(eia1a1_b)) == sort(["STRING.EMPTYA1TA1", "string_emptya1ta1"])
end # @testset "Instructions" begin

@testset "Literal instruction" begin
    li = Lit(23)
    @test inputtypes(li) == DataType[]
    @test outputtypes(li) == DataType[Int]
    @test neededstacks(li) == DataType[Int]
    @test arity(li) == 0
    @test numoutputs(li) == 1
    @test name(li) == "int64_lit"
    @test oldname(li) == "INT64.LIT"
    @test desc(li) == "23"

    interp = PushInterpreter()
    execute!(li, interp)
    @test last(stack(interp, Int)) == 23
    @test length(stack(interp, Int)) == 1
end # @testset "Literal instruction" begin

@testset "Add instruction" begin
    i = Add{Int}()
    @test isa(i, Add{Int})
    @test name(i) == "int64_add"
    @test opname(i) == "add"
    @test oldname(i) == "INT64.+"

    interp = PushInterpreter()
    push!(interp, 1)
    push!(interp, 2)
    execute!(i, interp)
    @test length(stack(interp, Int)) == 1
    @test last(stack(interp, Int)) == 3
end # @testset "Number instructions" begin

@testset "Sub instruction" begin
    i = Sub{Float64}()
    @test isa(i, Sub{Float64})
    @test name(i) == "float64_sub"
    @test opname(i) == "sub"
    @test oldname(i) == "FLOAT64.-"

    interp = PushInterpreter()
    push!(interp, 1.0)
    push!(interp, 2.1)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == (1.0 - 2.1)
end # @testset "Number instructions" begin

@testset "Mul instruction" begin
    i = Mul{Float64}()
    @test isa(i, Mul{Float64})
    @test name(i) == "float64_mul"
    @test opname(i) == "mul"
    @test oldname(i) == "FLOAT64.*"

    interp = PushInterpreter()
    push!(interp, 1.7)
    push!(interp, 2.1)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == (1.7 * 2.1)

    # But we can also multiply strings since Julia uses this to concat...
    # This instruction not available in normal Push languages so is unique to PushGP.jl (to the best of my knowledge).
    i = Mul{String}()
    @test isa(i, Mul{String})
    @test name(i) == "string_mul"
    @test opname(i) == "mul"
    @test oldname(i) == "STRING.*"

    interp = PushInterpreter()
    push!(interp, "a")
    push!(interp, "bc34")
    execute!(i, interp)
    @test length(stack(interp, String)) == 1
    @test last(stack(interp, String)) == "abc34" # Note order
end # @testset "Number instructions" begin

@testset "Div instruction" begin
    i = Div{Float64}()
    @test isa(i, Div{Float64})
    @test name(i) == "float64_div"
    @test opname(i) == "div"
    @test oldname(i) == "FLOAT64./"

    interp = PushInterpreter()
    push!(interp, 1.5)
    push!(interp, 2.0)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == (1.5 / 2.0)

    # Note that if denominator is 0.0 the Div instruction is a No-Op
    interp = PushInterpreter()
    push!(interp, 3.1)
    push!(interp, 0.0)
    @test execute!(i, interp) === nothing
    @test length(stack(interp, Float64)) == 2
    @test last(stack(interp, Float64)) == 0.0
end # @testset "Number instructions" begin
