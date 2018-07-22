;; Package setup
;; enable MELPA repository
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;; (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; req-package setup
(require 'req-package)

;; General configurations
;; enable line numbers
(global-linum-mode t)
;; enable automatic file refresh
(global-auto-revert-mode t)
;; add initialization files to load path
(add-to-list 'load-path "~/emacs_init/site-lisp")
;; use space for indentation
(setq-default indent-tabs-mode nil)
;; when inserting tabs,  insert 4 spaces instead
(setq-default tab-stop-list (number-sequence 4 120 4))
;; existing tabs look like 4 spaces
(setq-default tab-width 4)
;; set default font to DejaVu Sans Mono
(set-default-font "DejaVu Sans Mono-10")
;; try to fix emacs cut-and-paste
(setq-default x-select-enable-clipboard t)

;; setup custom modes
(autoload 'skill-mode "skill-mode" "Skill/Ocean Editing Mode" t)
(autoload 'verilog-mode "verilog-mode" "Verilog Editing Mode" t)
(autoload 'spice-mode "spice-mode" "Spice Editing Mode" t)
(autoload 'spectre-mode "spectre-mode" "Spectre Editing MOde" t)
(autoload 'yaml-mode "yaml-mode" "YAML Editing Mode" t)
(autoload 'cython-mode "cython-mode" "Cython Editing Mode" t)
(autoload 'cmake-mode "cmake-mode" "CMake Editing Mode" t)
(autoload 'markdown-mode "markdown-mode" "Markdown Editing Mode" t)
(autoload 'gfm-mode "markdown-mode" "Github Markdown Editing Mode" t)

;; associate files with various mods
(add-to-list 'auto-mode-alist '("\\.\\(ssp\\|sp\\|hsp\\|spi\\)\\'" . spice-mode))
(add-to-list 'auto-mode-alist '("\\.\\(il\\|ocn\\|cdf\\)\\'" . skill-mode))
;; match any file that starts with .cdsinit 
(add-to-list 'auto-mode-alist '("\\(/\\|\\`\\)\\.cdsinit" . skill-mode))
(add-to-list 'auto-mode-alist '("\\.scs\\'" . spectre-mode))
(add-to-list 'auto-mode-alist '("\\.\\(v\\|sv\\|vams\\|va\\)\\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\\.\\(yaml\\|yml\\)\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.\\(pyx\\|pxd\\)\\'" . cython-mode))
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))


;; set custom configurations for various modes
;; General programming mode configurations
(defun my-prog-hook ()
  ;; use space for indentation
  (setq indent-tabs-mode nil)
  ;; when inserting tabs, insert 4 spaces instead
  (setq tab-stop-list (number-sequence 4 120 4))
  ;; exiting tabs look like 4 spaces
  (setq tab-width 4)
)
;; Verilog mode configurations
(defun my-verilog-hook ()
  ;; use space for indentation
  (setq indent-tabs-mode nil)
  ;; when inserting tabs, insert 4 spaces instead
  (setq tab-stop-list (number-sequence 4 120 4))
  (setq verilog-case-indent 2)
  (setq verilog-cexp-indent 2)
  (setq verilog-indent-level 4)
  (setq verilog-indent-level-behavioral 4)
  (setq verilog-indent-level-declaration 4)
  (setq verilog-indent-level-module 4)
  ;; exiting tabs look like 4 spaces
  (setq tab-width 4)
)
;; Spice mode configurations
(defun my-spice-hook ()
  ;; set hot key to uncomment region in spice
  (local-set-key (kbd "C-c C-u") 'uncomment-region)
)
;; C++ mode configurations
;; add custom C++ style
;; (c-add-style "my-c++-style" 
;;              '("stroustrup"
;;                ;; use space for indentation
;;                (indent-tabs-mode . nil)
;;                ;; indent by 4 spaces
;;                (c-basic-offset . 4)
;;                ;; custom indentation rules
;;                (c-offsets-alist . ((inline-open . 0)
;;                                    (brace-list-open . 0)
;;                                   (statement-case-open . +)))
;;                )
;; )
;; (defun my-c++-mode-hook ()
;;   (c-set-style "my-c++-style")
;;   (auto-fill-mode)         
;;   (c-toggle-auto-hungry-state 1)
;; )

;; add custom configuration hooks
(add-hook 'spice-mode-hook 'my-spice-hook)
(add-hook 'prog-mode-hook 'my-prog-hook)
(add-hook 'verilog-mode-hook 'my-verilog-hook)
;; (add-hook 'c++-mode-hook 'my-c++-mode-hook)

;; C++ development setup
;; see http://martinsosic.com/development/emacs/2017/12/09/emacs-cpp-ide.html
(req-package rtags
  :config
  (progn
    (error "Does this even run?")
    (unless (rtags-executable-find "rc") (error "Binary rc is not installed!"))
    (unless (rtags-executable-find "rdm") (error "Binary rdm is not installed!"))

    (define-key c-mode-base-map (kbd "M-.") 'rtags-find-symbol-at-point)
    (define-key c-mode-base-map (kbd "M-,") 'rtags-find-references-at-point)
    (define-key c-mode-base-map (kbd "M-?") 'rtags-display-summary)
    (rtags-enable-standard-keybindings)

    (setq rtags-use-helm t)

    ;; Shutdown rdm when leaving emacs.
    (add-hook 'kill-emacs-hook 'rtags-quit-rdm)
    ))

;; TODO: Has no coloring! How can I get coloring?
(req-package helm-rtags
  :require helm rtags
  :config
  (progn
    (setq rtags-display-result-backend 'helm)
    ))

;; Use rtags for auto-completion.
(req-package company-rtags
  :require company rtags
  :config
  (progn
    (setq rtags-autostart-diagnostics t)
    (rtags-diagnostics)
    (setq rtags-completions-enabled t)
    (push 'company-rtags company-backends)
    ))

;; Live code checking.
(req-package flycheck-rtags
  :require flycheck rtags
  :config
  (progn
    ;; ensure that we use only rtags checking
    ;; https://github.com/Andersbakken/rtags#optional-1
    (defun setup-flycheck-rtags ()
      (flycheck-select-checker 'rtags)
      (setq-local flycheck-highlighting-mode nil) ;; RTags creates more accurate overlays.
      (setq-local flycheck-check-syntax-automatically nil)
      (rtags-set-periodic-reparse-timeout 2.0)  ;; Run flycheck 2 seconds after being idle.
      )
    (add-hook 'c-mode-hook #'setup-flycheck-rtags)
    (add-hook 'c++-mode-hook #'setup-flycheck-rtags)
    ))
(req-package projectile
  :config
  (progn
    (projectile-global-mode)
    ))

;; Helm makes searching for anything nicer.
;; It works on top of many other commands / packages and gives them nice, flexible UI.
(req-package helm
  :config
  (progn
    (require 'helm-config)

    ;; Use C-c h instead of default C-x c, it makes more sense.
    (global-set-key (kbd "C-c h") 'helm-command-prefix)
    (global-unset-key (kbd "C-x c"))

    (setq
     ;; move to end or beginning of source when reaching top or bottom of source.
     helm-move-to-line-cycle-in-source t
     ;; search for library in `require' and `declare-function' sexp.
     helm-ff-search-library-in-sexp t
     ;; scroll 8 lines other window using M-<next>/M-<prior>
     helm-scroll-amount 8
     helm-ff-file-name-history-use-recentf t
     helm-echo-input-in-header-line t)

    (global-set-key (kbd "M-x") 'helm-M-x)
    (setq helm-M-x-fuzzy-match t) ;; optional fuzzy matching for helm-M-x

    (global-set-key (kbd "C-x C-f") 'helm-find-files)

    (global-set-key (kbd "M-y") 'helm-show-kill-ring)

    (global-set-key (kbd "C-x b") 'helm-mini)
    (setq helm-buffers-fuzzy-matching t
          helm-recentf-fuzzy-match t)

    ;; TOOD: helm-semantic has not syntax coloring! How can I fix that?
    (setq helm-semantic-fuzzy-match t
          helm-imenu-fuzzy-match t)

    ;; Lists all occurences of a pattern in buffer.
    (global-set-key (kbd "C-c h o") 'helm-occur)

    (global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)

    ;; open helm buffer inside current window, not occupy whole other window
    (setq helm-split-window-in-side-p t)
    (setq helm-autoresize-max-height 50)
    (setq helm-autoresize-min-height 30)
    (helm-autoresize-mode 1)

    (helm-mode 1)
    ))

;; Use Helm in Projectile.
(req-package helm-projectile
  :require helm projectile
  :config
  (progn
    (setq projectile-completion-system 'helm)
    (helm-projectile-on)
    ))

;; automatic customizations
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark)))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (helm-projectile flycheck-rtags company-rtags helm-rtags projectile rtags flycheck company req-package helm markdown-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
