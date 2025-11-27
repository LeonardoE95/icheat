;;; icheat.el --- Interactive cheatsheet in Emacs -*- lexical-binding: t -*-
;;
;; Author: Leonardo Tamiano

(defvar icheat-cmd-list nil
  "A list of dynamically generated tool command function symbols.")

(defun icheat--format (fmt)
  ;; TODO: for the resolution of each format identifier we can
  ;; approach it in three different ways:
  ;;
  ;; - check if there is a direct variable icheat-var-<format-identifier>
  ;; - check if there is a function icheat-cmd-<format-identifier>
  ;; - ask input to the user
  ;;
  (let* ((ip-var (if (boundp 'my/ip) my/ip "0.0.0.0"))
         (fmt (replace-regexp-in-string "%ip" "127.0.0.1" fmt))
         (fmt (replace-regexp-in-string "%port" "4321" fmt))
         (fmt (if (string-match-p "%wordlist" fmt)
                  (replace-regexp-in-string "%wordlist" (icheat-cmd-wordlist t) fmt)
                fmt
                ))
         (fmt (if (string-match-p "%extension" fmt)
                  (replace-regexp-in-string "%extension" (icheat-cmd-extension t) fmt)
                fmt
                ))
         )
    fmt
    )
  )

(defmacro icheat-def-cmd (tool-name software? cmd-alist)
  (let* ((func-name (intern (format "icheat-cmd-%s" tool-name)))
         (prompt (format "%s: " tool-name))
         (cmd-types (mapcar 'car cmd-alist))
         (ip-sym 'ip-var)
         (type-sym 'type-var)
         (output-sym 'output-var)
         (value-p-sym 'value?)
         )
    (when software?
      (add-to-list 'my/tool-cmd-list tool-name t))
    (if (not cmd-alist)
        `(defun ,func-name (&optional ,value-p-sym)
           (interactive)
           (message "No commands defined for tool '%s'." ,tool-name)
           nil)
      `(defun ,func-name (&optional ,value-p-sym)
         (interactive)
         (let* ((,type-sym (completing-read ,prompt ',cmd-types))
                (,output-sym
                 (cond
                  ,@(mapcar
                     (lambda (pair)
                       (let ((type (car pair))
                             (format-string (cdr pair)))
                         `((string= ,type-sym ,type)
                           (icheat--format
                            (icheat--format ,format-string)))))
                     cmd-alist)))
                )
           (if ,value-p-sym
               ,output-sym
             (kill-new ,output-sym))
           )
         )
      )
    )
  )

(provide 'icheat)
