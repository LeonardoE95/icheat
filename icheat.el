;;; icheat.el --- Interactive cheatsheet in Emacs -*- lexical-binding: t -*-
;;
;; Author: Leonardo Tamiano

(defvar icheat-cmd-list nil
  "List of dynamically generated tools.")

(defvar icheat-fmt-list nil
  "List of dynamically generated fmt options.")

(defun icheat--format (fmt)
  ;; For the resolution of each format identifier we prioritize as
  ;; follows:
  ;;
  ;; - The variable icheat-var-<format-identifier> has most precedence
  ;; - The function icheat-fmt-<format-identifier> will take care of the rest
  ;;
  ;; NOTE: we're assuming that each format used has to be defined in
  ;; the cheatsheet using the 'icheat-def-fmt' macro as showcased in
  ;; ./example/pt.el
  ;;
  (dolist (fmt-opt icheat-fmt-list)
    (let* ((var-sym (read (format "icheat-var-%s" fmt-opt)))
           (fun-sym (read (format "icheat-fmt-%s" fmt-opt)))
           (fmt-str (concat "%" fmt-opt))
           (exists? (string-match fmt-str fmt))
           (value (if (not exists?)
                      nil
                    (cond
                     ((boundp var-sym) (symbol-value var-sym))
                     ((fboundp fun-sym) (funcall fun-sym))
                     )))
           )
      (when exists?
        (setq fmt (replace-regexp-in-string fmt-str value fmt)))
      )
    )
  fmt
  )

(defmacro icheat-def-fmt (name fmt-alist)
  (let* ((func-name (intern (format "icheat-fmt-%s" name)))
         (prompt (format "%s: " name))
         (fmt-types (mapcar 'car fmt-alist))
         (ip-sym 'ip-var)
         (type-sym 'type-var)
         (output-sym 'output-var)
         (value-p-sym 'value?)
         )
    (add-to-list 'icheat-fmt-list name t)
    `(defun ,func-name (&optional ,value-p-sym)
       (interactive)
       (let* ((,type-sym (completing-read ,prompt ',fmt-types))
              (,output-sym
               (cond
                ,@(mapcar
                   (lambda (pair)
                     (let ((type (car pair))
                           (value (cdr pair)))
                       `((string= ,type-sym ,type)
                         ,value))
                     )
                   fmt-alist)
                (t ,type-sym)
                ))
              )
         ,output-sym
         )
       )
    )
  )

(defmacro icheat-def-cmd (name cmd-alist)
  (let* ((func-name (intern (format "icheat-cmd-%s" name)))
         (prompt (format "%s: " name))
         (cmd-types (mapcar 'car cmd-alist))
         (ip-sym 'ip-var)
         (type-sym 'type-var)
         (output-sym 'output-var)
         (value-p-sym 'value?)
         )
    (add-to-list 'icheat-cmd-list name t)
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
                   cmd-alist))
               )
              )
         (if ,value-p-sym
             ,output-sym
           (kill-new ,output-sym))
         )
       )
    )
  )

(provide 'icheat)
