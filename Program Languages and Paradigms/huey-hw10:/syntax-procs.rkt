;;  ------------------------------------------------------------------------
;; |   FILE           :  syntax-procs.rkt                                   |
;; |   AUTHOR         :  Farhan Amjad                                       |
;; |   CREATION DATE  :  2020/04/16                                         |
;; |   DESCRIPTION    :  Syntax procedure functions for Huey language       |           
;;  ------------------------------------------------------------------------

#lang racket

(require "utilities.rkt")
(provide (all-defined-out))

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

;    <color> ::= (rgb <byte> <byte> <byte> )
;              | <varref>                               ; new
;              | ( <unary-op> <color> )
;              | ( <color> <2color-op> <color> )
;              | ( <color> <1color-op> <number> )
;              | ( color <var> = <color> in <color> )   ; new
;
; <unary-op> ::= invert | darker
;<2color-op> ::= + | - | mix
;<1color-op> ::= * | shift
;;  ------------------------------------------------------------------------
;;  general type predicate

(define color?
  (lambda (exp)
    (or (rgb?   exp)
        (unary-op?      exp)
        (2color-op?     exp)
        (1color-op? exp))))

;;  ------------------------------------------------------------------------

;  rgb check

(define rgb?
  (lambda (exp)
    (and ((list-of? 4) exp)
         (eq? 'rgb (first exp))
         (byte? (second exp))
         (byte? (third exp))
         (byte? (fourth exp)))))
  

;;  ------------------------------------------------------------------------
;;  unary operations

(define unary-op?
  (lambda (exp)
    (and ((list-of? 2) exp)
         (unary-operator? (first exp))
         (color? (second exp)))))

(define unary-op
  (lambda (op exp)
    (list op exp)))

(define unary-op->op
  (lambda (exp)
    (first exp)))

(define unary-op->arg
  (lambda (exp)
    (second exp)))

;;  ------------------------------------------------------------------------
;;  2color operations

(define 2color-op?
  (lambda (exp)
    (and ((list-of? 3) exp)
         (color? (first exp))
         (2color-operator? (second exp))
         (color? (third exp)))))

(define 2color-op
  (lambda (exp1 op exp2)
    (list exp1 op exp2)))

(define 2color-op->op
  (lambda (exp)
    (second exp)))

(define 2color-op->left
  (lambda (exp)
    (first exp)))

(define 2color-op->right
  (lambda (exp)
    (third exp)))

;;  ------------------------------------------------------------------------
;;  1color operations

(define 1color-op?
  (lambda (exp)
    (and ((list-of? 3) exp)
         (color? (first exp))
         (1color-operator? (second exp))
         (number? (third exp)))))

(define 1color-op
  (lambda (exp1 op exp2)
    (list exp1 op exp2)))

(define 1color-op->op
  (lambda (exp)
    (second exp)))

(define 1color-op->left
  (lambda (exp)
    (first exp)))

(define 1color-op->right
  (lambda (exp)
    (third exp)))


;;  ------------------------------------------------------------------------
;;  operators

(define *unary-operators* '(invert darker))
(define *2color-operators* '(+ - mix))
(define *1color-operators* '(* shift))


(define unary-operator?
  (lambda (exp)
    (member exp *unary-operators*)))

(define 2color-operator?
  (lambda (exp)
    (member exp *2color-operators*)))

(define 1color-operator?
  (lambda (exp)
    (member exp *1color-operators*)))

;; ----- END OF FILE -----