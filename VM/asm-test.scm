(load "build/prelude.scm")

" (((lambda (x) (lambda (y) (x y))) (lambda (x) x)) 2)
"
(define 
  assembly 
  '((label incr)
    (comment (x -> x+1))
    (pop x)
    (incr resp x)
    (ret)
 
    (label dechurch)
    (comment (renders a church numeral as an int))
    (pop n)
    (pushp incr)
    (push 0)
    (call n)
    (ret)
  
    (label lam1)
    (comment (x -> x))
    (pop x)
    (cp resp x)
    (ret)

    (label lam2)
    (comment (x -> y -> (x y)))
    (pop y)
    (pop x)
    (pushp y)
    (call x)
    (ret)

    (label lam3)
    (comment (x -> lam2))
    (cp resp lam2)
    (ret)

    (label lam4)
    (comment (f -> x -> (f (f x))))
    (pop x)
    (pop f)
    (pushp x)
    (call incr)
    (pushp resp)
    (call incr)
    (ret)

    (label main)
    (comment (dechurch (lam1 lam3 two)))
    (pushp lam1)
    (call lam3)
    (pushp lam4)
    (call resp)
    (pushp resp)
    (call dechurch)
    
    (label end)))

(map write (reverse assembly))