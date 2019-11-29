using PushGP: PushInstruction, inputtypes, outputtypes, neededstacks, hasstacks, split_type_name_in_parts
using PushGP: numoutputs, arity, name, opname, execute!, oldname, oldopname, desc
using PushGP: PushInstructionA1tA1, Lit, Add, names, Sub, Mul, Div, AfromB
using PushGP: Dup, Swap, Flush, StackDepth, Eq, Lt, Gt, Mod, Max, Min
using PushGP: PushInterpreter, stack

struct EmptyInstr <: PushInstruction end
struct EmptyA1tA1{T} <: PushInstructionA1tA1{T} end

# To make the tests architecture-independent
const IntStringL = lowercase(string(Int)) # Since it can be Int64 or Int32
const IntStringU = uppercase(string(Int)) # Since it can be Int64 or Int32

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
    @test name(eia1a1) == (IntStringL * "_emptya1ta1")
    @test desc(eia1a1) == (IntStringL * "_emptya1ta1")
    @test opname(eia1a1) == "emptya1ta1"
    @test oldname(eia1a1) == (IntStringU * ".EMPTYA1TA1")
    @test oldopname(eia1a1) == "EMPTYA1TA1"

    eia1a1_b = EmptyA1tA1{String}()
    @test name(eia1a1_b) == "string_emptya1ta1"
    @test desc(eia1a1_b) == "string_emptya1ta1"
    @test opname(eia1a1_b) == "emptya1ta1"
    @test oldname(eia1a1_b) == "STRING.EMPTYA1TA1"
    @test oldopname(eia1a1_b) == "EMPTYA1TA1"
    @test sort(names(eia1a1_b)) == sort(["STRING.EMPTYA1TA1", "string_emptya1ta1"])
end # @testset "Instructions" begin

@testset "split_type_name_in_parts" begin
    tn, st1, rest = split_type_name_in_parts(PushInstruction)
    @test tn    == "PushInstruction"
    @test st1  === nothing
    @test rest === nothing

    tn, st1, rest = split_type_name_in_parts(Add{Int})
    @test tn   == "Add"
    @test st1  == string(Int)
    @test rest === nothing

    tn, st1, rest = split_type_name_in_parts(AfromB{Int,Float64})
    @test tn   == "AfromB"
    @test st1  == string(Int)
    @test rest == ["Float64"]
end # @testset "Literal instruction" begin

@testset "Literal instruction" begin
    li = Lit(23)
    @test inputtypes(li) == DataType[]
    @test outputtypes(li) == DataType[Int]
    @test neededstacks(li) == DataType[Int]
    @test arity(li) == 0
    @test numoutputs(li) == 1
    @test name(li) == IntStringL * "_lit"
    @test oldname(li) == IntStringU * ".LIT"
    @test desc(li) == "23"

    interp = PushInterpreter()
    execute!(li, interp)
    @test last(stack(interp, Int)) == 23
    @test length(stack(interp, Int)) == 1
end # @testset "Literal instruction" begin

@testset "Add instruction" begin
    i = Add{Int}()
    @test isa(i, Add{Int})
    @test name(i) == IntStringL * "_add"
    @test opname(i) == "add"
    @test oldopname(i) == "+"
    @test oldname(i) == IntStringU * ".+"

    interp = PushInterpreter()
    push!(interp, 1)
    push!(interp, 2)
    execute!(i, interp)
    @test length(stack(interp, Int)) == 1
    @test last(stack(interp, Int)) == 3
end # @testset "Add instructions" begin

@testset "Sub instruction" begin
    i = Sub{Float64}()
    @test isa(i, Sub{Float64})
    @test name(i) == "float64_sub"
    @test opname(i) == "sub"
    @test oldopname(i) == "-"
    @test oldname(i) == "FLOAT64.-"

    interp = PushInterpreter()
    push!(interp, 1.0)
    push!(interp, 2.1)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == (1.0 - 2.1)
end # @testset "Sub instructions" begin

@testset "Mul instruction" begin
    i = Mul{Float64}()
    @test isa(i, Mul{Float64})
    @test name(i) == "float64_mul"
    @test opname(i) == "mul"
    @test oldopname(i) == "*"
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
end # @testset "Mul instructions" begin

@testset "Div instruction" begin
    i = Div{Float64}()
    @test isa(i, Div{Float64})
    @test name(i) == "float64_div"
    @test opname(i) == "div"
    @test oldopname(i) == "/"
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
end # @testset "Div instructions" begin

@testset "Mod instruction" begin
    i = Mod{Float64}()
    @test name(i) == "float64_mod"
    @test opname(i) == "mod"
    @test oldopname(i) == "%"
    @test oldname(i) == "FLOAT64.%"

    interp = PushInterpreter()
    push!(interp, 4.5)
    push!(interp, 2.0)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == 2.0

    # Note that if denominator is 0.0 the Mod instruction is a No-Op
    interp = PushInterpreter()
    push!(interp, 3.1)
    push!(interp, 0.0)
    @test execute!(i, interp) === nothing
    @test length(stack(interp, Float64)) == 2
    @test last(stack(interp, Float64)) == 0.0
end # @testset "Mod instructions" begin

@testset "Max instructions" begin
    i = Max{Float64}()
    @test name(i) == "float64_max"
    @test opname(i) == "max"
    @test oldopname(i) == "MAX"
    @test oldname(i) == "FLOAT64.MAX"

    interp = PushInterpreter()
    push!(interp, 3.1)
    push!(interp, 17.54)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == 17.54
end # @testset "Max instruction" begin

@testset "Max instructions" begin
    i = Min{Float64}()
    @test name(i) == "float64_min"
    @test opname(i) == "min"
    @test oldopname(i) == "MIN"
    @test oldname(i) == "FLOAT64.MIN"

    interp = PushInterpreter()
    push!(interp, 3.1)
    push!(interp, 17.54)
    execute!(i, interp)
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == 3.1
end # @testset "Max instruction" begin

@testset "AfromB instructions" begin
    i = AfromB{String,Float64}()
    @test name(i) == "string_from_float64"
    @test oldname(i) == "STRING.FROMFLOAT64"
    @test opname(i) == "from"

    interp = PushInterpreter()
    push!(interp, 3.0)
    execute!(i, interp)
    @test length(stack(interp, String)) == 1
    @test last(stack(interp, String)) == "3.0"

    i = AfromB{Float64,Int}()
    interp = PushInterpreter()
    push!(interp, 5)
    execute!(i, interp)
    @test length(stack(interp, Int)) == 0
    @test length(stack(interp, Float64)) == 1
    @test last(stack(interp, Float64)) == 5.0
end

@testset "Eq instructions" begin
    i = Eq{Float64}()
    @test name(i)         == "float64_eq"
    @test oldname(i)      == "FLOAT64.="
    @test opname(i)       == "eq"
    @test arity(i)        == 2
    @test inputtypes(i)   == DataType[Float64, Float64]
    @test outputtypes(i)  == DataType[Bool]
    @test neededstacks(i) == DataType[Float64, Bool]

    interp = PushInterpreter()
    push!(interp, 5.0)
    push!(interp, 5.0)
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 1
    @test last(stack(interp, Bool)) == true
    @test length(stack(interp, Float64)) == 0

    push!(interp, 1.1)
    push!(interp, 1.2)
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 2
    @test last(stack(interp, Bool)) == false
    @test length(stack(interp, Float64)) == 0
end # @testset "Eq instructions" begin

@testset "Lt instructions" begin
    i = Lt{Int}()
    @test name(i)         == IntStringL * "_lt"
    @test oldname(i)      == IntStringU * ".<"
    @test opname(i)       == "lt"
    @test oldopname(i)    == "<"
    @test arity(i)        == 2
    @test inputtypes(i)   == DataType[Int, Int]
    @test outputtypes(i)  == DataType[Bool]
    @test neededstacks(i) == DataType[Int, Bool]

    interp = PushInterpreter()
    push!(interp, 2)
    push!(interp, 3)
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 1
    @test last(stack(interp, Bool)) == true
    @test length(stack(interp, Int)) == 0

    push!(interp, 3)
    push!(interp, 2)
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 2
    @test last(stack(interp, Bool)) == false
    @test length(stack(interp, Int)) == 0
end # @testset "Lt instructions" begin

@testset "Gt instructions" begin
    i = Gt{String}()
    @test name(i)         == "string_gt"
    @test oldname(i)      == "STRING.>"
    @test opname(i)       == "gt"
    @test oldopname(i)    == ">"
    @test arity(i)        == 2
    @test inputtypes(i)   == DataType[String, String]
    @test outputtypes(i)  == DataType[Bool]
    @test neededstacks(i) == DataType[String, Bool]

    interp = PushInterpreter()
    push!(interp, "c")
    push!(interp, "a")
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 1
    @test last(stack(interp, Bool)) == true
    @test length(stack(interp, String)) == 0

    push!(interp, "a")
    push!(interp, "d")
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 2
    @test last(stack(interp, Bool)) == false
    @test length(stack(interp, String)) == 0
end # @testset "Lt instructions" begin

@testset "Dup stack instruction" begin
    i = Dup{String}()
    @test name(i) == "string_dup"
    @test oldname(i) == "STRING.DUP"
    @test opname(i) == "dup"

    interp = PushInterpreter()
    push!(interp, "42")
    execute!(i, interp)
    @test length(stack(interp, String)) == 2
    @test last(stack(interp, String)) == "42"
end

@testset "Swap stack instruction" begin
    i = Swap{Bool}()
    @test name(i) == "bool_swap"
    @test oldname(i) == "BOOL.SWAP"
    @test opname(i) == "swap"

    interp = PushInterpreter()
    push!(interp, true)
    push!(interp, false)
    execute!(i, interp)
    @test length(stack(interp, Bool)) == 2
    @test last(stack(interp, Bool)) == true # Before swap true was next to last now it is last
    @test stack(interp, Bool)[end-1] == false
end

@testset "Flush stack instruction" begin
    i = Flush{Int}()
    @test name(i) == IntStringL * "_flush"
    @test oldname(i) == IntStringU * ".FLUSH"
    @test opname(i) == "flush"

    interp = PushInterpreter()
    push!(interp, 1)
    push!(interp, 2)
    push!(interp, 3)
    execute!(i, interp)
    @test length(stack(interp, Int)) == 0
end

@testset "StackDepth stack instruction" begin
    i = StackDepth{Int}()
    @test name(i) == IntStringL * "_stackdepth"
    @test oldname(i) == IntStringU * ".STACKDEPTH"
    @test opname(i) == "stackdepth"

    interp = PushInterpreter()
    push!(interp, 1)
    push!(interp, 2)
    push!(interp, 3)
    execute!(i, interp)
    @test length(stack(interp, Int)) == 4
    @test last(stack(interp, Int)) == 3 # Since length was 3 when we executed instruction
end