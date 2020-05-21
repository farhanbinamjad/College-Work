;;
;; FILE:     homework02.rkt
;; AUTHOR:   Farhan Amjad
;; DATE:     01/25/20
;; COMMENT:  Provides templates for your solutions, plus a few tests.
;;
;; MODIFIED: 
;; CHANGE:   
;;

#lang racket
(require rackunit)      ; enables you to use rackunit tests

; -----   [1]   -----

(define average
  (lambda (i j k)
    (/ (+ i j k) 3)))

(check-equal? (average 2 3 12)     17/3)
(check-equal? (average 9 18 12)    13)
(check-equal? (average 6 5 12)     23/3)
(check-equal? (average 5 10 3)     6)
(check-equal? (average 104 111 13) 76)
(check-equal? (average 6 -6 9)     3)

; -----   [2]   -----

(define price-per-ounce
  (lambda (units-per-pack ounces-per-unit pack-price)
    (/ pack-price (* ounces-per-unit units-per-pack))))

(check-= (price-per-ounce 6 24   1.44) 0.01       0.00001)
(check-= (price-per-ounce 6 16.9 1.44) 0.01420118 0.00001)

; -----   [3]   -----

(define ring-area
  (lambda (ladder-length base-distance)
    (- (* pi base-distance base-distance) (* pi ladder-length ladder-length))))

(check-equal? (ring-area 1 2) 9.42477796076938)
(check-equal? (ring-area 6 24) 1696.4600329384882)
(check-equal? (ring-area 5 20) 1178.0972450961724)

; -----   [4]   -----

(define candy-temperature
  (lambda (temp elevation)
    (- temp (/ elevation 500))))

(check-= (candy-temperature 244 5280) 233.44 0.00001)
(check-= (candy-temperature 302 977.69) 300.04462 0.00001)
(check-= (candy-temperature 302 -1401) 304.802 0.00001)

; -----   [5]   -----

(define in-range?
  (lambda (actual desired epsilon)
    (< (abs (- actual desired)) epsilon)
        ))

(check-true  (in-range? 4.95 5.0 0.1))
(check-false (in-range? 4.95 5.0 0.01))     ;; not anymore!
(check-true  (in-range? 5.0 4.95 0.1))      ;; works both ways
(check-false (in-range? 5.0 5.95 0.1))
(check-true  (in-range? 5.5 5.95 0.5))

; -----   end   -----