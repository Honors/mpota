(define (not x)            (if x #f #t))
(define (null? obj)        (if (eqv? obj '()) #t #f))

" accept a variable number of arguments and return them
"
(define (list . objs)       objs)

" helpers for HOF
"
(define (id obj)           obj)
(define (flip func)        {|arg1 arg2| (func arg2 arg1)})
(define (curry func arg1)  {|arg| (apply func (cons arg1 (list arg)))})
(define (compose f g)      {|arg| (f (apply g arg))})

(define zero?              (curry = 0))
(define positive?          (curry < 0))
(define negative?          (curry > 0))
(define (odd? num)         (= (mod num 2) 1))
(define (even? num)        (= (mod num 2) 0))

" foundation of recursive functions
"
(define (foldr func end lst)
  (if (null? lst)
      end
      (func (car lst) (foldr func end (cdr lst)))))
(define (foldl func accum lst)
  (if (null? lst)
      accum
      (foldl func (func accum (car lst)) (cdr lst))))      
(define fold foldl)
(define reduce foldr)      
(define (unfold func init pred)
  (if (pred init)
      (cons init '())
      (cons init (unfold func (func init) pred))))
      
" simple derivatives
"
(define (sum . lst)         (fold + 0 lst))
(define (product . lst)     (fold * 1 lst))
(define (and . lst)         (fold && #t lst))
(define (or . lst)          (fold _or #f lst))      

(define (max first . rest) (fold {|old new| (if (> old new) old new)} first rest))
(define (min first . rest) (fold {|old new| (if (< old new) old new)} first rest))
(define (length lst)        (fold {|x y| (+ x 1)} 0 lst))
(define (reverse lst)       (fold (flip cons) '() lst))

" association functions
"
(define (mem-helper pred op) (lambda (acc next) (if (and (not acc) (pred (op next))) next acc)))
(define (memq obj lst)       (fold (mem-helper (curry eq? obj) id) #f lst))
(define (memv obj lst)       (fold (mem-helper (curry eqv? obj) id) #f lst))
(define (member obj lst)     (fold (mem-helper (curry equal? obj) id) #f lst))
(define (assq obj alist)     (fold (mem-helper (curry eq? obj) car) #f alist))
(define (assv obj alist)     (fold (mem-helper (curry eqv? obj) car) #f alist))
(define (assoc obj alist)    (fold (mem-helper (curry equal? obj) car) #f alist))

" map and filter
"
(define (map func lst)      (foldr {|x y| (cons (func x) y)} '() lst))
(define (filter pred lst)   (foldr {|x y| (if (pred x) (cons x y) y)} '() lst))

" misc.
"
(define (compose* . funcs) (foldr compose id funcs))
(define (push a b) ((compose reverse cons) (list b (reverse a))))
(define (concat a b) (fold push a b))
(define (strconcat a b) (list->string (concat (string->list a) (string->list b))))

" list access shorthands
"
(define cadr {|x| (car (cdr x))})
(define cadar {|x| (car (cdr (car x)))})
(define caar {|x| (car (caar x))})
(define caddr {|x| (car (cdr (cdr x)))})
(define cddr {|x| (cdr (cdr x))})
(define cdddr {|x| (cdr (cdr (cdr x)))})
(define cadddr {|x| (car (cdr (cdr (cdr x))))})

" substitution
"
(define (sub a b x) (if (eq? a x) b x))
(define (distribute fn alist) (if (atom? alist) (fn alist) (map {|elm| (distribute fn elm)} alist)))
(define (sublist a b alist) (distribute {|x| (sub a b x)} alist))

" a `defmacro` analog for quoted forms within lisp
"
(define 
  (submacro head fn alist) 
  (if 
    (atom? alist) 
    alist 
    (if 
      (eq? 
        (car alist) 
        head) 
      (fn alist) 
      (map {|part| (submacro head fn part)} alist))))
     
" the plan of attack to multi-expression `begincc`
"     
(defmacro (altbegincc . exprs) `(,(concat '(lambda (_)) exprs) 0))
      
" an early implementation of continuations
"      
(defenvmacro 
  (begincc env expr) 
  (submacro 
    'call/cc 
    (lambda 
      (part) 
      `(,(cadr part) 
      (lambda 
        (val) 
        (evalenv 
          (quote ,env) 
          (submacro 
            'call/cc 
            {|_| val} 
            (quote ,expr))))))
    expr))
