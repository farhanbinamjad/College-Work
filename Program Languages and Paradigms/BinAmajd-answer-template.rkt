#lang racket

;; Author: Farhan Amjad
;; EXAM

;; ----------
;; Problem  1
;;
;; a. Bullet 1: 2
;;    Bullet 2: 7
;; b. (cons 'b (cons (cons 'c 'd) 'a))
;;

;; ----------
;; Problem  2
;;
;; a. A special form is define while cons can be a function
;;
;; b. A fuction is evaluated as (<operator> <operand1> <operand2> while a special
;; form, for examlpe define is an operator, used in the same way
;; we use any function to create a compound expression; however Racket has a
;; special rule for it. In a special form is in which all operands are
;; evaluated and the values passed to the operator
;;

;; ----------
;; Problem  3

(define select
  (lambda (list1 list2 list3)
    (list (first list1) (second list2) (third list3))))

;; ----------
;; Problem  4

(define dot-product
  (lambda (lst1 lst2)
    (foldr + 0 (map * lst1 lst2))))


;; ----------
;; Problem  5

(define either?
  (lambda (f? g?)
    (lambda (v)
      (or (f? v)
          (g? v)
          ))))

;; ----------
;; Problem  6

(define apply-ff
  (lambda (ff sym)
    (cond ((null? ff)                                    
              (error 'ff "not in dom" sym))
          ((symbol? (first ff))                             
              (if (eq? sym (first ff))                     
                  (second ff)
                  (apply-ff (third ff) sym)))
          (else                                          
              (let ((position (list-index sym (first ff)))) 
                (if (>= position 0)
                    (list-ref (second ff) position)
                    (apply-ff (third ff) sym)))))))

(define list-index
  (lambda (target los)
    (letrec ((list-index-helper
              (lambda (los base)
                (if (null? los)
                    -1
                    (if (eq? target (first los))
                        base
                        (list-index-helper (rest los) (+ base 1)))))))
      (list-index-helper los 0))))

;; ----------
;; Problem  7
;;
;; a. In this expression, we defined a variable called bonus-rate which is to demonstrate a closure.
;; And in (lambda (salary) (* salary (add1 bonus-rate)))), the value of bonus-rate will be changed,
;; without changing  the orignal.
;;
;; b. bonus-rate and salary


;; ----------
;; Problem  8

;; a. A language will have:
;; 1) primitive expressions
;; 2) a means of combination, for building compound expressions out of simpler ones
;; 3) a means of abstracting, for grouping details into a higher-order expressions
;;
;; b.For racket a primitive expression can be  a number 25
;; a means of combining can be aggregate data types like pair
;; a means of abstraction can be define
;;
;; c. For Joy, it is similar where primitive expression can be a number 25,
;; for combining it can be lists and abstraction can be DEFINE
;; 

;; ----------
;; Problem  9

(define init-counts
  (lambda (lst)
    (if (null? lst)
        '()
    (cons (list (first lst) 0) (init-counts (rest lst)))
    )))

;; ----------
;; Problem 10

(define vector-sum
  (lambda (von)
    (vector-helper von 0)
    ))

(define vector-helper
  (lambda (von pos)
    (if (< pos (vector-length von))
        (+ (vector-ref von pos) (vector-helper von (+ 1 pos)))
        0)
    ))

;; ----------
;; Problem 11

(define slist-contains?
  (lambda (s slist)
    (if (null? slist)
        #f
        (or (symexp-contains? s slist) (slist-contains? s (rest slist))))

    ))

(define symexp-contains?
  (lambda (s slist)
    (if (eq? s (first slist))
        #t
        (slist-contains? s (rest slist)))
    ))

;; ----------
;; Problem 12

(define separate                   
       (lambda (v lst)               
          (remove (first (separate-with-position v lst 1))  (separate-with-position v lst 1)) ))

(define separate-with-position
  (lambda (v lst position)
          (if (null? lst)
              '()
              (flatten (cons (list v (first lst))
	            (separate-with-position v (rest lst) (add1 position)))))))
  
;; ----------
;; Problem 13
;;
;; a. a procedure that takes multiple arguments can be curried into its lambda forms
;; (into a procedure of one argument that returns a procedure that expects the rest)
;;
;; b. Logical connectives like and/or are abstraction of general conditional expression if.
;;
;; c. A multiway conditional is also an abstraction of if.
;;
;; d. for loops are abstraction for while loops
;;

;; ----------
;; Problem 14
;;
;; a. Translational Semantics refers to converting the given text
;; to their own form of language using the set of rules given.
;;
;; b. For local variables we use let and the translational semantics are
;;     (let ((<var_1> <exp_1>)
;;          (<var_2> <exp_2>)
;;               .
;;               .
;;          (<var_n> <exp_n>))
;;       <body>)
;;
;; c. Not entirely sure how to demonstrate but as shown above x is var1 and 60 is exp1
;; and similarly us y. However, when the values are changed there is a nested let which
;; with have the changed values. 
;;

;; ----------
;; Problem 15
;;
;; a. the lexical addresses of a variable reference contains two elements:
;; the depth from the reference and the position as the second number.
;; Every variable reference v replaced by its lexical address, in the form of a list (v : d p)
;;
;; b. Yes it is not necessary to have variables names. We can just write them as lexical
;; addresses in the body. We only do the names for readability. 
;;
;; c. We don't need parameter names either. We can just write the number of variables similar to
;;  variable names and would refer to the lexical addresses.
;;
;; d. (lambda 2 (lambda 2 ((lambda 2 (((: 0 1) (: 1 0)) ((: 1 0) (: 0 0)))) (: 0 1) (: 1 0))))
;;

;; ----------
;; Problem 16
;;
;; a. A finite function is a function that has a finite domain. A finite function can always
;;  be written as a finite set of ordered pairs.
;;
;; b. The function-based implementation requires more code to create a finite function, with
;; a payoff in less code to apply the finite function. The data-based implementation does
;;  work when applying a finite function, with a payoff in less code and work at creation time.
;;

;; ----------
;; Problem 17


(define make-player        
      (lambda (token1 token2)      
        (lambda (current)                          
                 (if (eq? current 'current)
                     token1
                     (lambda (next)
                     (begin
                       (set! next (token2))
                       current))
             ))))   

;; ----------
;; Problem 18
;;
;; To add to the preprocessor:
;;
;; ((dim-sum? exp)  (preprocess-dim-help
;;                  (preprocess (dim-sum->left exp))
;;                  (preprocess (dim-sum->right exp))
;;                  (preprocess (dim-sum->op exp)))  )
;;
;; (define preprocess-dim-help
;;  (lambda (left op right)
;;    (if (dim-sum-op-core? op)
;;        (dim-sum-exp op left right)
;;        (error)
;;        )))

;; ----------
;; Problem 19

;; First, I would need to change the color-in-exp? that checks if its a  color in exp. I would
;; need to add an option for indefinite symbols which I can do like  the make-do syntax. I would
;; also need to change the creator fucntion and accessor funstion in the stntax. Then moving on to the
;; preprocessor, I would need to (preprocess (color-in->val sugared-exp)) multiple times so that the
;; other colors can be preprocessed as well. I would also need to change the eval-exp to cater to the
;; change.

;; ----------
;; Problem 20
;;
;; Something not covered is tail recursion and I personally found it really  interesting when learning 
;; the different ways to write factorial with recursion.
;; 1) Loops are a special case of recursion with limits
;; 2) We use tail recursion because the run-time behavior of non-tail recursive functions can be bad
;; 3) Also structuring our code in this way can help other design patterns that we want to make
;;
;;---------------
;;     end