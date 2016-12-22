;; enable line numbers
(global-linum-mode t)

(add-to-list 'load-path "~/emacs_init/site-lisp")

;; setup custom modes
(autoload 'skill-mode "skill-mode" "Skill/Ocean Editing Mode" t)
(autoload 'verilog-mode "verilog-mode" "Verilog Editing Mode" t)
(autoload 'spice-mode "spice-mode" "Spice Editing Mode" t)
(autoload 'spectre-mode "spectre-mode" "Spectre Editing MOde" t)
(autoload 'yaml-mode "yaml-mode" "YAML Editing Mode" t)

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
