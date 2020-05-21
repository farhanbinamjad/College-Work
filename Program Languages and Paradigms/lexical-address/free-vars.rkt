;;  ------------------------------------------------------------------------
;; |   FILE           :   free-vars.rkt                                     |
;; |   AUTHOR         :   Eugene Wallingford                                |
;; |   CREATION DATE  :   2019/03/14                                        |
;; |   DESCRIPTION    :   Returns a set of the free variable references     |
;; |                      in an expression from the little language of      |
;; |                      Sessions 19 and 20.  You wrote a similar          |
;; |                      function for Homework 7.                          |
;;  ------------------------------------------------------------------------

#lang racket
(require "syntax-procs.rkt" "set-adt.rkt")
(provide free-vars)

(define free-vars
  (lambda (exp)
    (cond
      ( (varref? exp)
           (set exp) )
      ( (lambda? exp)
           (set-minus (free-vars (lambda->body exp))
                      (lambda->params exp)) )
      ( (if? exp)
           (set-union (free-vars (if->test exp))
                      (set-union (free-vars (if->then exp))
                                 (free-vars (if->else exp)))) )
      ( else    ;; application
           (set-union (free-vars (app->proc exp))
                      (set-union-all (map free-vars (app->args exp)))) ))))

;; ----- END OF FILE -------------------------------------------------------

