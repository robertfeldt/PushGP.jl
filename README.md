# PushGP

[![Build Status](https://travis-ci.com/robertfeldt/PushGP.jl.svg?branch=master)](https://travis-ci.com/robertfeldt/PushGP.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/robertfeldt/PushGP.jl?svg=true)](https://ci.appveyor.com/project/robertfeldt/PushGP-jl)
[![Codecov](https://codecov.io/gh/robertfeldt/PushGP.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/robertfeldt/PushGP.jl)
[![Coveralls](https://coveralls.io/repos/github/robertfeldt/PushGP.jl/badge.svg?branch=master)](https://coveralls.io/github/robertfeldt/PushGP.jl?branch=master)

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

## Why genetic programming?
I did genetic programming research as a young researcher but have lost touch somewhat with the GECCO community in the last 10 years or so. So first reason is to have fun and get back to GP and the GECCO community. :)

But I also think that we need automatic programming for future Software Engineering, AI and Machine Learning. So I want to use this package as an experimental vehicle for exploring Interpretable Machine Learning, Program Synthesis etc.

## Where can I learn more about PushGP and the Push language?
Push and PushGP has been developed by Lee Spector and his colleagues during many years. An [introduction to and overview of Push can be found here](https://faculty.hampshire.edu/lspector/push.html). Maybe the best starting point is the [Push Redux](https://erp12.github.io/push-redux/) site and, in particular, its brief [Intro to Push](https://erp12.github.io/push-redux/pages/intro_to_push/) page. 

If you want to dig deep on the research please check [Lee Spector's list of publications](https://faculty.hampshire.edu/lspector/publications.html). On Lee's [main Push page](https://faculty.hampshire.edu/lspector/push.html) you can also find a long list of PushGP implementations in other languages.

## Does PushGP.jl differ from the standard Push implementations?
Yes, there are some differences since my focus is on using this for research and future development rather than for backward compatibility. I will try to list deviances here though:

- `PushInterpreter`s can but does not have to make use of an Exec stack. While standard Push implementations always make use of such a stack there are use cases where one does not need to evolve complex programming constructs and then it might be simpler to exclude Exec stack manipulating instructions (since they might the search slower).

## History of this package

This is a complete rewrite for Julia 1.3 (of my old 2015-2016 implementation). With the introduction of multi-threading in Julia 1.3 I figured it was time to try to exploit multiple cores/threads at the core of this package since genetic programming, being an evolutionary algorithm, is 'embarassingly parallel'. Given that I know Julia even better now (2019) I can also design the core Push concepts to give better performance and allowing more flexibility. This prompted the rewrite. Rather than extend the old git repo I decided to get a fresh start and only carry over code as I went along, while adding tests and ensuring things work as expected of a modern Julia package.
