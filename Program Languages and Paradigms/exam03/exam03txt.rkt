;; -----------------------------------------------------------------------------------------------------------------
;;
;; FILE:     exam03.rkt
;; AUTHOR:   Farhan Amjad
;; DATE:     04/01/20
;; COMMENT:  File might not complile because does not have functions like free-vars and lexical-address-for
;;           do not exist in this file. Also I used syntax-procs.rkt and utilities.rkt to track my code.
;; -----------------------------------------------------------------------------------------------------------------

#lang racket
(require "syntax-procs.rkt")
(provide (all-defined-out))
(require "utilities.rkt")

;; -----------------------------------------------------------------------------------------------------------------
;; Question 1
;; -----------------------------------------------------------------------------------------------------------------

; What is the benefit of the syntactic abstractions for the implementers of a
; language, that is, the people who write our interpreters, compilers, and IDEs?


; Ans: Syntactic Abstractions make programming easier as it abstracts away
; details of a common construction into a simpler statement. Implementers
; can then write code easily and faster such that programs are written in
; terms of domain knowledge and problem-solving strategies.

; For each of these Racket expressions, write an equivalent expression that uses only core features of the language.
; 
; a.  (lambda (f y z)          b.  (cond ((eq? key 'name) (first lst))
;       (+ (f y) (f z)))                 ((eq? key 'date) (second lst))
;                                        (else (rest (rest lst))))


; Ans. a


;(+ (f y) (f z))

; Even though lambda is used to create a new procedure with a parameter body, it
; is a syntactic form. Because procedures are objects, we can establish a
; procedure as the value of a variable and use the procedure more than once.

; Ans. b


;(if (eq? key 'name)
;    (first lst)
;    (if (eq? key 'date)
;        (second lst)
;        (rest (rest lst))))


; Consider this diagram that shows the input and output of the preprocessor for our little language (LL):
; 
;      source program     →  pre-processor  →  source program
;      in full language                        in core language
; 
; Describe the benefits of preprocessing in terms of the other programs that process programs, such as occurs-bound


; Ans: We can preprocess so that we can easily extend the laguage. This way
; we can customize the syntax of the language or add new primitives then all
; of the existing tools that process the language will work on the preprocessed
; program. Overall, it is also more easier to write a preprocessor than to
; constantly modify an interpreter.


;; -----------------------------------------------------------------------------------------------------------------
;; Question 2
;; -----------------------------------------------------------------------------------------------------------------

; Explain briefly (1-2 sentences) how we can compute the same results without a local variable using a semantically
; equivalent form that binds a value to the variable's name.


; Ans: For this course, we have been using functions instead of local variables
; throughout and an example can be lambda that binds a value to a variable's
; name. In Racket usually a compiler can translate any let expression into
; an equivalent lambda application before evaluating it.

; Demonstrate your solution using this snippet of Python code, or use the equivalent code in another language:
;      # This block creates miles as a local variable.  Give an
;      # equivalent piece of code without a local variable that
;      # binds a value to that name and computes the same result.
; 
;      miles = speed_in_mph * time_in_minutes/60
;      return miles / number_of_days


(define miles
  (lambda (speed_in_mph time_in_minutes)
    (* speed_in_mph (/ time_in_minutes 60))))

(define snippet
  (lambda (speed_in_mph time_in_minutes number_of_days)
    (/ (miles speed_in_mph time_in_minutes) number_of_days)))


;(define snippet-with-localvar
;  (lambda (speed_in_mph time_in_minutes number_of_days)
;    (let ((miles (* speed_in_mph (/ time_in_minutes 60)) ))
;      (/ miles number_of_days))))

; Question to Prof: In this snippet, what values are to be assumed one takes from the user?

(define snippet-with-program-derivation
  (lambda (speed_in_mph time_in_minutes number_of_days)
    (/ (* speed_in_mph (/ time_in_minutes 60)) number_of_days)))

;; -----------------------------------------------------------------------------------------------------------------
;; Question 3
;; -----------------------------------------------------------------------------------------------------------------

; Write a mutually recursive Racket function (or->if exp), where exp is an expression described by this grammar:
; 
;                <exp> ::= <symbol>
;                        | (or <arglist>)
; 
;            <arglist> ::= <exp>
;                        | <exp> <arglist>


(define remove
  (lambda (s los) 
    (if (null? los)
        '()
        (if (eq? (first los) s)
            (remove s (rest los))     
            (cons (first los) 
                  (remove s (rest los)))))))

;remove will remove all occurences of 'or from the list

(define or->if
  (lambda (exp)
    (if (and (symbol? (first (remove 'or exp)))
             (= (length (remove 'or exp)) 1))
        (first (remove 'or exp))
        (list (arglist->if (remove 'or exp)) (flatten (or->if (rest (remove 'or exp)))))
        )))
   
(define arglist->if           
  (lambda (or-exp)
    (list 'if (first or-exp) #t)) )


; or->if must be mutually recursive with arglist->if, which recursively converts a
; list of expressions into an if expression. Hint: have or->if strip the symbol or from
; the front of the list before calling arglist->if.


;; -----------------------------------------------------------------------------------------------------------------
;; Question 4
;; -----------------------------------------------------------------------------------------------------------------

; Replace each variable reference in these two Racket expressions with its lexical address, in the form (v : d p).


; (lambda (n)
;   (lambda (f g)
;     (+ (f n) (g n))))


;(lambda (n)
;  (lambda (f g)
;    ((+ : 2 0) ((f : 0 0) (n : 1 0)) ((g : 0 1) (n : 1 0)))))
       
; (lambda (x y)
;   (lambda (y z)
;     ( (lambda (x z)
;         ((y z) (x y)))
;       y x)))


;(lambda (x y)
;  (lambda (y z)
;    ((lambda (x z)
;       (((y : 1 0) (z : 0 1)) ((x : 0 0) (y : 1 0))))
;     (y : 0 0) (x : 1 0))))

; Give equivalent Racket expressions for these expressions in lexical address form, or explain why there is none.


; (lambda (a b c)
;   (lambda (d e)
;     (((: 0 1) (: 1 2)) (: 1 0))))


;(lambda (a b c)
;  (lambda (d e)
;    ((e c) a)))

; (lambda 2
;   (lambda 3
;     (((: 1 1) (: 0 0))
;      ((: 0 2) (: 1 0) (: 1 2)))))


;(lambda (a b)
;  (lambda (c d e)
;    ((b c)
;     (e a (: 1 2)))))
; it does not exist here because there is no
; variable at position 2 if we go 1 depth up


;; -----------------------------------------------------------------------------------------------------------------
;; Question 5
;; -----------------------------------------------------------------------------------------------------------------

; Add a case to the definition of lexical-address-helper so that it can handle with-do expressions.
; 
; Like a lambda expression, a with-do expression creates a new block declaring an identifier.
; The region ofa local variable is the body of the expression. References to a local variable
; within the body of the with-do are at a depth of 0.


; <exp> ::= <varref>
;                        | (lambda (<var>*) <exp>)
;                        | (<exp> <exp>*)
;                        | (if <exp> <exp> <exp>)
;                        | (with <var> = <exp> do <exp>)


(define lexical-address-helper
  (lambda (exp list-of-decls)
    (cond ((varref? exp)
           (lexical-address-for exp list-of-decls 0))
          ((if? exp)
           (make-if (lexical-address-helper (if->test exp) list-of-decls)
                    (lexical-address-helper (if->then exp) list-of-decls)
                    (lexical-address-helper (if->else exp) list-of-decls)))
          ((app? exp)
           (make-app (lexical-address-helper (app->proc exp) list-of-decls)
                     (map (lambda (e)
                            (lexical-address-helper e list-of-decls))
                          (app->args exp))))
          ((lambda? exp)
           (make-lambda (lambda->params exp)
                        (lexical-address-helper
                         (lambda->body exp)
                         (cons (lambda->params exp) list-of-decls))))
          ((with-do? exp)
           (make-with-do (with-do->var exp)
                         (lexical-address-helper (with-do->val exp) (cons (with-do->var exp) list-of-decls))
                         (lexical-address-helper (with-do->body exp) (cons (with-do->var exp) list-of-decls))))

           (else (error 'lexical-address-helper "unknown exp ~a" exp) ))))


;; -----------------------------------------------------------------------------------------------------------------
;;  general type predicate for expressions
;; -----------------------------------------------------------------------------------------------------------------

(define exp?
  (lambda (exp)
    (or (varref?  exp)
        (lambda?  exp)
        (app?     exp)
        (if?      exp)
        (with-do? exp))))      ; * new case *

;; -----------------------------------------------------------------------------------------------------------------
;;  syntax procedures for the with-do expression   * all new *
;; -----------------------------------------------------------------------------------------------------------------

(define with-do?
  (lambda (exp)
    (and ((list-of? 6) exp)
         (eq? 'with (first  exp))
         (symbol?   (second exp))
         (eq? '=    (third  exp))
         (exp?      (fourth exp))
         (eq? 'do   (fifth  exp))
         (exp?      (sixth  exp)))))
  
(define with-do->var  second)
(define with-do->val  fourth)
(define with-do->body sixth )

(define make-with-do
  (lambda (var val body)
    (list 'with var '= val 'do body)))

;; -----------------------------------------------------------------------------------------------------------------
;;  occurs-bound? :: symbol core-exp -> boolean
;; -----------------------------------------------------------------------------------------------------------------

;(define occurs-bound?
;  (lambda (s exp)
;    (cond ((varref? exp) #f)
;          ((lambda? exp) (or (occurs-bound? s (lambda->body exp))
;                             (and (member s (lambda->params exp))
;                                  (occurs-free? s (lambda->body exp)))))
;          ((app? exp)    (or (occurs-bound? s (app->proc exp))
;                             (ormap (lambda (arg)
;                                      (occurs-bound? s arg))
;                                    (app->args exp))))
;          ((if? exp)     (or (occurs-bound? s (if->test exp))
;                             (occurs-bound? s (if->then exp))
;                             (occurs-bound? s (if->else exp))))
;          (else (error 'occurs-bound? "invalid exp ~a" exp)))))

;; -----------------------------------------------------------------------------------------------------------------