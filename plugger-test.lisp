(in-package #:plugger-test)

(define-test included-plugins-test
  (multiple-value-bind (success loaded) (load-plugins "./test_plugins/load" :included-plugins nil)
    (reset-plugins)
    (assert-equal 0 success)
    (assert-equal nil loaded)))
(define-test excluded-plugins-test
  (multiple-value-bind (success loaded) (load-plugins "./test_plugins/load" :excluded-plugins '("plugin"))
    (reset-plugins)
    (assert-equal 0 success )
    (assert-equal nil loaded )))
(define-test basic-load-test
  (multiple-value-bind (success loaded) (load-plugins "./test_plugins/load")
    (reset-plugins)
    (assert-equal 1 success )
    (assert-equal '(("plugin" . :success)) loaded ) ))
(define-test error-test
  (multiple-value-bind (success loaded) (load-plugins "./test_plugins/load-failure")
    (reset-plugins)
    (assert-equal 0 success)
    (assert-equal '(("plugin" . :error)) loaded )))
(define-test load-order-test
  (multiple-value-bind (success loaded) (load-plugins "./test_plugins/load-order" :load-order-test #'string>)
    (reset-plugins)
    (assert-equal 2 success )
    (assert-equal '(("b" . :success)
                    ("a" . :success)) loaded )))
(define-test plugin-defhook-test
  (setf *plugger-hooks* nil)
  (assert-equal (defplughook :test) '((:test))))
(define-test plugin-with-hook-test
  (setf *plugger-hooks* nil)
  (defplughook :test)
  (defun hook-test () 0)
  (with-plug-hook 'test :test #'hook-test)
  (assert-equal 2 (length (car *plugger-hooks*))))
(define-test plugin-hook-test
  (setq *plugger-hooks* nil)
  (defplughook :test)
  (with-plug-hook 'test :test (lambda () 0))
  (multiple-value-bind (success results) (trigger-hook :test ())
    (assert-equal success 1)
    (assert-equal results '((test :success (0))))))
(define-test plugin-import-test
  (reset-plugins)
  (load-plugins "./test_plugins/import-test" :die-on-error t))
(define-test error-test-and-die
  (reset-plugins)
  (assert-error 'error (load-plugins "./test_plugins/load-failure" :die-on-error t)))
