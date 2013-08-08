(load "prelude.scm")

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
(defmacro (let name val expr) `((lambda (,name) expr) ,val))

"  render a flat list with parentheses of the form 
"" `<...>` as a nested list.
"
(define (eatparens expr nested before paren accum found)
  (if
    (null? expr)
    (if
      (not (null? paren))
      (concat (push before paren) (parens accum))
      accum)
    (cond (((and (eqv? (car expr) '<) (not found))
            (if
              (eqv? nested 0)
              (eatparens (cdr expr) (+ nested 1) accum paren '() found)
              (eatparens (cdr expr) (+ nested 1) before paren (push accum (car expr)) found))) 
           ((and (eqv? (car expr) '>) (not found))
	        (if
              (eqv? nested 1)
              (eatparens (cdr expr) (- nested 1) before (parens accum) '() #t)
              (eatparens (cdr expr) (- nested 1) before paren (push accum (car expr)) found)))
           (#t (eatparens (cdr expr) nested before paren (push accum (car expr)) found))))))
(define (parens expr)
  (eatparens expr 0 '() '() '() #f))
  
" apply a list of arguments to a function  
"
(define (apply-set fn args)
  (if
    (null? args)
    fn
    (apply-set (fn (car args)) (cdr args))))
    
"  evaluate the lambda calculus
"" lazy evaluation is achieved by use of lambda wrappers
"" and then application of `'()` upon retrieval of values.
"
(define (eval expr env)
  (cond (((atom? expr) ((assocv expr env) '()))
         ((eqv? 'lam (car expr)) 
	      (lambda (x) (eval (cddr expr) (set (cadr expr) x env))))
	     ((null? (cdr expr)) (eval (car expr) env))
	     (#t 
	      (apply-set 
	        (eval (car expr) env) 
	        (map 
	          (lambda (expr) (eval (list 'lam 'z expr) env)) 
	          (cdr expr)))))))  
(define (evalpar expr env)
  (eval (parens expr) env))	 
  
" provide basic functions in a prelude
"  
(define prelude 
  `((id ,(lambda(z) (lambda (x) x))) (1 ,(lambda (z) 1))))
(define prelude 
  (set 'true (evalpar '(lam z lam a lam b < a > id) prelude) prelude))
(define prelude 
  (set 'false (evalpar '(lam z lam a lam b < b > id) prelude) prelude))
(define prelude 
  (set 'cons (evalpar '(lam z lam a lam b lam c lam n < < c > a > b) prelude) prelude))
(define prelude 
  (set 'nil (evalpar '(lam z lam c lam n < n > id) prelude) prelude))
(define prelude 
  (set 'car (evalpar '(lam z lam l < l < lam a lam b a > id >) prelude) prelude))
(define prelude 
  (set 'cdr (evalpar '(lam z lam l < l < lam a lam b b > id >) prelude) prelude))
(define prelude
  (set 'null? (evalpar '(lam z lam l < l < lam a lam b false > < lam n true > >) prelude) prelude))
(define prelude
  (set 'if (evalpar '(lam z lam p lam t lam f < p t f >) prelude) prelude))
(define prelude 
  (set 'tuple (evalpar '(lam z lam a lam b < cons a < cons b nil > >) prelude) prelude))

" a display of successful recursion
"
(define prelude 
  (set 'cursor (evalpar '(lam z lam me lam n < if < null? n > < lam z 1 > < lam z < me nil > > >) prelude) prelude))
(define prelude 
  (set 'Y (evalpar '(lam z lam f < lam x < f < x x > > > < lam x < f < x x > > >) prelude) prelude))
(define prelude 
  (set 'fixed (evalpar '(lam z < Y cursor >) prelude) prelude))
