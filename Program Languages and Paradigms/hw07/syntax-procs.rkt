;;  ------------------------------------------------------------------------
;; |   FILE           :  syntax-procs.rkt                                   |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2018/03/05                                         |
;; |   DESCRIPTION    :  These functions implement syntax procedures for    |
;; |                     a simple language grammar consisting of variable   |
;; |                     references, lambda expressions, function applica-  |
;; |                     applications, and let expressions.                 |
;;  ------------------------------------------------------------------------

#lang racket
(provide exp?
         varref?   make-varref
         lambda?   make-lambda     lambda->param lambda->body
         app?      make-app        app->proc     app->arg
         let?      make-let        let->var      let->val       let->body)

;;  ------------------------------------------------------------------------
;;   This code works with the following grammar:
;;
;;                       --------------------------- CORE FEATURES
;;        <exp>      ::= <varref>
;;                     | ( lambda ( <var> ) <exp> )
;;                     | ( <exp> <exp> )
;;                       --------------------------- ABSTRACTIONS
;;                     | ( let (<var> <exp>) <exp> )
;;  ------------------------------------------------------------------------

;;  ------------------------------------------------------------------------
;;  general type predicate

(define exp?
  (lambda (exp)
    (or (varref? exp)
        (lambda? exp)
        (app?    exp)
        (let?    exp))))

;;  ------------------------------------------------------------------------
;;  varrefs

(define varref? symbol?)

(define make-varref identity)

;;  ------------------------------------------------------------------------
;;  lambda expressions

(define lambda?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 3)
         (eq? (car exp) 'lambda)
         (varref? (caadr exp))
         (exp? (third exp)))))

(define lambda->param caadr)
(define lambda->body  third)

(define make-lambda
  (lambda (parameter body)
    (list 'lambda (list parameter) body)))

;;  ------------------------------------------------------------------------
;;  application expressions  ("apps")

(define app?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 2)
         (exp? (first exp))
         (exp? (second exp)))))

(define app->proc first)
(define app->arg  second)

(define make-app
  (lambda (fn arg)
    (list fn arg)))

;;  ------------------------------------------------------------------------
;;  let expressions

(define let?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 3)
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

(define make-let
  (lambda (var val body)
    (list 'let (list var val) body)))

;; ----- END OF FILE -----