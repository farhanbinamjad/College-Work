;;  ------------------------------------------------------------------------
;; |   FILE           :  interpreter.rkt                                    |
;; |   AUTHOR         :  Farhan Amjad                                       |
;; |   CREATION DATE  :  2020/04/16                                         |
;; |   DESCRIPTION    :  Intepreter for Huey language consisting of a       |
;; |                     preprocessor and an evaluator. I know there are    |
;;                       mistakes in eval-exp and preprocess but I didn't   |
;;                       have the time this time due to health issues.      |
;;                       I am also confused about how I can handle the      |
;;                       invert case and mix case.                          |
;;  ------------------------------------------------------------------------

#lang racket
(require "syntax-procs.rkt")
(require "utilities.rkt")
(provide (all-defined-out))

;;  ------------------------------------------------------------------------
;;   This code works with the following grammar:
;;
;;    <color> ::= (rgb <byte> <byte> <byte> )
;;              | ( <unary-op> <color> )
;;              | ( <color> <2color-op> <color> )
;;              | ( <color> <1color-op> <number> )
;;
;; <unary-op>  ::= invert | darker
;; <2color-op> ::= + | - | mix
;; <1color-op> ::= * | shift
;;
;;  ------------------------------------------------------------------------

;; -------------------------------------------------------------------------
;; preprocess :: full-exp -> core-exp
;; -------------------------------------------------------------------------

(define preprocess
  (lambda (sugared-exp)
    (cond ((rgb? sugared-exp) sugared-exp)
          ((unary-op? sugared-exp)
           (if (eq? (unary-op->op sugared-exp) 'darker)
               (1color-op (preprocess (unary-op->arg sugared-exp))
                          '*
                          '0.5)
               (unary-op  (unary-op->op sugared-exp)
                          (preprocess (unary-op->arg sugared-exp)))))
          ((2color-op? sugared-exp)
           (if (eq? (2color-op->op sugared-exp) 'mix)
               (1color-op (1color-op (preprocess (2color-op->left sugared-exp))
                                     '+
                                     (preprocess (2color-op->right sugared-exp)))
                          '*
                          '0.5)
               (2color-op (preprocess (2color-op->left sugared-exp))
                          (2color-op->op sugared-exp)
                          (preprocess (2color-op->right sugared-exp)))))
          (else (error 'preprocess "illegal expression -- ~a" sugared-exp)))))


;; -------------------------------------------------------------------------
;; evaluator
;; -------------------------------------------------------------------------

(define eval-exp
  (lambda (exp)
    (if (color? exp)
        (eval-exp-core (preprocess exp) exp)
        (error 'eval-exp "illegal expression -- ~a" exp))))

(define invert
  (lambda (exp)
    (cond ((color? exp)
        (map - 255 (rest  exp))))))

(define shift
  (lambda (exp)
    (cond ((color? exp)
        (map + 1color-op->right 1color-op->left)))))


     
(define eval-exp-core
  (lambda (exp env)
    (cond ((rgb? exp) exp)
          ((unary-op? exp)
           (invert (eval-exp-core (unary-op->arg exp) env)))
          ((2color-op? exp)
           (cond ((eq? (2color-op->op exp) '+)
                  (+ (eval-exp-core (2color-op->left exp)  env)
                     (eval-exp-core (2color-op->right exp) env)))
                 ((eq? (2color-op->op exp) '-)
                  (- (eval-exp-core (2color-op->left exp)  env)
                     (eval-exp-core (2color-op->right exp) env)))
                 ((eq? (2color-op->op exp) 'mix))))
          ((1color-op? exp)
           (cond ((eq? (1color-op->op exp) '*)
                  (* (eval-exp-core (1color-op->left exp)  env)
                     (eval-exp-core (1color-op->right exp) env)))
                 ((eq? (1color-op->op exp) 'shift)
                  (shift (eval-exp-core (1color-op->left exp)  env)
                     (eval-exp-core (1color-op->right exp) env)))))
          (else (error 'eval-exp-core "illegal expression -- ~a" exp)))))


;; -------------------------------------------------------------------------
;; repl
;; -------------------------------------------------------------------------

(define run-huey
  (lambda()
    (display "Enter a Huey expression to evaluate: ")
    (let ((exp (read)))
      (if (color? exp)
          (eval-exp exp)
          (display "Illegal expression.")))
    (newline)
    (run-huey)))

;; -------------------------------------------------------------------------