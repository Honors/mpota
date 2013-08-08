μπότα
=====
mpota is a project to bootstrap the lambda calculus then build up its feature set toward Scheme.

Roadmap
-------
1. Interpret the Lambda Calculus in a functionally-pure subset of Lisp.
2. Translate that interpreter to the Lambda Calculus.
3. Make a VM for an sexpr assembly language.
4. Compile to that VM from Lambda Calculus.
5. Build features iteratively upon the bootstrapped compiler.

Execution
---------
To execute the current Scheme interpreter, run the following.

```sh
$ ./interpret lambda.scm
```

Implementation
--------------
###Lazy Evaluation
Lazy Evaluation is achieved by wrapping all arguments in a lambda. Upon retrieval of a variable by name, the stored value is invoked with `'()` as argument. This lazy evaluation occurs at the fundamental level of our endeavors, excluding the VM once it has been constructed.

###Recursion
Thanks to lazy evaluation, recursion works with the simple Y Combinator in our implementation of the Lambda Calculus. The interpreter itself, however, currently utilizes recursion dependent on the mutable environment.
We will consider the Lambda Calculus simulated by this interpreter the starting point for now, that is, until we have a compiler going. This means that the implementation details at this level are insignificant, because they aim to mirror the formal definition of the Lambda Calculus.

###Parsing Parentheses
The parsing of parentheses was one of the hardest aspects of this interpreter. I wrote an [article][1] on *Lingua Lambda* on the process.

Learn More
----------
This project is tied to my writing of the book *Tarpits & Abstraction*, which is also [posted][2] on my Github. I have written on similar subject matters many times on *Lingua Lambda*, so feel free to browse the articles written there.

[1]: http://lingualambda.com/style/functional/2013/08/08/imperative-and-declarative.html
[2]: https://github.com/mattneary/Tarpits-Abstraction