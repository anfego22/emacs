;; Melpa

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.


;;; Code:
(package-initialize)
(require 'use-package)
(require 'package)


(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))


(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(global-hl-line-mode 1)
(global-visual-line-mode 1)
(setq-default indent-tabs-mode nil)
(setq inhibit-startup-message t)
(setq backup-directory-alist `(("." . "~/.saves")))


;; Org-mode
(require 'org)
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(setq org-log-done t)

;; Themes
;; (use-package vscode-dark-plus-theme
;;   :ensure t
;;   :config
;;   (load-theme 'vscode-dark-plus t))


;; Swipper
(require 'swiper)
(global-set-key "\C-s" 'swiper)
(global-set-key "\C-r" 'swiper-backward)
(global-set-key "\M-p" 'backward-paragraph)
(global-set-key "\M-n" 'forward-paragraph)

;; Who am I
(setq user-mail-address "anfego22@gmail.com")
(setq user-full-name "Andres Gonzalez")

;; Magit
(require 'magit)
(setq magit-fetch-modules-jobs 16)

;; Navigation inside code project
(require 'projectile)
(projectile-mode "1.0")

;; tree emacs
(use-package treemacs
  :ensure t
  :defer t
  :config
  (setq treemacs-no-png-images t
	  treemacs-width 24)
  :bind ("C-x C-n" . treemacs))


;; LSP-mode
(use-package lsp-mode
:ensure t
:defer t
:commands (lsp lsp-deferred)
:init (setq lsp-keymap-prefix "C-c l")
:hook (python-mode . lsp-deferred))


;; Company
(use-package company
  :ensure t
  :defer t
  :diminish
  :config
  (setq company-dabbrev-other-buffers t
        company-dabbrev-code-other-buffers t)
  :hook ((text-mode . company-mode)
         (prog-mode . company-mode)))

;; hover info
(use-package lsp-ui
  :ensure t
  :defer t
  :config
  (setq lsp-ui-sideline-enable nil
	    lsp-ui-doc-delay 2)
  :hook (lsp-mode . lsp-ui-mode)
  :bind (:map lsp-ui-mode-map
	      ("C-c i" . lsp-ui-imenu)))

;; Debugging
(use-package dap-mode
  :ensure t
  :defer t
  :after lsp-mode
  :config
  (dap-auto-configure-mode))

;; lsp pyright
(use-package lsp-pyright
  :ensure t
  :defer t
  :config
  (setq lsp-clients-python-library-directories '("/usr/" "/home/anfego-air/.local/lib/python3.8/site-packages"))
  (setq lsp-pyright-disable-language-service nil
	lsp-pyright-disable-organize-imports nil
	lsp-pyright-auto-import-completions t
	lsp-pyright-use-library-code-for-types t
        ;;	lsp-pyright-venv-path "~/miniconda3/envs"
        )
  :hook ((python-mode . (lambda ()
                          (require 'lsp-pyright) (lsp-deferred)))))

;; YAP formatter
;; pip3 install yap
(use-package yapfify
  :ensure t
  :defer t
  :hook
  (python-mode . yapf-mode)
  (before-save-hook . yapfify--buffer)
 )

;; importmagic python
;; pip3 install importmagic epc
(use-package importmagic
    :ensure t
    :config
    :hook
    (python-mode . importmagic-mode)
    )


;; Yasnippet
(require 'yasnippet)
(yas-global-mode 1)


;; Go
(require 'go-mode)
(add-hook 'go-mode-hook #'lsp)
(add-hook 'go-mode-hook (lambda ()
  (company-mode) ; enable company upon activating go
  ;;(set (make-local-variable 'company-backends) '(company-go))
  ;; Code layout.
  ;;(setq tab-width 2 indent-tabs-mode 1) ; std go whitespace configuration
  (setq tab-width 4)
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save) ; run gofmt on each save

  ;; Shortcuts for common go-test invocations.
  (let ((map go-mode-map))
    (define-key map (kbd "C-c a") 'go-test-current-project) ;; current package, really
    (define-key map (kbd "C-c m") 'go-test-current-file)
    (define-key map (kbd "C-c .") 'go-test-current-test)
    )

  ;; Fix parsing of error and warning lines in compiler output.
  (setq compilation-error-regexp-alist-alist ; first remove the standard conf; it's not good.
        (remove 'go-panic
                (remove 'go-test compilation-error-regexp-alist-alist)))
  ;; Make another one that works better and strips more space at the beginning.
  (add-to-list 'compilation-error-regexp-alist-alist
               '(go-test . ("^[[:space:]]*\\([_a-zA-Z./][_a-zA-Z0-9./]*\\):\\([0-9]+\\):.*$" 1 2)))
  (add-to-list 'compilation-error-regexp-alist-alist
               '(go-panic . ("^[[:space:]]*\\([_a-zA-Z./][_a-zA-Z0-9./]*\\):\\([0-9]+\\)[[:space:]].*$" 1 2)))
  ;; override.
  (add-to-list 'compilation-error-regexp-alist 'go-test t)
  (add-to-list 'compilation-error-regexp-alist 'go-panic t)
  ))


;; Go- Projectile
(require 'go-projectile)
(go-projectile-tools-add-path)
(setq go-projectile-tools
  '((gocode    . "github.com/mdempsky/gocode")
    (golint    . "golang.org/x/lint/golint")
    (godef     . "github.com/rogpeppe/godef")
    (errcheck  . "github.com/kisielk/errcheck")
    (godoc     . "golang.org/x/tools/cmd/godoc")
    (gogetdoc  . "github.com/zmb3/gogetdoc")
    (goimports . "golang.org/x/tools/cmd/goimports")
    (gorename  . "golang.org/x/tools/cmd/gorename")
    (gomvpkg   . "golang.org/x/tools/cmd/gomvpkg")
    (guru      . "golang.org/x/tools/cmd/guru")))


;; company-go
(require 'company-go)
(add-hook 'go-mode-hook
      (lambda ()
        (set (make-local-variable 'company-backends) '(company-go))
        (company-mode)))


;; Project
(require 'project)
(defun project-find-go-module (dir)
  (when-let ((root (locate-dominating-file dir "go.mod")))
    (cons 'go-module root)))
(cl-defmethod project-root ((project (head go-module)))
  (cdr project))
(add-hook 'project-find-functions #'project-find-go-module)


;;(require 'go-mode)

;; Optional: install eglot-format-buffer as a save hook.
;; The depth of -10 places this before eglot's willSave notification,
;; so that that notification reports the actual contents that will be saved.
;; (require 'eglot)
;; (add-hook 'go-mode-hook 'eglot-ensure)
;; (defun eglot-format-buffer-on-save ()
;;   (add-hook 'before-save-hook #'eglot-format-buffer -10 t))
;; (add-hook 'go-mode-hook #'eglot-format-buffer-on-save)

;; Python
;; (add-hook 'python-mode-hook 'lsp)
;; (add-hook 'python-mode-hook #'lsp-deferred)


(use-package pyvenv
  :demand t
  :config
;  (setq pyvenv-workon "env")  ; Default venv
  (pyvenv-tracking-mode 1))  ; Automatically use pyvenv-workon via dir-locals
  (setq pyvenv-post-activate-hooks
        (list (lambda ()
                (setq python-shell-interpreter (concat pyvenv-virtual-env "bin/python3")))))
  (setq pyvenv-post-deactivate-hooks
        (list (lambda ()
                (setq python-shell-interpreter "python3"))))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   (quote
    ("~/Projects/org/mu_out.org" "~/Projects/aws_course/project.org" "~/Documents/Notas/goweb.org" "~/Projects/org/org_tuto.org")))
 '(package-selected-packages
   (quote
    (importmagic py-isort yapfify dap-mode company-go exec-path-from-shell eglot yasnippet go-mode lsp-pyre lsp-ui pyvenv use-package python-mode py-autopep8 company lsp-mode magit swiper))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
