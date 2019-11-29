struct BoolOr <: PushBinaryOp{Bool} end
execute_op(i::BoolOr, a::Bool, b::Bool) = (a||b)

#struct Eq{I} <: PushInstructionA2tB1{I,Bool} end
#execute_op(i::Eq{I}, a::I, b::I) where {I} = (a==b)
#
#struct GrEq{I} <: PushInstructionA2tB1{I,Bool} end
#execute_op(i::GrEq{I}, a::I, b::I) where {I} = (a>=b)
#
#struct LtEq{I} <: PushInstructionA2tB1{I,Bool} end
#execute_op(i::LtEq{I}, a::I, b::I) where {I} = (a<=b)
#