;;  ------------------------------------------------------------------------
;; |   FILE           :  utilities.rkt                                      |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/03/24                                         |
;; |   DESCRIPTION    :  This file contains basic utility functions for     |
;; |                     use in other files.                                |
;;  ------------------------------------------------------------------------

#lang racket
(provide list-of? every?)

;; -------------------------------------------------------------------------
;; (list-of? n) returns a predicate for n-item lists
;; -------------------------------------------------------------------------

(define list-of?
  (lambda (n)
    (lambda (obj)
      (and (list? obj)
           (eq? n (length obj))))))

;; -------------------------------------------------------------------------
;; every? is a predicate that verifies each item in lst passes test?
;; -------------------------------------------------------------------------

(define every?
  (lambda (test? lst)
    (or (null? lst)
        (and (test? (car lst))
             (every? test? (cdr lst))))))

;; ----- END OF FILE -------------------------------------------------------

