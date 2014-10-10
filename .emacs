
;; no startscreen
(setq inhibit-startup-message t)


;; set f5 hotkey to invoke make
(global-set-key [f5] 'compile)


;; paren matching on
(show-paren-mode t)


;; tabs
(tabbar-mode 1)


;; speed bar
(speedbar 1)


;; autocompletion from debian
(require 'auto-complete)
    (add-to-list 'ac-dictionary-directories "/usr/share/auto-complete/dict/")
    (require 'auto-complete-config)
    (ac-config-default)
