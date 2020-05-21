;;
;; FILE:     homework05.rkt
;; AUTHOR:   Farhan Amjad
;; DATE:     02/21/20
;; COMMENT:  This module defines the five functions specified in
;;           Homework 5 as an importable module.  Notice how each
;;           each function has a body and returns a default value.
;;           Writing stubs of this sort enables us to load the file
;;           and run tests, even if the tests fail.
;;
;; MODIFIED: 
;; CHANGE:   
;;

#lang racket
(provide prefix-of? includes-course? nlist+ max-length prefix->infix)

;; --------------------------------------------------------------------------
;; Problem 1                                           (structural recursion)
;; --------------------------------------------------------------------------

(define prefix-of?
  (lambda (lst1 lst2)
    (if (null? lst1)
        #t
        (if (eq? (first lst1) (first lst2))
            (prefix-of? (rest lst1) (rest lst2))
            #f)
        )))

        

;; --------------------------------------------------------------------------
;; Problem 2                                               (mutual recursion)
;; --------------------------------------------------------------------------

(define includes-course?
  (lambda (course requirements)
    (if (null? requirements)
        #f
        (or (includes-course-ce? course (first requirements)) (includes-course? course (rest requirements))))
         ))


(define includes-course-ce?
  (lambda (course course-exp)
    (if (symbol? course-exp)
        (eq? course course-exp)
        (includes-course? course course-exp))))

;<course-tree> ::= ()
;                 | (<course-exp> . <course-tree>)
;<course-exp> ::= <symbol>
;                 | <course-tree>
    
;; --------------------------------------------------------------------------
;; Problem 3                                               (mutual recursion)
;; --------------------------------------------------------------------------

(define nlist+
  (lambda (nlst)
    (if (null? nlst)
        0
        (+ (num-expr+ (first nlst)) (nlist+ (rest nlst))
           
        ))))

(define num-expr+
  (lambda (nexp)
    (if (number? nexp)
        nexp
        (nlist+ nexp))
        ))


;<n-list> ::= ()
;            | (<number-exp> . <n-list>)
;<number-exp> ::= <number>
;            | <n-list>

;; --------------------------------------------------------------------------
;; Problem 4                                               (mutual recursion)
;; --------------------------------------------------------------------------

(define max-length
  (lambda (str-list)
    (if (null? str-list)
        -1
        (max (max-length-se (first str-list)) (max-length (rest str-list))))
        ))
        
(define max-length-se
  (lambda (str-exp)
    (if (string? str-exp)
        (string-length str-exp)
        (max-length str-exp))))

;<string-list> ::= ()
;                 | (<string-exp> . <string-list>)
;<string-exp> ::= <string>
;                 | <string-list>

;; --------------------------------------------------------------------------
;; Problem 5                                               (mutual recursion)
;; --------------------------------------------------------------------------

(define prefix->infix
  (lambda (binary-exp)      ; This is a default value, used as a placeholder.
    (if (null? binary-exp)
        '()                 ; It will fail all but one test.
         (number-expr->infix binary-exp))))

(define number-expr->infix
  (lambda (binary-exp)
    (cond ((and (list? (second binary-exp)) (list? (third binary-exp))) (prefix->infix (second binary-exp)) (prefix->infix (third binary-exp)))
          ((list? (second binary-exp)) (prefix->infix (second binary-exp))) 
          ((list? (third binary-exp)) (prefix->infix (third binary-exp)))
          )
    (list (second binary-exp) (first binary-exp) (third binary-exp))))

;; --------------------------------------------------------------------------