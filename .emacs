;; Character encoding
(set-language-environment "UTF-8")

;; No menubar
(menu-bar-mode -1)

;; Column & line number
(column-number-mode t)
(line-number-mode t)

;; Colors
(require 'color)
(global-font-lock-mode t)

;; Split files vertically by default
(setq split-height-threshold nil)
(setq split-width-threshold 0)

;; Show paren
(require 'paren)
(show-paren-mode)

(require 'package)
(package-initialize)

;; Indent style
(setq c-default-style "bsd")
(setq require-final-newline t)
(setq-default c-basic-offset 4
              tab-width 4
              indent-tabs-mode nil)

;; Whitespace mode (Eighty Column Rule)
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)

;; Remove whitespaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Backups
(setq backup-directory-alist `(("." . "~/.emacs.d/backups/")))
(setq backup-enable-predicate
      (lambda (name)
        (and (normal-backup-enable-predicate name)
             (not
              (let ((method (file-remote-p name 'method)))
                (when (stringp method)
                  (member method '("su" "sudo"))))))))

;; Packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

;; OPAM
(setq opam-share
  (substring
    (shell-command-to-string "opam config var share")
    0 -1))

;; Extended files
(add-to-list 'load-path (expand-file-name "~/.emacs.d"))
(add-to-list 'load-path (format "%s/emacs/site-lisp/" opam-share))
(add-to-list 'load-path (format "%s/emacs/site-lisp/patoline" opam-share))

;; Evil
(setq evil-toggle-key "C-u")
(require 'evil)
(evil-mode 1)

;; Tuareg
(load "tuareg-site-file")

;; Vala highlight
(autoload 'vala-mode "vala-mode" "Major mode for editing Vala code." t)
(add-to-list 'auto-mode-alist '("\\.vala$" . vala-mode))
(add-to-list 'auto-mode-alist '("\\.vapi$" . vala-mode))

;; Ocsigen
(add-to-list 'auto-mode-alist '("\\.eliomi?$" . tuareg-mode))

;; Haskell
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)

;; ocp-indent
(require 'ocp-indent)

;; Merlin
(require 'merlin)
(require 'merlin-iedit)
(add-hook 'tuareg-mode-hook 'merlin-mode t)
(setq merlin-use-auto-complete-mode 'easy)
(setq merlin-command 'opam)
(define-key ac-mode-map (kbd "M-TAB") 'merlin-try-completion)

(defun evil-custom-merlin-iedit ()
  (interactive)
  (if iedit-mode (iedit-mode)
    (merlin-iedit-occurrences)))
(define-key merlin-mode-map (kbd "M-r") 'evil-custom-merlin-iedit)

;; Patoline
(require 'patoline-mode)

;; Why3
(require 'why3)

;; Prolog
(autoload 'prolog-mode "prolog" "Major mode for editing Prolog programs." t)
(add-to-list 'auto-mode-alist '("\\.pl$" . prolog-mode))
