;;  ------------------------------------------------------------------------
;; |   FILE           :  homework08-tests.rkt                               |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   DATE           :  2019/03/24                                         |
;; |   DESCRIPTION    :  an incomplete set of tests for the analysis        |
;; |                     from Homework 8, extended with cases for           |
;; |                     the little language in Homework 8 (with if exps)   |
;;  ------------------------------------------------------------------------
;; |   AUTHOR         :  YOUR NAME HERE                                     |
;; |   DATE           :  2019/03/xx                                         |
;; |   DESCRIPTION    :  DESCRIBE YOUR CHANGES FOR HOMEWORK 8               |
;;  ------------------------------------------------------------------------

#lang racket
(require rackunit)
(require "syntax-procs.rkt")
(require "homework08.rkt")

;; --------------------------------------------------------------------------
;; occurs-bound? :: symbol core-exp -> boolean
;; occurs-free?  :: symbol core-exp -> boolean

(check-true  (occurs-bound? 'a (preprocess '(let (a b)
                                              (let (c (lambda (d) a))
                                                (if x y (c a)))))))

(check-false (occurs-bound? 'b (preprocess '(let (a b)
                                              (let (c (lambda (d) a))
                                                (if x y (c a)))))))

(check-false (occurs-free? 'a (preprocess '(let (a b)
                                             (let (c (lambda (d) a))
                                               (if x y (c a)))))))

(check-true (occurs-free? 'b (preprocess '(let (a b)
                                            (let (c (lambda (d) a))
                                              (if x y (c a)))))))

;; --------------------------------------------------------------------------
;; declared-vars :: core-exp -> set

(check-equal? (declared-vars (preprocess '(let (a b)
                                            (let (c (lambda (d) a))
                                              (c a)))))
                             '(a c d))

;; --------------------------------------------------------------------------
;; free-vars :: core-exp -> set

(check-equal? (free-vars 'x)
             '(x))
(check-equal? (free-vars '(square x))
             '(square x))
(check-equal? (free-vars '(if x
                              (lambda (y) (f y))
                              (lambda (z) (g z))))
             '(x f g))
(check-equal? (free-vars '(lambda (y) (x y)))
             '(x))
(check-equal? (free-vars '((lambda (y) (y (square x)))
                           (lambda (y) (f y))))
              '(square x f))
(check-equal? (free-vars (preprocess '(let (a b)
                                        (let (c (lambda (d) a))
                                          (c a)))))
             
             '(b))
(check-equal? (free-vars (preprocess '(let (a (f b))
                                        (if a (c a) (d a)))))
             
             '(c d f b))

;; --------------------------------------------------------------------------
;; syntax-procs tests

(check-true   (and? '(and x y)) #t)
(check-false  (and? '(x y)) #f)
(check-equal? (make-and 'exp1 'exp2) '(and exp1 exp2))
(check-equal? (and->arg1 '(and x y)) 'x)
(check-equal? (and->arg2 '(and x y)) 'y)

(check-true   (or? '(or x y)) #t)
(check-false  (or? '(x y)) #f)
(check-equal? (make-or 'exp1 'exp2) '(or exp1 exp2))
(check-equal? (or->arg1 '(or x y)) 'x)
(check-equal? (or->arg2 '(or x y)) 'y)

;; --------------------------------------------------------------------------
;; declared-vars :: core-exp -> set

(check-true  (contains-varref? 'y 'y))

(check-false (contains-varref? 'y '(lambda (y) x)))

(check-true (contains-varref? 'x '(f (lambda (y) x))))

(check-true (contains-varref? 'x '( (lambda (x) y)      
                               (lambda (y) x) )))   

;; --------------------------------------------------------------------------

