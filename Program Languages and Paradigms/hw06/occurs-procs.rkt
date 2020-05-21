;;  ------------------------------------------------------------------------
;; |   FILE           :  occurs-procs.rkt                                   |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2018/02/18                                         |
;; |   DESCRIPTION    :  These functions analyze a static feature of the    |
;; |                     programs written in the little language from       |
;; |                     Session 12:  Does a variable occur bound in a      |
;; |                     program?  Does a variable occur free?              |
;;  ------------------------------------------------------------------------

#lang racket
(require rackunit)
(require "syntax-procs.rkt")
(provide occurs-bound? occurs-free?)

;;   This code works with the following grammar:
;;
;;        <exp>      ::= <varref>
;;                     | ( lambda ( <var> ) <exp> )
;;                     | ( <exp> <exp> )

(define occurs-bound?
  (lambda (s exp)
    (cond ((varref? exp) #f)
          ((app? exp) (or (occurs-bound? s (app->proc exp))
                          (occurs-bound? s (app->arg  exp))))
          (else       (or (occurs-bound? s (lambda->body exp))
                          (and (eq? s (lambda->param exp))
                               (occurs-free? s (lambda->body exp))))))))

(define occurs-free?
  (lambda (s exp)
    (cond ((varref? exp) (eq? s exp))
          ((app? exp)    (or (occurs-free? s (app->proc exp))
                             (occurs-free? s (app->arg  exp))))
          (else          (and (not (eq? s (lambda->param exp)))
                              (occurs-free? s (lambda->body exp)))))))

;;  ------------------------------------------------------------------------
;;  tests

(check-true  (occurs-free? 'a 'a))
(check-false (occurs-free? 'a 'b))
(check-true  (occurs-free? 'a '(lambda (b) (a b))))
(check-false (occurs-free? 'b '(lambda (b) (a b))))
(check-false (occurs-free? 'c '(lambda (b) (a b))))
(check-true  (occurs-free? 'a '(a b)))
(check-true  (occurs-free? 'b '(a b)))
(check-false (occurs-free? 'c '(a b)))
(check-false (occurs-bound? 'a 'a))
(check-false (occurs-bound? 'a '(a b)))
(check-false (occurs-bound? 'a '(lambda (b) (a b))))
(check-true  (occurs-bound? 'b '(lambda (b) (a b))))
(check-true  (occurs-bound? 'a '(lambda (a)
                                   (lambda (b)
                                     (a b)))))
(check-true  (occurs-bound? 'b '(lambda (a)
                                   (lambda (b)
                                     (a b)))))
(check-false (occurs-bound? 'c '(lambda (a)
                                   (lambda (b)
                                     (a b)))))

;;  ------------------------------------------------------------------------
