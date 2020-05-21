;;  ------------------------------------------------------------------------
;; |   FILE           :  list-index.rkt                                     |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/03/24                                         |
;; |   DESCRIPTION    :  list-index returns the 0-based position of an      |
;; |                     item in a list, or -1 if not found.  We first      |
;; |                     encountered this function in Session 17 and its    |
;; |                     reading, when learning about letrec.               |
;;  ------------------------------------------------------------------------

#lang racket
(provide list-index)

(define list-index
  (lambda (target los)
    (letrec ((list-index-helper
               (lambda (los base)
                 (if (null? los)
                     -1
                     (if (eq? target (first los))
                         base
                         (list-index-helper (rest los) (add1 base)))))))
      (list-index-helper los 0))))

;; ----- END OF FILE -------------------------------------------------------
