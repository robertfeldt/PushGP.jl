# Should probably be a AbstractArray{T}??
abstract type PushStack{T} end

struct Stack{T} <: PushStack{T}
    st::Vector{T}
    Stack{T}() where {T} = new{T}(T[])
end

import Base: length, push!, pop!, last, empty!

@inline length(s::Stack) = length(s.st)
@inline push!(s::Stack{T}, o::T) where {T} = push!(s.st, o)
@inline push!(s::Stack, o) = error("Objects of type $(typeof(o)) cannot be put on a $(typeof(s))")
@inline pop!(s::Stack) = pop!(s.st)
@inline pop2!(s::Stack) = return(pop!(s.st), pop!(s.st))
@inline last(s::Stack) = last(s.st)
@inline empty!(s::Stack) = empty!(s.st)
