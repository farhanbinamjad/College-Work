;;  ------------------------------------------------------------------------
;; |   FILE           :  tests.rkt                                          |
;; |   AUTHOR         :  Farhan Amjad                                       |
;; |   CREATION DATE  :  2020/04/16                                         |
;; |   DESCRIPTION    :  Tests for Huey language syntax procedures,         |
;; |                     interpreter, and utilities.                        |
;;  ------------------------------------------------------------------------

#lang racket
(require rackunit)
(require "syntax-procs.rkt")
(require "interpreter.rkt")
(require "utilities.rkt")


;;  ------------------------------------------------------------------------
;;  This code works with the following grammar:
;;
;;    <color> ::= (rgb <byte> <byte> <byte> )
;;              | ( <unary-op> <color> )
;;              | ( <color> <2color-op> <color> )
;;              | ( <color> <1color-op> <number> )
;;
;; <unary-op>  ::= invert | darker
;; <2color-op> ::= + | - | mix
;; <1color-op> ::= * | shift
;;  ------------------------------------------------------------------------


;;  ------------------------------------------------------------------------
;; |                        syntax procedures tests                         |
;;  ------------------------------------------------------------------------

;; -------------------------------------------------------------------------
;; Huey type predicates
;; -------------------------------------------------------------------------

;; rgb

(check-equal? (color? '(rgb 5 11 122)) #t)
(check-equal? (color? '(rgb 25 111 22)) #t)
(check-equal? (color? '(rgb 34 1 132)) #t)
(check-equal? (color? '(rgb 13 11 555)) #f)

;; unary operations
(check-equal? (color? '(invert (rgb 5 11 122))) #t)
(check-equal? (color? '(darker (rgb 22 16 121))) #t)

;; 2color-operations
(check-equal? (color? '((rgb 5 11 12) + (rgb 5 11 122))) #t)
(check-equal? (color? '((rgb 23 11 132) - (rgb 5 11 122))) #t)
(check-equal? (color? '((rgb 89 21 131) mix (rgb 5 11 122))) #t)




;;  ------------------------------------------------------------------------
;; |                          interpreter tests                             |
;;  ------------------------------------------------------------------------

;; -------------------------------------------------------------------------
;; preprocess
;; -------------------------------------------------------------------------
(check-equal? (preprocess '((rgb 150 99 422) mix (rgb 50 108 21)))
              '(((rgb 150 99 422) * 0.5) + ((rgb 50 108 21) * 0.5)))

