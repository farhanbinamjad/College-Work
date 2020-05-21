;;  ------------------------------------------------------------------------
;; |   FILE           :  homework08.rkt                                     |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/03/24                                         |
;; |   DESCRIPTION    :  a preprocessor for our little language, now with   |
;; |                     if expressions, and static analysis functions      |
;; |                     that analyze programs in the core language         |
;;  ------------------------------------------------------------------------
;; |   AUTHOR         :  Farhan Amjad                                       |
;; |   DATE           :  2020/03/xx                                         |
;; |   DESCRIPTION    :  DESCRIBE YOUR CHANGES FOR HOMEWORK 8               |
;;  ------------------------------------------------------------------------

#lang racket
(require "syntax-procs.rkt")
(require "set-adt.rkt")
(provide (all-defined-out))   ; exports every function defined in the file

;;  ------------------------------------------------------------------------
;;   This code works with the following grammar:
;;
;;                       --------------------------- CORE FEATURES
;;        <exp>      ::= <varref>
;;                     | ( lambda ( <var>* ) <exp> )
;;                     | ( <exp> <exp>* )
;;                     | ( if <exp> <exp> <exp> )
;;                       --------------------------- ABSTRACTIONS
;;                     | ( let (<var> <exp>) <exp> )
;;                     | ( and <exp> <exp>)
;;                     | ( or <exp> <exp>)
;;  ------------------------------------------------------------------------

;; --------------------------------------------------------------------------
;; preprocess :: full-exp -> core-exp
;; --------------------------------------------------------------------------


(define preprocess
  (lambda (exp)
    (cond
      ( (varref? exp) exp)
      ( (lambda? exp)
        (list 'lambda (lambda->params exp)
              (preprocess (lambda->body exp))) )
      ( (app? exp)
        (cons (preprocess (app->proc exp))
              (map preprocess (app->args exp))) )
      ( (if? exp)
        (list 'if
              (preprocess (if->test exp))
              (preprocess (if->then exp))
              (preprocess (if->else exp))) )
      ( (and? exp)
        (make-if
         (preprocess (and->arg1 exp))
         (preprocess (and->arg2 exp))
         'FALSE) )
      ( (or? exp)
        (make-if
         (preprocess (or->arg1 exp))
         'TRUE
         (preprocess (or->arg2 exp))) )
      ( else  ;; let
        (let ((var  (let->var  exp))
              (val  (let->val  exp))
              (body (let->body exp)))
          (list (list 'lambda (list var) (preprocess body))
                (preprocess val)) ) ))))

;; --------------------------------------------------------------------------
;; functions that analyze expressions in the core language
;; --------------------------------------------------------------------------

;; contains-varref? :: symbol core-exp -> boolean

(define contains-varref?
  (lambda (v exp)
    (cond ((varref? exp) (eq? v exp))
          ((lambda? exp) (or (contains-varref? v (lambda->body exp))
                             (and (member v (lambda->params exp))
                                  (contains-varref? v (lambda->body exp)))))
          ((app? exp) (or (contains-varref? v (app->proc exp))
                             (ormap (lambda (arg)
                                      (contains-varref? v arg))
                                    (app->args exp))))
          ((if? exp)     (or (contains-varref? v (if->test exp))
                             (contains-varref? v (if->then exp))
                             (contains-varref? v (if->else exp))))
          (else (error 'contains-varref? "invalid exp ~a" exp)))))
                         

;; occurs-bound? :: symbol core-exp -> boolean

(define occurs-bound?
  (lambda (s exp)
    (cond ((varref? exp) #f)
          ((lambda? exp) (or (occurs-bound? s (lambda->body exp))
                             (and (member s (lambda->params exp))
                                  (occurs-free? s (lambda->body exp)))))
          ((app? exp)    (or (occurs-bound? s (app->proc exp))
                             (ormap (lambda (arg)
                                      (occurs-bound? s arg))
                                    (app->args exp))))
          ((if? exp)     (or (occurs-bound? s (if->test exp))
                             (occurs-bound? s (if->then exp))
                             (occurs-bound? s (if->else exp))))
          (else (error 'occurs-bound? "invalid exp ~a" exp)))))

;; occurs-free? :: symbol core-exp -> boolean

(define occurs-free?
  (lambda (s exp)
    (cond ((varref? exp) (eq? s exp))
          ((lambda? exp) (and (not (member s (lambda->params exp)))
                              (occurs-free? s (lambda->body exp))))
          ((app? exp)    (or (occurs-free? s (app->proc exp))
                             (ormap (lambda (arg)
                                      (occurs-free? s arg))
                                    (app->args exp))))
          ((if? exp)     (or (occurs-free? s (if->test exp))
                             (occurs-free? s (if->then exp))
                             (occurs-free? s (if->else exp))))
          (else (error 'occurs-free? "invalid exp ~a" exp)))))

;; declared-vars :: core-exp -> set

(define declared-vars
  (lambda (exp)
    (cond ((varref? exp)
           '())
          ((lambda? exp)
           (set-union (lambda->params exp)
                      (declared-vars (lambda->body exp))))
          ((app? exp)
           (set-union (declared-vars (app->proc exp))
                      (set-union-all (map declared-vars (app->args exp)))))
          ((if? exp)
           (set-union-all (declared-vars (if->test exp))
                          (declared-vars (if->then exp))
                          (declared-vars (if->else exp))))
          (else (error 'declared-vars "invalid exp ~a" exp)))))

;; free-vars :: core-exp -> set

(define free-vars
  (lambda (exp)
    (cond ((varref? exp)
           (set exp) )
          ((lambda? exp)
           (set-minus (free-vars (lambda->body exp))
                      (lambda->params exp)) )
          ((app? exp)
           (set-union (free-vars (app->proc exp))
                      (set-union-all (map free-vars (app->args exp)))))
          ((if? exp)
           (set-union (free-vars (if->test exp))
                      (set-union (free-vars (if->then exp))
                                 (free-vars (if->else exp)))) )
          (else (error 'free-vars "invalid exp ~a" exp)))))

;; --------------------------------------------------------------------------
