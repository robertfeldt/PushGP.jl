@inline hasstacks(interp::AbstractPushInterpreter, i::PushInstruction) = 
    all(st -> hasstack(interp, st), neededstacks(i))

@inline inputtypes(i::PushInstruction) = DataType[]
@inline outputtypes(i::PushInstruction) = DataType[]
@inline neededstacks(i::PushInstruction) = unique(vcat(inputtypes(i), outputtypes(i)))
@inline arity(i::PushInstruction) = length(inputtypes(i))
@inline numoutputs(i::PushInstruction) = length(outputtypes(i))

name(i::PushInstruction) = name(typeof(i))
desc(i::PushInstruction) = name(i)
opname(i::PushInstruction) = opname(typeof(i))
oldopname(i::PushInstruction) = oldopname(typeof(i))
oldname(i::PushInstruction) = oldname(typeof(i))
names(i::PushInstruction) = names(typeof(i))

oldopname(::Type{I}) where {I<:PushInstruction} = uppercase(opname(I)) # Default is that the old Push name is same as current op name. Override for exception like add/+ etc.
names(::Type{I}) where {I<:PushInstruction} = unique([name(I), oldname(I)])

@inline function name(::Type{I}) where {I<:PushInstruction}
    oname, stname = split_type_name_in_parts(I)
    (stname === nothing) ? opname(I) : (lowercase(stname) * "_" * opname(I))
end    
@inline function oldname(::Type{I}) where {I<:PushInstruction}
    oname, stname = split_type_name_in_parts(I)
    (stname === nothing) ? oldopname(I) : (uppercase(stname) * "." * oldopname(I))
end    
@inline opname(::Type{I}) where {I<:PushInstruction} =
    lowercase(first(split_type_name_in_parts(I)))

const TypeNameRegexp = r"([^{]+){([^,]+)(.+)*}"

function split_type_name_in_parts(::Type{I}) where {I<:PushInstruction}
    m = match(TypeNameRegexp, string(I))
    if m === nothing
        # No subtypes
        return string(I), nothing
    end
    if length(m.captures) == 2 # Most common case
        return m[1], m[2] # Note that 3 will need to be further sub-divided for complex types...
    elseif length(m.captures) == 1
        return m[1], ""
    else
        return m[1], m[2], m[3]
    end
end

@inline execute!(i::PushInstruction, interp::AbstractPushInterpreter) = nothing # No-Op is default

# We use a naming convention where types are indicated A, B, C and so. 
# So an instruction taking 2 input arguments of type A and producing one output of the same
# type A would be of type PushInstructionA2tA1.
# An instruction taking one input of type A, one input of type B and producing an output
# of type C would be of type: PushInstructionA1B1tC1

abstract type PushInstructionA1tA1{T} <: PushInstruction end
inputtypes(i::PushInstructionA1tA1{T}) where {T} = DataType[T]
outputtypes(i::PushInstructionA1tA1{T}) where {T} = DataType[T]

abstract type PushInstructionA1tB1{I,O} <: PushInstruction end
inputtypes(i::PushInstructionA1tB1{I,O}) where {I,O} = DataType[I]
outputtypes(i::PushInstructionA1tB1{I,O}) where {I,O} = DataType[O]

abstract type PushUnaryOp{T} <: PushInstructionA1tA1{T} end

abstract type PushInstructionA2tB1{I,O} <: PushInstruction end
inputtypes(i::PushInstructionA2tB1{I,O}) where {I,O} = DataType[I, I] # Note that both are given so arity is right
outputtypes(i::PushInstructionA2tB1{I,O}) where {I,O} = [O]
neededstacks(i::PushInstructionA2tB1{I,O}) where {I,O} = DataType[I, O]

@inline function execute!(i::PushInstructionA2tB1{I,O}, interp::AbstractPushInterpreter) where {I,O}
    stackhas(interp, I, 2) || return(nothing)
    a, b = pop2!(interp, I)
    res = execute_op(i, a, b) # Should produce a result of type O (but we do not check it)
    push!(interp, res)
end

# Binary Op is an A2tB1 where input type (A) and output type (B) are the same.
abstract type PushBinaryOp{T} <: PushInstructionA2tB1{T,T} end
neededstacks(i::PushBinaryOp{T}) where {T} = DataType[T]
name(i::PushBinaryOp{T}) where {T} = lowercase(string(T)) * "_" * opname(typeof(i))

abstract type PushInstructionA0tA1{T} <: PushInstruction end
inputtypes(i::PushInstructionA0tA1{T}) where {T} = DataType[]
outputtypes(i::PushInstructionA0tA1{T}) where {T} = DataType[T]

# Since Vector are used as Push programs we might need to explicitly
# indicate when they are literals. We can do this with the Lit instruction.
struct Lit{T} <: PushInstructionA0tA1{T}
    value::T
    Lit(x::T) where {T} = new{T}(x)
end
@inline execute!(l::Lit, interp::AbstractPushInterpreter) = push!(interp, l.value)
@inline desc(i::Lit) = string(i.value)

# Load instructions for specific areas:
include("instructions/stack_instructions.jl")
include("instructions/number_instructions.jl")
include("instructions/bool_instructions.jl")
include("instructions/conversion_instructions.jl")
