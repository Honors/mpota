(load "interpreter/lambda.scm")

(define prog '(fixed < cons 1 1 >))
(write (parens prog))
(write (eval (parens prog) prelude))