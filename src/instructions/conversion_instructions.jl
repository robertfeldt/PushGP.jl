struct AfromB{O,I} <: PushInstructionA1tB1{I,O} end
opname(::Type{<:AfromB}) = "from"

function name(::Type{AfromB{O,I}}) where {I,O}
    lowercase(string(O)) * "_from_" * lowercase(string(I))
end

function oldname(::Type{AfromB{O,I}}) where {I,O}
    uppercase(string(O)) * ".FROM" * uppercase(string(I))
end

@inline function execute!(i::AfromB{O,I}, interp::AbstractPushInterpreter) where {I,O}
    stackhas(interp, I, 1) || return(nothing)
    a = pop!(interp, I)
    res = convert(O, a)
    push!(interp, res)
end

@inline function execute!(i::AfromB{O,I}, interp::AbstractPushInterpreter) where {I,O<:String}
    stackhas(interp, I, 1) || return(nothing)
    a = pop!(interp, I)
    res = string(a)
    push!(interp, res)
end
