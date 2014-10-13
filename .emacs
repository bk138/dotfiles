
;; no startscreen
(setq inhibit-startup-message t)


;; theme
(load-theme 'tango-dark)


;; set f5 hotkey to invoke make
(global-set-key [f5] 'compile)


;; paren matching on
(show-paren-mode t)


;; tabs
(require 'tabbar)
(tabbar-mode t)


;; open a new speedbar frame if there isn't one already
(speedbar-frame-mode 1)
(global-set-key  [f8] 'speedbar-get-focus)


;; minimap 
(add-to-list 'load-path "~/.emacs.d/elpa/minimap-1.2/")
(require 'minimap)
(minimap-mode 1)
(setq minimap-update-delay 0)
(setq minimap-width-fraction 0.05)
(setq minimap-window-location (quote right))



;; autocompletion from debian
(require 'auto-complete)
    (add-to-list 'ac-dictionary-directories "/usr/share/auto-complete/dict/")
    (require 'auto-complete-config)
    (ac-config-default)
