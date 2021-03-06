(defsystem "lwwchat"
  :version "0.1.0"
  :author "Masahiro NAGATA"
  :license "BSD 2-Clause"
  :depends-on ("websocket-driver"
               "clack"
               "cl-ppcre")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "lwwchat/tests"))))

(defsystem "lwwchat/tests"
  :author "Masahiro NAGATA"
  :license "MIT"
  :depends-on ("lwwchat"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for lwwchat"
  :perform (test-op (op c) (symbol-call :rove :run c)))
