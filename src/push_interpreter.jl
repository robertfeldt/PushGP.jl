abstract type AbstractPushInterpreter end

# Default is to have no stacks, override for types for which your vm has a stack.
stacktypes(i::AbstractPushInterpreter) = DataType[]
@inline hasstack(i::AbstractPushInterpreter, T::DataType) = in(T, stacktypes(i))

function execute!(interp::AbstractPushInterpreter, program::AbstractArray)
    for instr in program
        execute!(instr, interp)
    end
end

# The default stacks follow a certain naming structure/format for speed and simplicity.
# For this to work you must name the fields for your stacks accordingly!!
@inline stack(i::AbstractPushInterpreter, ::Type{Int}) = i.stack_Int
@inline stack(i::AbstractPushInterpreter, ::Type{Float64}) = i.stack_Float64
@inline stack(i::AbstractPushInterpreter, ::Type{String}) = i.stack_String
@inline stack(i::AbstractPushInterpreter, ::Type{Bool}) = i.stack_Bool
@inline execstack(i::AbstractPushInterpreter) = i.exec_stack

@inline stackhas(i::AbstractPushInterpreter, T::DataType, n::Int) = length(stack(i, T)) >= n
@inline pop2!(i::AbstractPushInterpreter, I::DataType) = pop2!(stack(i, I))
@inline push!(i::AbstractPushInterpreter, val::O) where {O} = push!(stack(i, O), val)

# Default execution behavior is to just push the value. This takes care of all literals.
@inline execute!(instr, i::AbstractPushInterpreter) = push!(i, instr)

abstract type PushInstruction end

# This is the default type for things that can be part of a Push program.
const PushLiteralOrInstruction = Union{Int, Float64, Bool, String, PushInstruction}

# The standard/default PushVM has stacks for all the common things and executes via
# the Exec stack.
struct PushInterpreter{T} <: AbstractPushInterpreter
    exec_stack::Stack{T}
    stack_Int::Stack{Int}
    stack_Float64::Stack{Float64}
    stack_Bool::Stack{Bool}
    stack_String::Stack{String}
    PushInterpreter{T}() where {T} = begin
        new(Stack{T}(), 
            Stack{Int}(), Stack{Float64}(), 
            Stack{Bool}(), Stack{String}())
    end
end
PushInterpreter() = PushInterpreter{PushLiteralOrInstruction}()
stacktypes(i::PushInterpreter) = DataType[Int, Float64, String, Bool]

function execute!(interp::PushInterpreter, program::AbstractArray)
    # Push in reverse order
    for instr in Iterators.reverse(program)
        push!(interp.exec_stack, instr)
    end
    # Then run from exec_stack
    run_from_execstack!(interp)
end

function run_from_execstack!(interp::PushInterpreter)
    while length(interp.exec_stack) > 0
        i = pop!(interp.exec_stack)
        execute!(i, interp)
    end
end
