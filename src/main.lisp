(defpackage lwwchat
  (:use :cl :websocket-driver)
  (:export :start-server :clear-all-clients))
(in-package :lwwchat)

(defvar *clients* (make-hash-table :test #'equalp))

(defun get-command (uri &optional opt-size)
  (let ((uri-contents (ppcre:split "/" uri)))
    (when (and (>= (length uri-contents) 2)
               (string= "" (first uri-contents)))
      (let ((cmd (second uri-contents))
            (opts (cddr uri-contents)))
        (if (and opt-size (>= (length opts) opt-size))
            (list cmd (subseq opts 0 opt-size))
            (list cmd opts))))))

(defun ws-handle (env roomname)
  (let ((ws (make-server env)))
    (on :open ws
        (lambda ()
          (format t "Opened~%")
          (unless (find ws (gethash roomname *clients*))
            (push ws (gethash roomname *clients*)))))
    (on :message ws
        (lambda (msg)
          (let ((dist-clients (gethash roomname *clients*)))
            (dolist (client dist-clients)
              (unless (eq client ws)
                (send client msg))))))
    (on :close ws
        (lambda (&key code reason)
          (let ((dist-clients (gethash roomname *clients*)))
            (setf (gethash roomname *clients*)
                  (remove-if (lambda (c) (eq c ws)) dist-clients)))
          (format t "Closed~%")))
    ;; response
    (lambda (responder)
      (declare (ignore responder))
      (start-connection ws))))

(defun delete-handle (targets)
  (if (null targets)
      (setf *clients* (make-hash-table :test #'equalp))
      (dolist (target targets)
        (when (gethash target *clients*)
          (setf (gethash target *clients*) nil))))
  '(200 (:content-type "text/plain") ("Delete")))

(defun error-handle ()
  '(404 (:content-type "text/plain") ("Not found")))

(defvar *chat*
  (lambda (env)
    (let* ((uri (getf env :REQUEST-URI))
           (cmd (get-command uri)))
      (cond
        ((and (string= (first cmd) "room")
              (= 1 (length (second cmd))))
         (ws-handle env (first (second cmd))))
        ((string= (first cmd) "delete")
         (delete-handle (second cmd)))
        (t (error-handle))))))

(defun start-server (&optional (port 5000))
  (clack:clackup *chat* :server :wookie :port port))

(defun clear-all-clients ()
  (setf *clients* (make-hash-table :test #'equalp)))
