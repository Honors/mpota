(load "prelude.scm")

" Builtin to the book's Language (Tarpits & Abstraction)
"
(define 
  (set key val hash)
  (push (map
    (lambda (item)
      (if
        (equal? (car item) key)
        (list key val)
        item))
    hash) (list key val)))
(define (assocv key hash) (if (eqv? #f (assoc key hash)) '() (cadr (assoc key hash))))
(define (cond-set conds)
  (if
    (null? conds)
    '#f
    (list 
      (list 
        'lambda 
	'(found) 
	(list 'if 'found (cadar conds) (cond-set (cdr conds)))) 
      (car (car conds)))))
(defmacro (cond conds) (cond-set conds))
(define
  (let-set vars expr)
  (if
    (null? vars)
    expr
    (list (list 'lambda (list (car (car vars))) (let-set (cdr vars) expr)) (car (cdr (car vars))))))
(defmacro (let* vars expr) (let-set vars expr))
(defmacro (let key val expr) `((lambda (,key) ,expr) ,val))


" Register Machine
"
(define (get lst index)
  (if
    (null? lst)
    '(halt)
    (if
      (eqv? index 0)
      (car lst)
      (get (cdr lst) (- index 1)))))
(define (eval exprs env index)
  (write (get exprs index))
  (let 
    expr 
    (get exprs index)
    (cond (((eqv? (car expr) 'jmp) (eval exprs env (assocv (cadr expr) env)))
           ((eqv? (car expr) 'call) (let stack (assocv 'stack env) (eval exprs (set 'stack (cons (+ 1 index) stack) env) (assocv (cadr expr) env))))
	   ((eqv? (car expr) 'push) (eval exprs (set 'args (cons (cadr expr) (assocv 'args env)) env) (+ 1 index)))
	   ((eqv? (car expr) 'pushp) (eval exprs (set 'args (cons (assocv (cadr expr) env) (assocv 'args env)) env) (+ 1 index)))
	   ((eqv? (car expr) 'pop) (let args (assocv 'args env) (eval exprs (set 'args (cdr args) (set (cadr expr) (car args) env)) (+ 1 index))))
           ((eqv? (car expr) 'set) (eval exprs (set (cadr expr) (caddr expr) env) (+ 1 index)))
           ((eqv? (car expr) 'cp) (eval exprs (set (cadr expr) (assocv (caddr expr) env) env) (+ 1 index)))
           ((eqv? (car expr) 'incr) (eval exprs (set (cadr expr) (+ 1 (assocv (caddr expr) env)) env) (+ 1 index)))
	   ((eqv? (car expr) 'ret) (let stack (assocv 'stack env) (eval exprs (set 'stack (cdr stack) env) (car stack))))
	   ((eqv? (car expr) 'comment) (eval exprs env (+ 1 index)))
	   ((eqv? (car expr) 'halt) env)))))
(define (enumerate exprs num)
  (if
    (null? exprs)
    '()
    (if
      (eqv? (car (car exprs)) 'label)
      (cons (push (car exprs) num) (enumerate (cdr exprs) num))
      (cons (push (car exprs) num) (enumerate (cdr exprs) (+ 1 num))))))
(define (init-env exprs)
  (concat (map (lambda (label) (cdr label)) (filter (lambda (expr) (eqv? (car expr) 'label)) (enumerate exprs 0))) '((stack ()) (args ()))))
(define (remove-labels exprs)
  (filter (lambda (expr) (not (eqv? (car expr) 'label))) exprs))  
(define (init-index env)
  (assocv 'main env))  
  
(define (get-asm)
  (let cmd (read)
    (if
      (eqv? '(label end) cmd)
      '()
      (cons cmd (get-asm)))))
(define assembly (get-asm))

(define env (init-env assembly))
(define index (init-index env))
(define exprs (remove-labels assembly))

(write (assocv 'resp (eval exprs env index)))
