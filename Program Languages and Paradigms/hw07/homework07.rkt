;;  ------------------------------------------------------------------------
;; |   FILE           :  homework07.rkt                                     |
;; |   AUTHOR         :  Eugene Wallingford                                 |
;; |   CREATION DATE  :  2020/03/05                                         |
;; |   DESCRIPTION    :  a preprocessor for our little language             |
;; |                     and functions that analyze programs in the core    |
;;  ------------------------------------------------------------------------
;; |   MODIFIED BY    :  Farhan Amjad                                       |
;; |   CREATION DATE  :  2020/03/09                                         |
;; |   DESCRIPTION    :  [ what you added and changed ]                     |
;;  ------------------------------------------------------------------------

#lang racket
(require "syntax-procs.rkt")
(provide digit-sum curry
         set-add   set-union   set-member?   set-subset?
         free-vars preprocess)

;; --------------------------------------------------------------------------
;; Problem 1                                           (structural recursion)
;; --------------------------------------------------------------------------

(define digit-sum
  (lambda (n)
    (if (digit? n)
        n
        (+ (remainder n 10) (digit-sum (quotient n 10)))
        )))

(define digit?
  (lambda (n)
    (if (eq? 0 (quotient n 10))
        #t
        #f)
    ))

;(define digit-sum
;  (lambda (n)
;    (if (< n 0)
;        "non negetive integer"
;        (if (eq? (quotient n 10) 0)
;            n
;            (+ (remainder n 10) (digit-sum (quotient n 10)))))))

;-----not sure which one is better (went with readability)-----

;; --------------------------------------------------------------------------
;; Problem 2                                          (syntactic abstraction)
;; --------------------------------------------------------------------------

(define curry
  (lambda (lambda-exp)
    (make-lambda (lambda->param (curry (lambda->body)))) 
    ))

; > (curry '(lambda (x y z) anything))
;     '(lambda (x)
;        (lambda (y)
;          (lambda (z)
;            anything)))

;; --------------------------------------------------------------------------
;; Problem 3                                           (structural recursion)
;; --------------------------------------------------------------------------

;(define set-add
;  (lambda (sym S)
;    (remove-duplicates (append S (list sym)))
;    ))

;-----is this not a better way of writing the set-add function?-----

(define set-add
  (lambda (sym S)
    (if (member sym S)
        S
        (cons sym S))))


;(define set-union
;  (lambda (S1 S2)
;    (remove-duplicates (append S1 S2))
;    ))


(define set-union
  (lambda (S1 S2)
    (if (null? S1)
        S2
        (let ((nwlst (set-add (last S1) S2)))
          (set-union (remove (last S1) S1) nwlst))
        )))

    
;; --------------------------------------------------------------------------
;; Problem 4                                           (structural recursion)
;; --------------------------------------------------------------------------

(define set-member?
  (lambda (sym S)
    (if (member sym S)
        #t
        #f
        )))

(define set-subset?
  (lambda (S1 S2)
    (if (null? S1)
        #t
        (let ((nwlst (set-member? (first S1) S2)))
          (and nwlst (set-subset? (rest S1) S2)))
        )))
    

;; --------------------------------------------------------------------------
;; Problem 5                                               (mutual recursion)
;; --------------------------------------------------------------------------

(define free-vars
  (lambda (exp)
    (cond
      ((varref? exp) (set-add exp '()))
      ((app? exp) (free-vars (app->proc exp))
                  (free-vars (app->arg  exp)))
      (else (free-vars (lambda->body exp)))
       )))

;;                       --------------------------- CORE FEATURES
;;        <exp>      ::= <varref>
;;                     | ( lambda ( <var> ) <exp> )
;;                     | ( <exp> <exp> )
;;                       --------------------------- ABSTRACTIONS
;;                     | ( let (<var> <exp>) <exp> )

;; --------------------------------------------------------------------------
;; preprocess :: full-exp -> core-exp          (for use in testing Problem 5)
;; --------------------------------------------------------------------------

(define preprocess
  (lambda (exp)
    (cond
      ( (varref? exp) (make-varref exp) )
      ( (lambda? exp)
        (make-lambda (lambda->param exp)
                     (preprocess (lambda->body exp))) )
      ( (app? exp)
        (make-app (preprocess (app->proc exp))
                  (preprocess (app->arg  exp))) )
      ( else  ;; let
        (let ((var  (let->var  exp))
              (val  (let->val  exp))
              (body (let->body exp)))
          (make-app (make-lambda var (preprocess body))
                    (preprocess val)) ) ))))

;; --------------------------------------------------------------------------
