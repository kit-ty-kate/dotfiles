(setq warning-minimum-level :error)

(require 'cl)

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

;; Do not show the annoying "Buffer list" window
(setq inhibit-startup-buffer-menu t)

;; Packages
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Indent style
(setq c-default-style "bsd")
(setq require-final-newline t)
(setq-default c-basic-offset 4
              tab-width 4
              indent-tabs-mode nil)

;; Whitespace mode (Eighty Column Rule currently disabled. Add line-tail to enable it)
(require 'whitespace)
(setq whitespace-style '(face empty tabs trailing))
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

;; Auto-save
(defconst emacs-auto-save-dir "~/.emacs.d/auto-save/")
(setq backup-directory-alist `((".*" . , emacs-auto-save-dir)))
(setq auto-save-file-name-transforms `((".*", emacs-auto-save-dir)))

;; Extended files
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'load-path (expand-file-name "~/.opam/default/share/emacs/site-lisp/"))

;; Evil
(setq evil-toggle-key "C-u")
(require 'evil)
(evil-mode 1)

;; Undo-tree
(require 'undo-tree)
(global-undo-tree-mode)
(evil-set-undo-system 'undo-tree)

;; Tuareg
(load "tuareg-site-file")
(setq auto-mode-alist
      (append '(("\\.ml[ily]?$" . tuareg-mode)
                ("\\.topml$" . tuareg-mode))
              auto-mode-alist))

;; Vala highlight
;(require 'vala-mode)
;(add-to-list 'auto-mode-alist '("\\.vala$" . vala-mode))
;(add-to-list 'auto-mode-alist '("\\.vapi$" . vala-mode))

;; Ocsigen
(add-to-list 'auto-mode-alist '("\\.eliomi?$" . tuareg-mode))

;; Haskell
;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)

;; ocp-indent
(require 'ocp-indent)

;; autocomplete
(require 'auto-complete)
(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)

;; Merlin
(let ((opam-share (ignore-errors (car (process-lines "opam" "var" "share")))))
 (when (and opam-share (file-directory-p opam-share))
  (add-to-list 'load-path (expand-file-name "emacs/site-lisp" opam-share))
  (require 'merlin)
  (require 'merlin-iedit)
  (require 'merlin-ac)
  (add-hook 'tuareg-mode-hook #'merlin-mode)
  (add-hook 'caml-mode-hook #'merlin-mode)
  (defun evil-custom-merlin-iedit ()
   (interactive)
   (if iedit-mode (iedit-mode)
    (merlin-iedit-occurrences)))
  (define-key merlin-mode-map (kbd "M-r") 'evil-custom-merlin-iedit)
  (setq merlin-locate-preference 'mli)
  (setq merlin-command 'opam)))

;; Patoline
;(require 'patoline-mode)

;; Why3
;(require 'why3)

;; Prolog
;(autoload 'prolog-mode "prolog" "Major mode for editing Prolog programs." t)
;(add-to-list 'auto-mode-alist '("\\.pl$" . prolog-mode))

;; Proof General
;(load-file "~/programming/contrib/proofgeneral/generic/proof-site.el")
;(add-hook 'proof-mode-hook
;          '(lambda ()
;             (define-key proof-mode-map [f5] 'proof-assert-next-command-interactive)
;             (define-key proof-mode-map [f6] 'proof-undo-last-successful-command)))

;; Ott
;(require 'ottmode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(undo-tree iedit evil auto-complete)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
