struct BoolOr <: PushBinaryOp{Bool} end
execute_op(i::BoolOr, a::Bool, b::Bool) = (a||b)
opname(::Type{BoolOr}) = "or"

struct Eq{I} <: PushInstructionA2tB1{I,Bool} end
execute_op(i::Eq{I}, a::I, b::I) where {I} = (b==a)
oldopname(::Type{<:Eq}) = "="

struct Lt{I} <: PushInstructionA2tB1{I,Bool} end
execute_op(i::Lt{I}, a::I, b::I) where {I} = (b<a)
oldopname(::Type{<:Lt}) = "<"

struct Gt{I} <: PushInstructionA2tB1{I,Bool} end
execute_op(i::Gt{I}, a::I, b::I) where {I} = (b>a)
oldopname(::Type{<:Gt}) = ">"
