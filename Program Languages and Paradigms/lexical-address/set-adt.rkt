;;  ------------------------------------------------------------------------
;; |                                                                        |
;; |   FILE           :   set-adt.rkt                                       |
;; |   AUTHOR         :   Eugene Wallingford                                |
;; |   CREATION DATE  :   2019/03/14                                        |
;; |                                                                        |
;; |   DESCRIPTION    :   These functions implement a set datatype in       |
;; |                      Racket, including a number of common set          |
;; |                      operations.                                       |
;; |                                                                        |
;;  ------------------------------------------------------------------------

#lang racket
(provide (all-defined-out))

;;  ------------------------------------------------------------------------
;;  constructors

(define the-empty-set '())

(define set
  (lambda args
    (if (null? args)
        the-empty-set
        (set-add (car args) (apply set (cdr args))))))

;;  ------------------------------------------------------------------------
;;  accessors

(define set-one-elem car)
(define set-rest     cdr)

;;  ------------------------------------------------------------------------
;;  size and membership

(define set-size
  (lambda (s)
    (length s)))

(define set-empty?
  (lambda (s)
    (null? s)))

(define set-member?
  (lambda (e S)
    (and (not (set-empty? S))
         (or (equal? e (set-one-elem S))
             (set-member? e (set-rest S))))))

(define set-subset?
  (lambda (S1 S2)
    (or (set-empty? S1)
        (and (set-member? (set-one-elem S1) S2)
             (set-subset? (set-rest S1) S2)))))

(define set-equal?
  (lambda (S1 S2)
    (and (set-subset? S1 S2)
         (set-subset? S2 S1))))

;;  ------------------------------------------------------------------------
;;  set operations

(define set-add
  (lambda (e S)
    (if (set-member? e S)
        S
        (cons e S))))

(define set-remove
  (lambda (e S)
    (remove e S)))

(define set-union
  (lambda (S1 S2)
    (if (set-empty? S1)
        S2
        (set-add (set-one-elem S1)
                 (set-union (set-rest S1) S2)))))

(define set-minus
  (lambda (S1 S2)
    (if (set-empty? S2)
        S1
        (set-remove (set-one-elem S2)
                    (set-minus S1 (set-rest S2))))))

(define set-intersect
  (lambda (S1 S2)
    (if (set-empty? S1)
        the-empty-set
        (if (set-member? (set-one-elem S1) S2)
            (set-add (set-one-elem S1)
                     (set-intersect (set-rest S1) S2))
            (set-intersect (set-rest S1) S2)))))

(define set-union-all
  (lambda (set-list)
    (if (null? set-list)
        the-empty-set
        (set-union (set-one-elem set-list)
                   (set-union-all (set-rest set-list))))))

;; ----- END OF FILE -------------------------------------------------------
