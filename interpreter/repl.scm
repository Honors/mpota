(load "interpreter/lambda.scm")

(define parsed '())
(define (loop)
  ((lambda (parsed)
    (write "parentheses parsed...")        
    ((lambda (evaled)
      (write "expression evaluated:")
      (write evaled)
      (loop))
    (eval parsed prelude))) (parens (read))))
(loop)
