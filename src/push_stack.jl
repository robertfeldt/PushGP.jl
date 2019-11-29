# Should probably be a AbstractArray{T}??
abstract type PushStack{T} end

struct Stack{T} <: PushStack{T}
    st::Vector{T}
    Stack{T}() where {T} = new{T}(T[])
end

import Base: length, push!, pop!, last, empty!, getindex, lastindex

@inline length(s::Stack) = length(s.st)
@inline push!(s::Stack{T}, o::T) where {T} = push!(s.st, o)
@inline push!(s::Stack, o) = error("Objects of type $(typeof(o)) cannot be put on a $(typeof(s))")
@inline pop!(s::Stack) = pop!(s.st)
@inline function pop2!(s::Stack)
    a = pop!(s.st)
    b = pop!(s.st)
    return (a, b) # Note that element at the back is returned first
end
@inline last(s::Stack) = last(s.st)
@inline empty!(s::Stack) = empty!(s.st)
@inline getindex(s::Stack, args...) = getindex(s.st, args...)
@inline lastindex(s::Stack) = lastindex(s.st)