(load "lambda.scm")

(define (loop)
  (write (eval (parens (read)) prelude))
  (loop))
(loop)