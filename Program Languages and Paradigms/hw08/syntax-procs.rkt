;;  ------------------------------------------------------------------------
;; |   FILE           :  syntax-procs.rkt                                   |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/03/24                                         |
;; |   DESCRIPTION    :  This file includes standard syntax procedures      |
;; |                     for a little language consisting of variable       |
;; |                     references, functions with multiple parameters,    |
;; |                     function applications, and if expressions, and     |
;; |                     local variables.                                   |
;;  ------------------------------------------------------------------------

;;  ------------------------------------------------------------------------
;;   This code works with the following grammar:
;;
;;                       --------------------------- CORE FEATURES
;;        <exp>      ::= <varref>
;;                     | ( lambda <parameters> <exp> )
;;                     | ( <exp> . <exp-list>)
;;                     | ( if <exp> <exp> <exp> )
;;                       --------------------------- ABSTRACTIONS
;;                     | ( let (<var> <exp>) <exp> )
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
         varref? make-varref
         lambda? make-lambda lambda->params lambda->body
         app?    make-app    app->proc     app->args
         if?     make-if     if->test      if->then      if->else
         let?    make-let    let->var      let->val      let->body
         and?    make-and    and->arg1     and->arg2
         or?     make-or     or->arg1      or->arg2)

;; -------------------------------------------------------------------------
;; general type predicate
;; -------------------------------------------------------------------------

(define exp?
  (lambda (exp)
    (or (varref? exp)
        (lambda? exp)
        (app?    exp)
        (if?     exp)
        (let?    exp)
        (and?    exp)
        (or?     exp))))

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
    (member s '(lambda if let))))

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
  (lambda (fxn . args)
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

;; -------------------------------------------------------------------------
;;  let expressions
;; -------------------------------------------------------------------------

(define let?
  (lambda (exp)
    (and ((list-of? 3) exp)
         (eq? 'let (first exp))
         (binding? (second exp))
         (exp? (third exp)))))

(define binding?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 2)
         (varref? (first exp))
         (exp? (second exp)))))

(define let->var
  (lambda (let-exp)
    (first (second let-exp))))

(define let->val
  (lambda (let-exp)
    (second (second let-exp))))

(define let->body third)

(define	make-let
  (lambda (var val body)
    (list 'let (list var val) body)))

;;  ------------------------------------------------------------------------
;;  and expressions
;;  ------------------------------------------------------------------------

(define and?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 3)
         (eq? 'and (first exp))
         (exp? (second exp))
         (exp? (third exp)))))

(define and->arg1 second)
(define and->arg2 third)

(define make-and
  (lambda (arg1 arg2)
    (list 'and arg1 arg2)))

;;  ------------------------------------------------------------------------
;;  or expressions
;;  ------------------------------------------------------------------------


(define or?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 3)
         (eq? 'or (first exp))
         (exp? (second exp))
         (exp? (third exp)))))

(define or->arg1 second)
(define or->arg2 third)

(define make-or
  (lambda (arg1 arg2)
    (list 'or arg1 arg2)))


;; ----- END OF FILE -------------------------------------------------------

