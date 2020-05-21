;;
;; FILE:     homework04.rkt
;; AUTHOR:   Farhan Amjad
;; DATE:     02/18/20
;; COMMENT:  This module defines the five functions specified in
;;           Homework 4 as an importable module.
;;
;; MODIFIED: 
;; CHANGE:   
;;

#lang racket
(require rackunit)      ; enables you to use rackunit tests
(provide take           ; exports your functions to client code
         reject         ;      You must define a function with
         interleave     ;      each name, even if the function
         every?         ;      only returns a default value!
         positions-of)

;; --------------------------------------------------------------------------
;; Problem 1                                              (counted recursion)
;; --------------------------------------------------------------------------

(define take
  (lambda (n lst)
    (if (null? lst)
        '()
        (if (zero? n)
            '()
            (cons (first lst) (take (sub1 n) (rest lst)))))))

(check-equal? (take 2 '(a b c d e)) '(a b))
(check-equal? (take 4 '(d 2 f 3 1 d)) '(d 2 f 3))
(check-equal? (take 10 '(s w s w s9 wd f x w 2 e 33 d s w)) '(s w s w s9 wd f x w 2))


;; --------------------------------------------------------------------------
;; Problem 2                                           (structural recursion)
;; --------------------------------------------------------------------------

(define reject
  (lambda (pred? lst)
    (if (null? lst)
        '()
        (if (pred? (first lst))
            (reject pred? (rest lst))
            (cons (first lst) (reject pred? (rest lst)))))))

(check-equal? (reject negative? '(1 2 -1 -2 3 -3 5 -4 4)) '(1 2 3 5 4))
(check-equal? (reject positive? '(1 -2 2 2 1 2 2 2)) '(-2))
(check-equal? (reject number? '(2 e 3 r 4r f  f4 4)) '(e r 4r f f4))


;; --------------------------------------------------------------------------
;; Problem 3                                           (structural recursion)
;; --------------------------------------------------------------------------


(define interleave
  (lambda (lst1 lst2)
    (if (null? lst1)
        '()
        (cons (cons (first lst1) (first lst2))
              (interleave (rest lst1) (rest lst2)))
        )))


(check-equal? (interleave '(a b c d e) '(1 2 3 4 5)) '((a . 1) (b . 2) (c . 3) (d . 4) (e . 5)))
(check-equal? (interleave '(e e 2 s f g b) '(1 2 3 4 5 6 7)) '((e . 1) (e . 2) (2 . 3) (s . 4) (f . 5) (g . 6) (b . 7)))
(check-equal? (interleave '(1 2 3) '( x y z)) '((1 . x) (2 . y) (3 . z)))

;; --------------------------------------------------------------------------
;; Problem 4                                           (structural recursion)
;; --------------------------------------------------------------------------

(define every?
  (lambda (lob)
    (if (null? lob)
        #t
        (and (eq? #t (first lob)) (every? (rest lob))))))
       


(check-true (every? '(#t #t #t)))
(check-false (every? (map (lambda (n)
                      (<= n 40))
                    '(26 37 41 25 12))))
(check-false (every? '(#t #f #t #t)))

;; --------------------------------------------------------------------------
;; Problem 5                   (structural recursion and interface procedure)
;; --------------------------------------------------------------------------


(define positions-of
  (lambda (s los)
    (position s los 0)))

        
             
(define position
  (lambda (s los pos)
    (if (null? los)
        '()
        (if (eq? (first los) s)
            (cons pos (position s (rest los) (+ pos 1)))            
            (position s (rest los) (+ pos 1))
                  ))))

(check-equal? (positions-of 'a '(a b a c d a e f g a h i j k)) '(0 2 5 9))
(check-equal? (positions-of 'f '(f a)) '(0))
(check-equal? (positions-of '1 '(1 2 3 1 d d3 1 12 1)) '(0 3 6 8))


;; --------------------------------------------------------------------------
