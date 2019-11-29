# Stack ops are things like Dup, Swap, Flush etc
abstract type PushStackOp{T} <: PushInstructionA1tA1{T} end

struct Dup{T} <: PushStackOp{T} end
@inline function execute!(i::Dup{T}, interp::AbstractPushInterpreter) where {T}
    stackhas(interp, T, 1) || return(nothing)
    s = stack(interp, T)
    push!(s, last(s))
end

struct Swap{T} <: PushStackOp{T} end
@inline function execute!(i::Swap{T}, interp::AbstractPushInterpreter) where {T}
    stackhas(interp, T, 2) || return(nothing)
    a, b = pop2!(interp, T) # a was last and b next to last
    push!(interp, a)
    push!(interp, b) # b is now last so a is next to last
end

struct Flush{T} <: PushStackOp{T} end
@inline function execute!(i::Flush{T}, interp::AbstractPushInterpreter) where {T}
    empty!(stack(interp, T))
end

struct StackDepth{T} <: PushStackOp{T} end
@inline function execute!(i::StackDepth{T}, interp::AbstractPushInterpreter) where {T}
    push!(stack(interp, Int), length(stack(interp, T)))
end
