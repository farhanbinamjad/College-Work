;;  ------------------------------------------------------------------------
;; |   FILE           :  syntax-procs.rkt                                   |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/02/24                                         |
;; |   DESCRIPTION    :  These functions implement syntax procedures for    |
;; |                     a simple language grammar consisting only of       |
;; |                     variable references, lambda expressions, and       |
;; |                     function applications.                             |
;;  ------------------------------------------------------------------------

#lang racket
(provide exp?
         varref?   make-varref
         lambda?   make-lambda     lambda->param   lambda->body
         app?      make-app        app->proc       app->arg)

;;   This code works with the following grammar:
;;
;;        <exp>      ::= <varref>
;;                     | ( lambda ( <var> ) <exp> )
;;                     | ( <exp> <exp> )

;; type predicate for language expressions

(define exp?
  (lambda (exp)
    (or (varref? exp)
        (lambda? exp)
        (app?    exp))))

;; varrefs

(define varref? symbol?)

(define make-varref
  (lambda (sym)
    sym))

;; lambda expressions

(define lambda?
  (lambda (exp)
    (and (list? exp)
         (= (length exp) 3)
         ; ---------------------------------- lambda keyword
         (eq? (first exp) 'lambda)
         ; ---------------------------------- parameter list
         (list? (second exp))
         (= 1 (length (second exp)))
         (varref? (first (second exp)))
         ; ---------------------------------- body
         (exp? (third exp)))))

(define lambda->param caadr)    ; (first (second exp))
(define lambda->body  third)

(define make-lambda
  (lambda (parameter body)
    (list 'lambda (list parameter) body)))

;; function applications

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

;; ----- END OF FILE -----