;;
;; FILE:     homework07-tests.rkt
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
(require "homework07.rkt")

;; --------------------------------------------------------------------------
;; Problem 1                                          
;; --------------------------------------------------------------------------

(check-equal? (digit-sum 1984) 22)
(check-equal? (digit-sum 123) 6)
(check-equal? (digit-sum 4444) 16)
(check-equal? (digit-sum 8934) 24)

;; --------------------------------------------------------------------------
;; Problem 2                                              
;; --------------------------------------------------------------------------



;; --------------------------------------------------------------------------
;; Problem 3                                        
;; --------------------------------------------------------------------------

(check-equal? (set-add 'a '(x y z))
     '(a x y z))
(check-equal? (set-add 'y '(x y z))
     '(x y z))
(check-equal? (set-union '(a b) '(x y z))
     '(a b x y z))
(check-equal? (set-union '(a x y z b) '(x y z))
     '(a b x y z))

;; --------------------------------------------------------------------------
;; Problem 4                                               
;; --------------------------------------------------------------------------

(check-false (set-member? 'a '(x y z)))
(check-true (set-member? 'y '(x y z)))
(check-false (set-subset? '(a b) '(x y z)))
(check-true (set-subset? '(x y z) '(a x y z b)))

;; --------------------------------------------------------------------------
;; Problem 5                                               
;; --------------------------------------------------------------------------



;; --------------------------------------------------------------------------

