;;  ------------------------------------------------------------------------
;; |   FILE           :  syntax-procs.rkt                                   |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/03/24                                         |
;; |   DESCRIPTION    :  This file includes standard syntax procedures      |
;; |                     for a little language consisting of variable       |
;; |                     references, functions with multiple parameters,    |
;; |                     function applications, and if expressions.  We     |
;; |                     use it for the lexical addressing exercise in      |
;; |                     Sessions 19 and 20.                                |
;;  ------------------------------------------------------------------------

;; -------------------------------------------------------------------------
;;   This code works with the following grammar:
;;
;;        <exp>      ::= <varref>
;;                     | ( lambda <parameters> <exp> )
;;                     | ( <exp> . <exp-list>)
;;                     | ( if <exp> <exp> <exp> )
;;
;;      <parameters> ::= ()
;;                     | ( <var> . <parameters> )
;;
;;        <exp-list> ::= ()
;;                     | ( <exp> . <exp-list>)
;; -------------------------------------------------------------------------

#lang racket
(require "utilities.rkt")
(provide exp?
         varref?   make-varref   varref->val
         lambda?   make-lambda   lambda->params lambda->body
         app?      make-app      app->proc      app->args
         if?       make-if       if->test       if->then      if->else)

;; -------------------------------------------------------------------------
;; general type predicate
;; -------------------------------------------------------------------------

(define exp?
  (lambda (exp)
    (or (varref? exp)
        (lambda? exp)
        (app?    exp)
        (if?     exp))))

;; -------------------------------------------------------------------------
;; varrefs
;; -------------------------------------------------------------------------

(define varref?
  (lambda (s)
    (and (symbol? s)
         (not (keyword? s)))))

(define make-varref identity)
(define varref->val identity)

(define keyword?
  (lambda (s)
    (member s '(lambda if))))

;; -------------------------------------------------------------------------
;; lambda expressions
;; -------------------------------------------------------------------------

(define lambda?
  (lambda (exp)
    (and ((list-of? 3) exp)
         (eq? 'lambda (first exp))
         (list? (second exp))
         (every? symbol? (second exp))
         (exp? (third exp)))))

(define lambda->params second)
(define lambda->body   third)

(define make-lambda
  (lambda (params body)
    (list 'lambda params body)))

;; -------------------------------------------------------------------------
;; application expressions  ("apps")
;; -------------------------------------------------------------------------

(define app?
  (lambda (exp)
    (and (list? exp)
         (>= (length exp) 1)
         (every? exp? exp))))

(define app->proc first)
(define app->args rest)

(define	make-app
  (lambda (fxn args)
    (cons fxn args)))

;; -------------------------------------------------------------------------
;; if expressions
;; -------------------------------------------------------------------------

(define if?
  (lambda (exp)
    (and ((list-of? 4) exp)
         (eq?  (first  exp) 'if)
         (exp? (second exp))
         (exp? (third  exp))
         (exp? (fourth exp)))))

(define if->test second)
(define if->then third)
(define if->else fourth)

(define	make-if
  (lambda (test-exp then-exp else-exp)
    (list 'if test-exp then-exp else-exp)))

;; ----- END OF FILE -------------------------------------------------------

