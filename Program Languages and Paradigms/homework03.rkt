;;
;; FILE:     homework03.rkt
;; AUTHOR:   Farhan Amjad
;; DATE:     02/01/2020
;; COMMENT:  Includes rackunit tests for the examples in the assignment.
;;
;; MODIFIED: 
;; CHANGE:   
;;

#lang racket
(require rackunit)

; -----   [1]   -----

(define price-per-ounce-for
  (lambda (units-per-pack ounces-per-unit)
    (lambda (pack-price)
      (/ pack-price (* ounces-per-unit units-per-pack)))))



(check-= ((price-per-ounce-for 6 16.9) 1.44) 0.01420118 0.0001)
(define big-bottles-at (price-per-ounce-for 6 24))
(check-= (big-bottles-at 2.75) 0.019097222222222224 0.0001)
(check-= (big-bottles-at 3.22) 0.022361111111111113 0.0001)
(check-= (big-bottles-at 1.75) 0.012152777777777778 0.0001)
(check-= ((price-per-ounce-for 12 25) 5.55) 0.0185 0.0001)
(check-= ((price-per-ounce-for 24 50) 11.23) 0.009358333333333333 0.0001)

; -----   [2]   -----

(define circle-area
  (lambda (r)
    (* pi (expt r 2))))

(define ring-area-around
  (lambda (inner)
    (lambda (outer)
      (- (circle-area outer) (circle-area inner)))))

(define area-for-2inch-bolt (ring-area-around 2))
(check-= ((ring-area-around 1) 2)  9.42477796076938 0.0001)
(check-= (area-for-2inch-bolt 5)  65.97344572538566 0.0001)
(check-= ((ring-area-around 2) 5)  65.97344572538566 0.0001)
(check-= ((ring-area-around 4) 7)  103.67255756846316 0.0001)

;I'm still unable to comprehend why we have to write a finction inside of a function and the need of the lambda inside another lambda expression

; -----   [3]   -----

(define average-height
  (lambda (height-weight-list)
       (apply average (map car height-weight-list))))

  (define average               ; a helper function
    (lambda numbers
      (/ (apply + numbers)
         (length numbers))))

; why do I have to put the  bracket around numbers in (lambda numbers to get it working without apply in the average-height finction.
; Why is it bad to put brackets around numbers in the function average? or why is it preffered/why didn't you put brackets?

  (check-= (average-height '((79 . 225))) 79.0 0.0001)
  (check-= (average-height '((70 . 150) (62 . 100))) 66.0 0.0001)
  (check-= (average-height '((43 . 350) (65 . 120))) 54.0 0.0001)
  (check-= (average-height '((83 . 134) (72 . 120))) 77.5 0.0001)

; -----   [4]   -----


(define total-error
  (lambda (list-of-pairs)
    (apply + (map abs (map - (map car (map cdr list-of-pairs)) (map car list-of-pairs))))))

; Can I map two procedures at the same time? ie. map abs and - at the same time to the whole list instead of mapping it twice?

(check-equal? (total-error '((2 -7) (-4 -20) (7 8) (-13 2)))
              41)
(check-equal? (total-error '((3 5) (4 20) (1 -2) (23 21)))
              23)
(check-equal? (total-error '((32 12) (-12 -1) (12 -1) (3 12)))
              53)
(check-equal? (total-error '((4 -2) (2 -10) (1 -8) (33 42)))
              36)
                           

; -----   [5]   -----
;
;(define total-capacity
;  (lambda (lista)
;    (apply + (map string->number (map car(map cdr (map cdr (map cdr (map cdr (cdr lista))))))))))
;
;(define left-capacity
;  (lambda (listb)
;    (apply + (map string->number (map car (map cdr (map cdr (map cdr (map cdr (map cdr (cdr listb)))))))))))

(define max-open-seats
  (lambda (sections)
     (apply max (map - (map string->number (map fifth (cdr sections))) (map string->number (map sixth (cdr sections)))))))

(define example '(("Dept" "Number" "Section" "Class Nbr" "Capacity" "Enrollment")
                  ("CS" "1000" "1" "11546" "30" "30")
                  ("CS" "1025" "1" "11547" "30" "30")
                  ("CS" "1120" "1" "11557" "30" "15")
                  ("CS" "1130" "1" "11548" "30" "18")))

(define example2 '(("Dept" "Number" "Section" "Class Nbr" "Capacity" "Enrollment")
                  ("CS" "1000" "1" "11546" "90" "30")
                  ("CS" "1025" "1" "11547" "30" "20")
                  ("CS" "1120" "1" "11557" "40" "25")
                  ("CS" "1130" "1" "11548" "35" "10")))

(define example3 '(("Dept" "Number" "Section" "Class Nbr" "Capacity" "Enrollment")
                  ("CS" "1000" "1" "11546" "10" "8")
                  ("CS" "1025" "1" "11547" "30" "30")
                  ("CS" "1120" "1" "11557" "30" "25")
                  ("CS" "1130" "1" "11548" "40" "40")))

(define example4 '(("Dept" "Number" "Section" "Class Nbr" "Capacity" "Enrollment")
                  ("CS" "1000" "1" "11546" "10" "8")
                  ("CS" "1025" "1" "11547" "30" "28")
                  ("CS" "1120" "1" "11557" "30" "28")
                  ("CS" "1130" "1" "11548" "12" "10")))

(check-equal? (max-open-seats example) 15)
(check-equal? (max-open-seats example2) 60)
(check-equal? (max-open-seats example3) 5)
(check-equal? (max-open-seats example4) 2)
;; -----   end   -----
