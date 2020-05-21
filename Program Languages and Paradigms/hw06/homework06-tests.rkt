;;
;; FILE:     homework06-tests.rkt
;; AUTHOR:   YOUR NAME
;; DATE:     YOUR DATE
;; COMMENT:  This file loads "homework06.rkt" and runs tests on its
;;           publicly-defined functions.
;;
;; MODIFIED: 
;; CHANGE:   
;;

#lang racket
(require rackunit)
(require "homework06.rkt")

;; --------------------------------------------------------------------------
;; Problem 1                                           (structural recursion)
;; --------------------------------------------------------------------------

(check-equal? (tails '(1 2 3)) '((1 2 3) (2 3) (3) ()))
(check-equal? (tails '(1 2 3 () () z)) '((1 2 3 () () z) (2 3 () () z) (3 () () z) (() () z) (() z) (z) ()))
(check-equal? (tails '((a b) (c d))) '(((a b) (c d)) ((c d)) ()))
(check-equal? (tails '((a b) (c d) 1 2)) '(((a b) (c d) 1 2) ((c d) 1 2) (1 2) (2) ()))

;; --------------------------------------------------------------------------
;; Problem 2                                               (mutual recursion)
;; --------------------------------------------------------------------------

(check-true (n-list? '(1 (2 (3 4) 5) 6)))
(check-false (n-list? '(1 (1 (q 4) s) d)))
(check-false (n-list? '(c)))

;; --------------------------------------------------------------------------
;; Problem 3                                           (structural recursion)
;; --------------------------------------------------------------------------

(check-equal? (tree-min '(8 (13 11 (5 24 6)) (15 (12 10 14) 20))) 5)
(check-equal? (tree-min '(8 (2 11 (5 24 6)) (15 (12 10 0) 20))) 0)
(check-equal? (tree-min '(82 (32 11 (51 24 16)) (15 (12 10 30) 20))) 10)

;; --------------------------------------------------------------------------
;; Problem 4                                                (little language)
;; --------------------------------------------------------------------------

; put your tests here

;; --------------------------------------------------------------------------
;; Problem 5                                                (little language)
;; --------------------------------------------------------------------------

(check-equal? (prefix->postfix '(square x)) '(x square))
(check-equal? (prefix->postfix '(lambda (y) (x y))) '(lambda (y) (y x)))
(check-equal? (prefix->postfix '(lambda (exp) (add1 y))) '(lambda (exp) (y add1)))

;; --------------------------------------------------------------------------

