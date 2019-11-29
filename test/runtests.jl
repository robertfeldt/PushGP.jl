using PushGP
using Test

@testset "PushGP.jl" begin

include("test_push_stack.jl")
include("test_push_interpreter.jl")
include("test_instructions.jl")
#include("test_examples_README.jl")
#include("test_examples_PushGP_doc.jl")

end
