
;;
;; bootstrap use-package as per http://cachestocaches.com/2015/8/getting-started-use-package/
;;
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; configure use-package
(eval-when-compile
  (require 'use-package)
  (setq use-package-compute-statistics t)
  (require 'use-package-ensure)
  (setq use-package-always-ensure t))


;;
;; tabs, https://amitp.blogspot.com/2018/10/emacs-prettier-tabbar.html
;;
(use-package tabbar
  :config
  (customize-set-variable 'tabbar-separator '(1))
  (set-face-attribute 'tabbar-button nil
		      :box nil)
  (tabbar-mode 1))


;;
;; theme accroding to day/night
;;
(use-package circadian
  :config
  (setq calendar-location-name "Berlin") 
  (setq calendar-latitude 52.30)
  (setq calendar-longitude 13.25)
  (setq circadian-themes '((:sunrise . tango)
			   (:sunset  . tango-dark)))
  (add-hook 'circadian-after-load-theme-hook
	    #'(lambda (theme)
		(if (string-equal theme "tango")
		    (progn
		      (message "adapting for tango")
		      (set-face-attribute 'tabbar-default nil
					  :background "gray"
					  :foreground "gray60"
					  :distant-foreground "gray50"
					  :box nil)
		      (set-face-attribute 'tabbar-unselected nil
					  :foreground "black"
					  :box nil)
		      (set-face-attribute 'tabbar-modified nil
					  :foreground "red4"
					  :box nil
					  :inherit 'tabbar-unselected)
		      (set-face-attribute 'tabbar-selected nil
					  :background "#4090c0"
					  :foreground "white"
					  :box nil)
		      (set-face-attribute 'tabbar-selected-modified nil
					  :inherit 'tabbar-selected
					  :foreground "GoldenRod2"
					  :box nil)

		      (set-face-attribute 'mode-line-inactive nil
					  :foreground "gray30"
					  :background "gray"
					  :box nil)
		      (set-face-attribute 'mode-line nil
					  :foreground "gray10"
					  :background "gray90"
					  :box nil)
		      (set-face-attribute 'mode-line-highlight nil
					  :foreground "gray50"
					  :box nil)
		      ))
		(if (string-equal theme "tango-dark")
		    (progn
		      (message "adapting for tango-dark")
		      (set-face-attribute 'tabbar-default nil
					  :background "gray25"
					  :foreground "gray60"
					  :distant-foreground "gray50"
					  :box nil)
		      (set-face-attribute 'tabbar-unselected nil
					  :foreground "gray60"
					  :box nil)
		      (set-face-attribute 'tabbar-modified nil
					  :foreground "OrangeRed1"
					  :box nil
					  :inherit 'tabbar-unselected)
		      (set-face-attribute 'tabbar-selected nil
					  :background "SteelBlue4"
					  :foreground "white"
					  :box nil)
		      (set-face-attribute 'tabbar-selected-modified nil
					  :inherit 'tabbar-selected
					  :foreground "orange"
					  :box nil)
		      
		      (set-face-foreground 'vertical-border "gray30")

		      (set-face-attribute 'mode-line-inactive nil
					  :foreground "gray60"
					  :background "gray30"
					  :box nil)
		      (set-face-attribute 'mode-line nil
					  :foreground "gray10"
					  :background "gray60"
					  :box nil)
		      (set-face-attribute 'mode-line-highlight nil
					  :foreground "gray90"
					  :box nil)
		      ))))
  (circadian-setup))


;;
;; highlight doxygen comments
;;
(use-package highlight-doxygen
  :hook (prog-mode . highlight-doxygen-mode))


;;
;; highlight numbers
;;
(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode))


;;
;; functionality to hide modes in modeline
;;
(use-package diminish)


;;
;; emacs-core-related config
;;
(use-package emacs
  :config

  ;; no startscreen
  (setq inhibit-startup-message t)

  ;; start maximized, no toolbar
  (tool-bar-mode -1)
  (setq initial-frame-alist '( (fullscreen . maximized)))
  (set-frame-parameter nil 'undecorated t) ; and no wm title bar either

  ;; hide menubar per default, make toggable
  (global-set-key (kbd "<f12>") 'menu-bar-mode)
  (unless (string-equal system-type "darwin")
    (menu-bar-mode -1))

  ;; disable native scroll, annoying on dark theme
  (scroll-bar-mode -1)

  ;; c-x 1 after startup
  (add-hook 'window-setup-hook 'delete-other-windows)

  ;; use winner mode.
  (winner-mode 1)
  
  ;; set f5 hotkey to invoke make
  (global-set-key [f5] 'compile)

  ;; jump to related file
  (global-set-key (kbd "C-c o") 'ff-find-other-file)

  ;; disable mouse whell scroll accel
  (setq mouse-wheel-progressive-speed nil)

  ;; always use the short y n
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; remap home and end keys on OSX
  (if (string-equal system-type "darwin")
      (progn
	(global-set-key (kbd "<home>") 'beginning-of-line)
	(global-set-key (kbd "<end>") 'end-of-line)))

  ;; disable bell
  (setq ring-bell-function 'ignore)

  ;; delete to trash
  (setq delete-by-moving-to-trash t)

  ;; If I reopen a file, I want to start at the line at which I was when I closed it.
  (save-place-mode 1)

  ;; auto-refresh all buffers when files have changed on disk
  (global-auto-revert-mode t)

  ;; paren matching on
  (show-paren-mode t)

  ;; line numbers
  (add-hook 'prog-mode-hook 'linum-mode)
  
  ;; C indent settings
  (setq c-basic-offset 4)

  ;; objc-mode tweaks
  (add-to-list 'magic-mode-alist
               `(,(lambda ()
                    (and (string= (file-name-extension buffer-file-name) "m")
                         (re-search-forward "@\\<interface\\>" 
					    magic-mode-regexp-match-limit t)))
                 . objc-mode))
  (add-to-list 'magic-mode-alist
               `(,(lambda ()
                    (and (string= (file-name-extension buffer-file-name) "h")
                         (re-search-forward "@\\<interface\\>" 
					    magic-mode-regexp-match-limit t)))
                 . objc-mode))

  ;; have those custom-set-variables in a separate file
  (setq custom-file "~/.emacs.d/custom.el")
  (load custom-file 'noerror)
  )


;; and also surrounding ones ;;-)
(use-package highlight-parentheses
  :hook (prog-mode . highlight-parentheses-mode)
  :config (setq hl-paren-colors '("red1" "turquoise" "magenta" "dodger blue"))
  :diminish)

;;
;; set indentation
;;
(use-package editorconfig
  :config (editorconfig-mode 1)
  :diminish)


;;
;; show changes on the fly
;;
(use-package diff-hl
  :init
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))


;;
;; use magit
;;
(use-package magit
  :bind ("C-x g" . magit-status)
  :after (diff-hl)
  :config (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))


;;
;; quick git-blame
;;
(use-package git-messenger
  :bind (("C-x v p" . git-messenger:popup-message))
  :config
  (setq git-messenger:show-detail t)
  (setq git-messenger:use-magit-popup t))


;;
;; Highlight TODO and FIXME in comments 
;;
(use-package hl-todo
  :init (global-hl-todo-mode))


;;
;; which-key
;;
(use-package which-key
  :diminish
  :init (which-key-mode))

;;
;; even better search in file
;;
(use-package swiper
  :bind ("C-s" . swiper))

;;
;; better completion of emacs UI and commands. nicer than helm IMO.
;;
(use-package ivy
  :init (ivy-mode)
  :diminish
  :config
  (setq ivy-use-virtual-buffers t) ; kind of a builtin recentf :-)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-wrap t)) ; wrap around

(use-package counsel ; use ivy in more places
  :init (counsel-mode)
  :diminish
  :bind
  ("C-c g" . counsel-git) ; search file in current git project
  ("C-c j" . counsel-git-grep) ; search regexp in current project via git grep
  ("C-c c" . counsel-compile)
  ("C-c k" . counsel-ag) ; search regexp occurence in current project via ag
  ("C-x l" . counsel-locate))


;;
;; use treemacs on the left
;;
(use-package treemacs
  :config
  (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)
  ;; make scrolling activate the treemacs window so the follow modes don't reset the position all the time
  (if (string-equal system-type "gnu/linux") ;; linux
      (progn
	(define-key treemacs-mode-map [mouse-4] (lambda () (interactive) (treemacs-select-window) (scroll-down 5)))
	(define-key treemacs-mode-map [mouse-5] (lambda () (interactive) (treemacs-select-window) (scroll-up 5))))
    (progn
      (define-key treemacs-mode-map [wheel-up] (lambda () (interactive) (treemacs-select-window) (scroll-down 5)))
      (define-key treemacs-mode-map [wheel-down] (lambda () (interactive) (treemacs-select-window) (scroll-up 5)))
      ))
  (treemacs-git-mode 'simple)
  (treemacs-tag-follow-mode t)
  (treemacs-follow-mode t)
  (setq treemacs-is-never-other-window t)
  :init
  (treemacs)
  )

(use-package treemacs-magit
  :after treemacs magit)


;;
;; go to the last change. sweet!
;;
(use-package goto-chg
  :bind ("C-." . goto-last-change))


;;
;; show recent files
;;
(use-package recentf
  :bind ("C-x C-r" . recentf-open-files)
  :init
  (setq recentf-max-menu-items 1000)
  (recentf-mode 1))


;;
;; find external programs on OSX and other platforms
;;
(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-initialize)))

;;
;; restart emacs from whitin emacs
;;
(use-package restart-emacs)

;;
;; autocompletion
;;
(use-package company
  :config
  (global-company-mode 1)
  (defun indent-or-complete ()
    "Complete if point is looking at end-of-symbol or just after '->', otherwise indent line."
    (interactive)
    (if (or (looking-at "\\_>") (looking-back "->" 2) (looking-back "\\." 1))
        (company-complete-common)
      (indent-according-to-mode)))
  :bind
  ("TAB" . indent-or-complete))



;;
;; flycheck syntax checker
;;
(use-package flycheck
  :init (global-flycheck-mode))

(use-package flycheck-inline
  :hook (flycheck-mode . flycheck-inline-mode))

;;
;; LSP
;;
(use-package lsp-mode
  :hook (prog-mode . lsp)
  :config
  (setq lsp-prefer-flymake nil))

(use-package yasnippet) ; if lsp-enable-snippets is still on, company-lsp will always insert extra spaces
(use-package company-lsp)

(use-package lsp-ui
  :config
  ;; try to show documentation in a webkit widget
  (setq lsp-ui-doc-use-webkit t)
  ;; Show the peek view even if there is only 1 cross reference
  (setq lsp-ui-peek-always-show t)
  ;; remap xref bindings to use peek
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  ;; no sideline
  (setq lsp-ui-sideline-enable nil)
  )

;;
;; web editing tweaks
;;
(use-package web-mode
  :mode "\\.php\\'"
  :mode "\\.html?\\'")


;;
;; JavaScript
;;
(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-mode . js2-imenu-extras-mode))



;;
;; markdown
;;
(use-package markdown-mode
  :defer t)


;;
;; YAML
;;
(use-package yaml-mode
  :defer t)

