;;
;; FILE:     homework06.rkt
;; AUTHOR:   Farhan Amjad
;; DATE:     2/26/20
;; COMMENT:  This module defines the five functions specified in
;;           Homework 6 as an importable module.  Use the function
;;           stub if you do not have a working solution of your own.
;;
;; MODIFIED: 
;; CHANGE:   
;;

#lang racket
(require "syntax-procs.rkt")
(require "occurs-procs.rkt")
(provide tails n-list? tree-min declared-vars prefix->postfix)

;; --------------------------------------------------------------------------
;; Problem 1                                           (structural recursion)
;; --------------------------------------------------------------------------

(define tails
  (lambda (lst)
    (if (null? lst)
        '(())
        (cons lst (tails (rest lst)))
        )))          

;; --------------------------------------------------------------------------
;; Problem 2                                               (mutual recursion)
;; --------------------------------------------------------------------------

(define n-list?
  (lambda (obj)
    (or (null? obj)
        (and (num-expr? (car obj)) (n-list? (cdr obj)))
        )))

(define num-expr?
  (lambda (obj)
    (if (symbol? obj)
        #f
        (or (number? obj) (n-list? obj))             
        )))

; <n-list> ::= ()
;             | (<number-exp> . <n-list>)
;
;<number-exp> ::= <number>
;             | <n-list>

;; --------------------------------------------------------------------------
;; Problem 3                                           (structural recursion)
;; --------------------------------------------------------------------------

(define tree-min
  (lambda (bin-tree)
    (if (number? bin-tree)
        bin-tree
        (min (tree-min (first bin-tree)) (tree-min (second bin-tree)) (tree-min (third bin-tree)))
        ))) 


;<binary-tree> ::= <number>
;               |  (<number> <binary-tree> <binary-tree>)

;; --------------------------------------------------------------------------
;; Problem 4                                                (little language)
;; --------------------------------------------------------------------------

(define declared-vars
  (lambda (exp)
    (cond
      ((lambda? exp) (list (lambda->param exp)
                           (declared-vars (lambda->body exp))))
      ((app? exp) (append (declared-vars (app->proc exp))
                  (declared-vars (app->arg exp))))
                  
      )))


;<exp> ::= <varref>
;         | (lambda (<var>) <exp>)
;         | (<exp> <exp>)

;; --------------------------------------------------------------------------
;; Problem 5                                                (little language)
;; --------------------------------------------------------------------------

(define prefix->postfix
  (lambda (exp)
    (cond
      ((lambda? exp) (make-lambda (lambda->param exp) (make-app (app->arg (lambda->body exp)) (app->proc (lambda->body exp)))))
      ((app? exp) (prefix->postfix (app->proc exp)) (prefix->postfix (app->arg exp)) (make-app (first (rest exp)) (first exp))
                  ))))


;<exp> ::= <varref>
;        | (lambda (<var>) <exp>)
;        | (<exp> <exp>)
;; --------------------------------------------------------------------------