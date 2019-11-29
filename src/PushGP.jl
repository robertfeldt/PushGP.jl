module PushGP

include("push_stack.jl")
include("push_interpreter.jl")
include("instructions.jl")
#include("stack_instructions.jl")
#include("number_instructions.jl")

# Maybe we should keep stack manipulation functions internal only?
export length, push!, pop!, last, empty!, pop2!
export PushInterpreter, execute!

end # module
