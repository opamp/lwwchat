(defpackage lwwchat/tests/main
  (:use :cl
        :lwwchat
        :rove))
(in-package :lwwchat/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :lwwchat)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
