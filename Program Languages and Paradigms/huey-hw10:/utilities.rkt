;;  ------------------------------------------------------------------------
;; |   FILE           :  utilities.rkt                                      |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  20202/04/16                                        |
;; |   DESCRIPTION    :  Utility functions for Huey language interpreter.   |
;;  ------------------------------------------------------------------------

#lang racket

(provide (all-defined-out))

;; -------------------------------------------------------------------------
;; general utilities
;; -------------------------------------------------------------------------

(define list-of?
  (lambda (num)
    (lambda (lst)
      (and (list? lst)
           (= num (length lst))))))

