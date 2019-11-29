# PushGP.jl

[![Build Status](https://travis-ci.com/robertfeldt/PushGP.jl.svg?branch=master)](https://travis-ci.com/robertfeldt/PushGP.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/robertfeldt/PushGP.jl?svg=true)](https://ci.appveyor.com/project/robertfeldt/PushGP-jl)
[![Codecov](https://codecov.io/gh/robertfeldt/PushGP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/robertfeldt/PushGP.jl)

A Julia implementation of the [Push](https://faculty.hampshire.edu/lspector/push.html) language for Genetic Programming.

## Usage

Push is a stack-based programming language specifically developed to support [genetic programming](https://en.wikipedia.org/wiki/Genetic_programming). Here is a simple example program to add the integers 2 and 5:

```
using PushGP
simple_program = [2, 5, Add{Int}()]
```

When we run this program it will first push 2 onto the Int stack, then push 5 onto the same stack, and then the `:integer_add` Push instruction will pop the 5 and the 2 from the Int stack, add them, and push the result onto the Int stack. To run this program we need a push interpreter:

```
i = PushInterpreter()
execute!(i, simple_program)
```

There is no output when we execute the program but we can now check that the last element on the Int stack is 7 and the length of the stack is 1:

```
intstack = stack(i, Int)
@assert last(intstack) == 7
@assert length(intstack) == 1
```

We can continue execution on this interpreter. Let's now try a more complex example:

```
execute!(i, [5, 6.5, Sub{Int}(), 2.0, Mul{Float64}(), 4.0, Div{Float64}(), AfromB{String,Float64}(), 1.7])
```

Here we can see how interleaved order of instructions doesn't matter since there are multiple, independent stacks. For example, the `Sub{Int}` instruction above will put 2 on the Int stack since 7 was already on there and we then pushed 5 and then executed the `Sub{Int}` instruction. It didn't matter that 6.5 happened in between since it was just pushed on the `Float64` stack. The `Mul{Float64}()` then multiplied 2.0 and 6.5, leaving 13.0 on the Float64 stack. After pushing 4.0 the `Div{Float64}()` instruction left 3.25 on the stack which was then converted to the String "3.25". The final state of the stacks is now:

```
    @assert last(stack(i, Int)) == 2
    @assert length(stack(i, Int)) == 1
    @assert last(stack(i, String)) == "3.25" # string((2.0 * 6.5) / 4.0)
    @assert length(stack(i, String)) == 1
    @assert last(stack(i, Float64)) == 1.7
    @assert length(stack(i, Float64)) == 1
```

There is a [large number of Push instructions](https://faculty.hampshire.edu/lspector/push3-description.html) and this package does not yet implement them all. However, this will be fixed over time and it is often trivial to add individual instructions (requiring only to write a few lines of Julia code). However, more important than implement the standard Push language is that a user can easily add their own, custom instructions and thus do genetic programming for specific domains and problems.

## Why genetic programming?
I did genetic programming research early in my research career but have lost touch somewhat with the GECCO and Evolutionary Computation (EC) community in the last 10 years or so. So the first reason is to have fun and get back to GP and the GECCO community. :)

But I also think that we need automatic programming for future Software Engineering, AI and Machine Learning. So I want to use this package as an experimental vehicle for exploring Interpretable Machine Learning, Program Synthesis etc.

## Where can I learn more about PushGP and the Push language?
Push and PushGP has been developed by Lee Spector and his colleagues during many years. An [introduction to and overview of Push can be found here](https://faculty.hampshire.edu/lspector/push.html). Maybe the best starting point is the [Push Redux](https://erp12.github.io/push-redux/) site and, in particular, its brief [Intro to Push](https://erp12.github.io/push-redux/pages/intro_to_push/) page. The Push3 language description can be found [here](https://faculty.hampshire.edu/lspector/push3-description.html) but note that the Plush linear Push genome was not available at that time so have been added later.

If you want to dig deep on the research please check [Lee Spector's list of publications](https://faculty.hampshire.edu/lspector/publications.html). On Lee's [main Push page](https://faculty.hampshire.edu/lspector/push.html) you can also find a long list of PushGP implementations in other languages.

## Does PushGP.jl differ from the standard Push implementations?
Yes, there are some differences since my focus is on using this for research and future development rather than for backward compatibility. I will try to list deviances here though:

- `PushInterpreter`s can but does not have to make use of an Exec stack. While standard Push implementations always make use of such a stack there are use cases where one does not need to evolve complex programming constructs and then it might be simpler to exclude Exec stack manipulating instructions (since they might the search slower).
- We do not yet support the Plush linear genomes for PushGP. This should be a fairly trivial fix when the core has been ported over from previous Julia versions.

## History of this package

This is a complete rewrite for Julia 1.3 (of my old 2015-2016 implementation). With the introduction of multi-threading in Julia 1.3 I figured it was time to try to exploit multiple cores/threads at the core of this package since genetic programming, being an evolutionary algorithm, is 'embarassingly parallel'. Given that I know Julia even better now (2019) I can also design the core Push concepts to give better performance and allowing more flexibility. This prompted the rewrite. Rather than extend the old git repo I decided to get a fresh start and only carry over code as I went along, while adding tests and ensuring things work as expected of a modern Julia package.
