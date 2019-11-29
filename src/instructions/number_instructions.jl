struct Add{T} <: PushBinaryOp{T} end
execute_op(i::Add{T}, a::T, b::T) where {T} = b+a
oldopname(::Type{<:Add}) = "+"

struct Sub{T} <: PushBinaryOp{T} end
execute_op(i::Sub{T}, a::T, b::T) where {T} = b-a # Push order is that element at top of stack (a) is subtracted from the next element (b)
oldopname(::Type{<:Sub}) = "-"

struct Mul{T} <: PushBinaryOp{T} end
execute_op(i::Mul{T}, a::T, b::T) where {T} = b*a
oldopname(::Type{<:Mul}) = "*"

struct Div{T} <: PushBinaryOp{T} end
@inline function execute!(i::Div{T}, interp::AbstractPushInterpreter) where {T}
    stackhas(interp, T, 2) || return(nothing)
    last(stack(interp, T)) == 0 && return(nothing)
    a, b = pop2!(interp, T)
    res = b/a
    push!(interp, res)
end
oldopname(::Type{<:Div}) = "/"
