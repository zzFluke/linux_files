;; enable line numbers
(global-linum-mode t)

(add-to-list 'load-path "~/emacs_init/site-lisp")

; use space for indentation
(setq-default indent-tabs-mode nil)
; when inserting tabs,  insert 4 spaces instead
(setq tab-stop-list (number-sequence 4 120 4))
; existing tabs looks like 4 spaces
(setq tab-width 4)

;; setup custom modes
(autoload 'skill-mode "skill-mode" "Skill/Ocean Editing Mode" t)
(autoload 'verilog-mode "verilog-mode" "Verilog Editing Mode" t)
(autoload 'spice-mode "spice-mode" "Spice Editing Mode" t)
(autoload 'spectre-mode "spectre-mode" "Spectre Editing MOde" t)
(autoload 'yaml-mode "yaml-mode" "YAML Editing Mode" t)
(autoload 'cython-mode "cython-mode" "Cython Editing Mode" t)
(autoload 'cmake-mode "cmake-mode" "CMake Editing Mode" t)

(setq auto-mode-alist (append '(("\\.\\(ssp\\|sp\\|hsp\\|spi\\)$" .
                                 spice-mode)) auto-mode-alist))
(setq auto-mode-alist (append '(("\\.\\(il\\|ocn\\|\\cdf\\)$" .
                                 skill-mode)) auto-mode-alist)) 
(setq auto-mode-alist (append '(("\\.\\(scs\\)$" .
                                 spectre-mode)) auto-mode-alist)) 
(setq auto-mode-alist (append '(("\\.\\(v\\|sv\\|vams\\|va\\)$" .
                                 verilog-mode)) auto-mode-alist)) 
(setq auto-mode-alist (append '(("\\.\\(yaml\\|yml\\)$" .
                                 yaml-mode)) auto-mode-alist)) 
(setq auto-mode-alist (append '(("\\.\\(pyx\\|pxd\\)$" .
                                 cython-mode)) auto-mode-alist)) 
(setq auto-mode-alist (append '(("CMakeLists\\.txt$" .
                                 cmake-mode)) auto-mode-alist)) 

;; set hot key to uncomment region in spice
(defun my-spice-mode-keys ()
  (local-set-key (kbd "C-c C-u") 'uncomment-region)
)
(add-hook 'spice-mode-hook 'my-spice-mode-keys)

;; Any files in verilog mode should have their keywords colorized
(add-hook 'verilog-mode-hook '(lambda () (font-lock-mode 1)))

;; bind enter key to newline-and-indent for programming
(add-hook 'prog-mode-hook
	  '(lambda () (define-key prog-mode-map "\C-m" 'newline-and-indent)))

;; set c++ indentation to 4 spaces
(c-add-style "my-style" 
	     '("stroustrup"
	       (indent-tabs-mode . nil)        ; use spaces rather than tabs
	       (c-basic-offset . 4)            ; indent by four spaces
	       (c-offsets-alist . ((inline-open . 0)  ; custom indentation rules
				   (brace-list-open . 0)
				   (statement-case-open . +)))))

(defun my-c++-mode-hook ()
  (c-set-style "my-style")        ; use my-style defined above
  (auto-fill-mode)         
  (c-toggle-auto-hungry-state 1))

(add-hook 'c++-mode-hook 'my-c++-mode-hook)


;; set default font to DejaVu Sans Mono
(set-default-font "-unknown-DejaVu Sans Mono-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")

(setq x-select-enable-clipboard t)

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
