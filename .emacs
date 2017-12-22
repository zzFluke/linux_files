;; General configurations
;; initialize packages
;; (package-initialize)
;; enable line numbers
(global-linum-mode t)
;; add initialization files to load path
(add-to-list 'load-path "~/emacs_init/site-lisp")
;; use space for indentation
(setq-default indent-tabs-mode nil)
;; when inserting tabs,  insert 4 spaces instead
(setq-default tab-stop-list (number-sequence 4 120 4))
;; existing tabs look like 4 spaces
(setq-default tab-width 4)
;; set default font to DejaVu Sans Mono
(set-default-font "DejaVu Sans Mono-13")
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
;; Spice mode configurations
(defun my-spice-hook ()
  ;; set hot key to uncomment region in spice
  (local-set-key (kbd "C-c C-u") 'uncomment-region)
)
;; C++ mode configurations
;; add custom C++ style
(c-add-style "my-c++-style" 
             '("stroustrup"
               ;; use space for indentation
               (indent-tabs-mode . nil)
               ;; indent by 4 spaces
               (c-basic-offset . 4)
               ;; custom indentation rules
               (c-offsets-alist . ((inline-open . 0)
                                   (brace-list-open . 0)
                                   (statement-case-open . +)))
               )
)
(defun my-c++-mode-hook ()
  (c-set-style "my-c++-style")
  (auto-fill-mode)         
  (c-toggle-auto-hungry-state 1)
)

;; add custom configuration hooks
(add-hook 'spice-mode-hook 'my-spice-hook)
(add-hook 'prog-mode-hook 'my-prog-hook)
(add-hook 'c++-mode-hook 'my-c++-mode-hook)

;; automatic customizations
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark)))
 '(inhibit-startup-screen t)
)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)
