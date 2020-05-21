;;  ------------------------------------------------------------------------
;; |   FILE           :  homework09.rkt                                     |
;; |   AUTHOR         :  FARHAN AMJAD                                       |
;; |   CREATION DATE  :  2020/04/08                                         |
;; |   DESCRIPTION    :                                                     |
;; |                                                                        |
;;  ------------------------------------------------------------------------


#lang racket

(provide (all-defined-out))
;; --------------------------------------------------------------------------
;; Problem 1
;; --------------------------------------------------------------------------

(define vector-sum
  (lambda (von)
    (vector-helper von 0)
    ))

(define vector-helper
  (lambda (von pos)
    (if (< pos (vector-length von))
        (+ (vector-ref von pos) (vector-helper von (+ 1 pos)))
        0)
    ))

;; --------------------------------------------------------------------------
;; Problem 2
;; --------------------------------------------------------------------------

(define rle-first
  (lambda (rle-lst)
    (cond ((number? (first rle-lst)) (first rle-lst))
          ((char? (first rle-lst)) (first rle-lst))
          ((symbol? (first rle-lst)) (first rle-lst))
          (else (car (first rle-lst)))
          )))


;; --------------------------------------------------------------------------
;; Problem 3
;; --------------------------------------------------------------------------

(define rle-rest
  (lambda (rle-lst)
    (cond ((number? (first rle-lst)) (rest rle-lst))
          ((char? (first rle-lst)) (rest rle-lst))
          ((symbol? (first rle-lst)) (rest rle-lst))
          (else (rest-helper rle-lst)))
    ))

(define rest-helper
  (lambda (rle-lst)
    (if (eq? (cdr (first rle-lst)) 2)
        (cons (car (first rle-lst)) (rest rle-lst))
        (cons (cons (car (first rle-lst)) (sub1 (cdr (first rle-lst)))) (rest rle-lst))
        )))

;; --------------------------------------------------------------------------
;; Problem 4
;; --------------------------------------------------------------------------

(define rle-add
  (lambda (value rle-lst)
    (cond ((null? rle-lst) (list value))
          ((number? (first rle-lst)) (rle-equal-helper value rle-lst))
          ((char? (first rle-lst)) (rle-equal-helper value rle-lst))
          ((symbol? (first rle-lst)) (rle-equal-helper value rle-lst))
          (else (rle-pair-helper value rle-lst)))
    ))
  
(define rle-equal-helper
  (lambda (value rle-lst)
    (if (eq? value (first rle-lst))
        (cons (cons value 2) (rest rle-lst))
        (cons value rle-lst))
    ))

(define rle-pair-helper
  (lambda (value rle-lst)
    (cond ((eq? (car (first rle-lst)) value)
           (cons (cons value (add1 (cdr (first rle-lst)))) (rest rle-lst)))
          (else (cons value rle-lst)))
    ))


;; --------------------------------------------------------------------------
;; Problem 5
;; --------------------------------------------------------------------------

;(define run-length-encode
;  (lambda (lst)
;    (run-length-encode-helper lst '())
;    ))
;
;(define run-length-encode-helper
;  (lambda (lst new-lst)
;    (if (null? lst)
;        new-lst
;        (append (rle-add (first lst) new-lst) (run-length-encode-helper (rest lst) new-lst))   
;        )))

(define run-length-encode
  (lambda (lst)
    (let ((new-lst '()))
      (if (null? lst)
        (append '())
        (append (rle-add (first lst) new-lst) (run-length-encode (rest lst)))    
      ))))


;(run-length-encode '(1 2 2 3 3 3 4 4 4 4 5 5 5 6 6 7))
; >    '(1 (2 . 2) (3 . 3) (4 . 4) (5 . 3) (6 . 2) 7)

