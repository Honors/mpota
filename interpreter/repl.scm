(load "interpreter/lambda.scm")

(define (loop)
  (write (eval (parens (read)) prelude))
  (loop))
(loop)