(load "build/prelude.scm")

"  define `cond`, a version of `assoc` giving the 
"" value, `set`, and `let`
"
(define (cond-set conds)
  (if
    (null? conds)
    '#f
    (list 
      (list 
        'lambda 
	'(found123) 
	(list 'if 'found123 (cadar conds) (cond-set (cdr conds)))) 
      (car (car conds)))))
(defmacro (cond conds) (cond-set conds))
(defmacro (let name val expr)
  `((lambda (,name) expr) ,val))
(defmacro
  (let* vars expr)
  (if
    (null? vars)
    expr
    `((lambda (,(car (car vars))) (let* ,(cdr vars) ,expr)) ,(cadar vars))))
(define (assocv key hash) (cadr (assoc key hash)))
(define 
  (set key val hash)
  (push (map
    (lambda (item)
      (if
        (equal? (car item) key)
        (list key val)
        item))
    hash) (list key val)))
(defmacro (let name val expr) `((lambda (,name) ,expr) ,val))

"  render a flat list with parentheses of the form 
"" `<...>` as a nested list.
"
(define (Z f) (f (lambda (z) (Z f))))
(define (eatparenser eatparens) (lambda (expr nested before paren accum found)
  (if
    (null? expr)
    (if
      (not (null? paren))
      (concat (push before paren) ((eatparens '()) accum 0 '() '() '() #f))
      accum)
    (cond (((and (eqv? (car expr) '<) (not found))
            (if
              (eqv? nested 0)
              ((eatparens '()) (cdr expr) (+ nested 1) accum paren '() found)
              ((eatparens '()) (cdr expr) (+ nested 1) before paren (push accum (car expr)) found))) 
           ((and (eqv? (car expr) '>) (not found))
	        (if
              (eqv? nested 1)
              ((eatparens '()) (cdr expr) (- nested 1) before (parens accum) '() #t)
              ((eatparens '()) (cdr expr) (- nested 1) before paren (push accum (car expr)) found)))
           (#t ((eatparens '()) (cdr expr) nested before paren (push accum (car expr)) found)))))))
(define eatparens (Z eatparenser))           
(define (parens expr)
  (eatparens expr 0 '() '() '() #f))
  
" apply a list of arguments to a function  
"
(define (apply-setter apply-set) (lambda (fn args)
  (if
    (null? args)
    fn
    ((apply-set '()) (fn (car args)) (cdr args)))))
(define apply-set (Z apply-setter))    
    
"  evaluate the lambda calculus
"" lazy evaluation is achieved by use of lambda wrappers
"" and then application of `'()` upon retrieval of values.
"" recursion is achieved rather explicitly by *unwrapping*
"" a lambda wrapped version of oneself prior to execution.
"
(define (evaler eval) (lambda (expr env)
  (cond (((atom? expr) ((assocv expr env) '()))
         ((eqv? 'lam (car expr)) 
	      (lambda (x) ((eval '()) (cddr expr) (set (cadr expr) x env))))
	     ((null? (cdr expr)) ((eval '()) (car expr) env))
	     (#t 
	      (apply-set 
	        ((eval '()) (car expr) env) 
	        (map 
	          (lambda (expr) ((eval '()) (list 'lam 'z expr) env)) 
	          (cdr expr))))))))  
	          
(define eval (Z evaler))	          
(define (evalpar expr env)
  (eval (parens expr) env))	 
  
" provide basic functions in a prelude
"  
(define preludefinal '())
(let* ((prelude `((id ,(lambda(z) (lambda (x) x))) (1 ,(lambda (z) 1))))
       (prelude (set 'true (evalpar '(lam z lam a lam b < a > id) prelude) prelude))
       (prelude (set 'false (evalpar '(lam z lam a lam b < b > id) prelude) prelude))
       (prelude (set 'cons (evalpar '(lam z lam a lam b lam c lam n < < c > a > b) prelude) prelude))
       (prelude (set 'nil (evalpar '(lam z lam c lam n < n > id) prelude) prelude))
       (prelude (set 'car (evalpar '(lam z lam l < l < lam a lam b a > id >) prelude) prelude))
       (prelude (set 'cdr (evalpar '(lam z lam l < l < lam a lam b b > id >) prelude) prelude))
       (prelude (set 'null? (evalpar '(lam z lam l < l < lam a lam b false > < lam n true > >) prelude) prelude))
       (prelude (set 'if (evalpar '(lam z lam p lam t lam f < p t f >) prelude) prelude))
       (prelude (set 'tuple (evalpar '(lam z lam a lam b < cons a < cons b nil > >) prelude) prelude))
       (prelude (set 'cursor (evalpar '(lam z lam me lam n < if < null? n > < lam z 1 > < lam z < me nil > > >) prelude) prelude))
       (prelude (set 'Y (evalpar '(lam z lam f < lam x < f < x x > > > < lam x < f < x x > > >) prelude) prelude))
       (prelude (set 'fixed (evalpar '(lam z < Y cursor >) prelude) prelude)))
  (set! preludefinal prelude))
(define prelude preludefinal)  