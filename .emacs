
;;
;; bootstrap use-package as per http://cachestocaches.com/2015/8/getting-started-use-package/
;;
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(if (string-equal system-type "gnu/linux")
    (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")) ; make default https elpa usable again
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

;; make elpa usable again
(use-package gnu-elpa-keyring-update)


;; modern alternative to tabbar, uses Emacs 27 tab-line
(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-headline-match)
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-gray-out-icons 'buffer)
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  :hook
  (dashboard-mode . centaur-tabs-local-mode))

(use-package doom-themes
  :config
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  ;; leaving out treemacs config for now, might be added later...
  )


;;
;; theme accroding to day/night
;;
(use-package circadian
  :config
  (setq calendar-location-name "Berlin")
  (setq calendar-latitude 52.30)
  (setq calendar-longitude 13.25)
  (setq circadian-themes '((:sunrise . doom-acario-light)
			   (:sunset  . doom-zenburn)))
  (add-hook 'circadian-after-load-theme-hook
	    #'(lambda (theme)
		(if (string-equal theme "doom-acario-light")
		    (progn
		      (message "adapting for doom-acario-light")
		      ;; reset to default
		      (setq lsp-diagnostics-attributes '((unnecessary :foreground "dim gray")(deprecated :strike-through t)))
		      ;; have to re-set those, otherwise modeline is too wide and cut off
		      (setq doom-modeline-height 1)
		      (set-face-attribute 'mode-line nil :height 0.95)
		      (set-face-attribute 'mode-line-inactive nil :height 0.95)

		      ))
		(if (string-equal theme "doom-zenburn")
		    (progn
		      (message "adapting for doom-zenburn")
		      (eval-after-load 'magit
			'(progn
			   (set-face-background 'magit-diff-hunk-heading-highlight "#7bb8bb")
			   (set-face-attribute 'magit-header-line nil :background "#4f4f4f" :box nil)))
		      ;; make these more readable
		      (setq lsp-diagnostics-attributes '((unnecessary :foreground "gray80")(deprecated :strike-through t)))
		      (set-face-attribute 'shadow nil :foreground "#7F7F7F")
		      (eval-after-load 'markdown-mode
			'(progn
			   (set-face-attribute 'markdown-markup-face nil :foreground "#ff6655")))
		      ;; have to re-set those, otherwise modeline is too wide and cut off
		      (setq doom-modeline-height 1)
		      (set-face-attribute 'mode-line nil :height 0.95)
		      (set-face-attribute 'mode-line-inactive nil :height 0.95)

		      ))))
  (circadian-setup))


;;
;; dim inactive buffers
;;
(use-package dimmer
  :config
  (dimmer-configure-which-key)
  (dimmer-configure-company-box)
  (dimmer-configure-magit)
  (dimmer-configure-posframe)
  (dimmer-configure-hydra)
  (dimmer-mode t))


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


;; way faster than spaceline and more to my liking than powerline, not as basic as moodline
(use-package doom-modeline
  :config
  ;; show process status of inactive buffers coloured as well
  (doom-modeline-def-segment process
  "The process info, always coloured"
  (if (doom-modeline--active)
      mode-line-process
    mode-line-process))

  (doom-modeline-mode)
  )


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

  ;; windmove keybindings (that do not interfere with selection)
  (global-set-key (kbd "S-M-<left>")  'windmove-left)
  (global-set-key (kbd "S-M-<right>") 'windmove-right)
  (global-set-key (kbd "S-M-<up>")    'windmove-up)
  (global-set-key (kbd "S-M-<down>")  'windmove-down)

  ;; set f5 hotkey to invoke make
  (global-set-key [f5] 'projectile-compile-project)

  ;; encourage emacs to follow the compilation buffer
  (setq compilation-scroll-output t)

  ;; jump to related file
  (global-set-key (kbd "C-c o") 'ff-find-other-file)

  ;; show man page
  (global-set-key (kbd "C-c m") 'manual-entry)

  ;; disable mouse whell scroll accel
  (setq mouse-wheel-progressive-speed nil)

  ;; make scrolling less laggy by applying some optimisations
  (setq fast-but-imprecise-scrolling t)
  (setq inhibit-compacting-font-caches t) ; don't compat font cache on GC

  ;; always use the short y n
  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; remap home and end keys on OSX
  (if (string-equal system-type "darwin")
      (progn
	(global-set-key (kbd "<home>") 'beginning-of-line)
	(global-set-key (kbd "<end>") 'end-of-line)
	(setq mac-right-option-modifier 'none))) ; make alt-gr work

  ;; disable bell
  (setq ring-bell-function 'ignore)

  ;; delete to trash
  (setq delete-by-moving-to-trash t)

  ;; If I reopen a file, I want to start at the line at which I was when I closed it.
  (save-place-mode 1)

  ;; auto-refresh all buffers when files have changed on disk
  (global-auto-revert-mode t)

  ;; Auto-refresh dired on file change
  (add-hook 'dired-mode-hook 'auto-revert-mode)

  ;; paren matching on
  (show-paren-mode t)

  ;; highlight current line
  (global-hl-line-mode t)

  ;; line numbers
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)

  ;; show current function or similar thing in modeline
  (which-function-mode 1)

  ;; highlight trailing whitespace
  (add-hook 'prog-mode-hook (lambda ()(setq show-trailing-whitespace 1)))

  ;; C indent settings
  (setq-default c-basic-offset 4)

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
  :config (setq hl-paren-colors '("red1" "turquoise" "magenta" "dodger blue")))


;; highlight indent levels
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :config (setq highlight-indent-guides-method 'character))

;; background colour names with their colour
(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode)
  :config (add-hook 'c-mode-common-hook 'rainbow-turn-off))

;;
;; set indentation
;;
(use-package editorconfig
  :config (editorconfig-mode 1))


;;
;; show changes on the fly
;;
(use-package diff-hl
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  (advice-add 'vc-refresh-state :after #'diff-hl-update))


;;
;; use magit
;;
(use-package magit
  :bind ("C-x g" . magit-status)
  :after (diff-hl)
  :config
  (setq auto-revert-check-vc-info t)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))


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
  :config (which-key-mode))

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
  :config
  (setq ivy-use-virtual-buffers t) ; kind of a builtin recentf :-)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-wrap t)) ; wrap around

(use-package counsel ; use ivy in more places
  :init (counsel-mode)
  :bind
  ("C-c g" . counsel-git) ; search file in current git project
  ("C-c j" . counsel-git-grep) ; search regexp in current project via git grep
  ("C-c c" . counsel-compile)
  ("C-c k" . counsel-ag) ; search regexp occurence in current project via ag
  ("C-x l" . counsel-locate)
  ("C-c i" . counsel-imenu)) ; list things in file

(use-package smex) ; counsel-M-x will use this for recently-used

(use-package counsel-projectile
  :after projectile
  :config
  (counsel-projectile-mode))


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
  :bind  ("C-x t" . treemacs-select-window); switch over to treemacs
  :init
  (treemacs)
  )

(use-package treemacs-magit
  :after treemacs magit)

(use-package treemacs-projectile
  :after treemacs projectile)

(use-package treemacs-icons-dired
  :after treemacs dired
  :config (treemacs-icons-dired-mode))

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
;; nicer startscreen
;;
(use-package dashboard
  :config
  (dashboard-setup-startup-hook))


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
(use-package restart-emacs
  :defer t)

;;
;; google helper
;;
(use-package google-this
  :config (google-this-mode 1))

;;
;; nicer package menu
;;
(use-package paradox
  :config (paradox-enable))

;;
;; compare files side by side
;;
(use-package vdiff
  :defer t
  :config (setq vdiff-auto-refine t))

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
  :init (global-flycheck-mode)
  :bind ("C-c f" . flycheck-list-errors))


;;
;; LSP
;;
(use-package lsp-mode
  :hook (prog-mode . lsp)
  :config
  (setq lsp-prefer-flymake nil)
  (setq lsp-headerline-breadcrumb-enable nil) ;; we have lsp-treemacs for this
  (setq lsp-file-watch-threshold nil)
  (setq read-process-output-max (* 1024 1024)) ;; 1mb
  (defun after-lsp ()
    (progn
      (when (derived-mode-p 'c-mode) (setq lsp-enable-indentation nil))
      (when (derived-mode-p 'sh-mode) (eldoc-mode -1))))
  (add-hook 'lsp-after-initialize-hook 'after-lsp)
  (add-hook 'lsp-after-apply-edits-hook (lambda (&rest _) (projectile-save-project-buffers)))
  :bind ("C-c r" . lsp-rename))

(use-package posframe) ; for dap-ui-controls
(use-package dap-mode
  :bind ("C-c d" . dap-debug-last)
  :config
  (setq dap-auto-configure-features '(sessions locals breakpoints expressions controls)) ; https://github.com/emacs-lsp/dap-mode/issues/314
  ;; pull in support for gdb
  (require 'dap-gdb-lldb)
  (dap-mode 1)
  ;; show fringe indicators for errors and breakpoints and the like
  (dap-ui-mode 1)
  ;; displays floating panel with debug buttons, requires emacs 26+ and posframe package
  (dap-ui-controls-mode 1)
  ;; automatically trigger the hydra when the program hits a breakpoint
  (add-hook 'dap-stopped-hook (lambda (arg) (call-interactively #'dap-hydra)))
  )

(use-package yasnippet ; if lsp-enable-snippets is still on, company-lsp will always insert extra spaces
  :hook (lsp-mode . yas-minor-mode))
(use-package company-lsp
  :defer t)

(use-package lsp-ui
  :config
  ;; try to show documentation in a webkit widget
  (setq lsp-ui-doc-enable nil) ; do not popup doc without asking, use combo defined below
  (setq lsp-ui-doc-use-webkit t)
  (setq lsp-ui-doc-position (quote top))
  ;; Show the peek view even if there is only 1 cross reference
  (setq lsp-ui-peek-always-show t)
  (setq lsp-ui-peek-fontify (quote always))
  ;; remap xref bindings to use peek
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  ;; custom sideline
  :bind ("M-RET" . lsp-ui-sideline-apply-code-actions)
  :bind ("C-c h" . lsp-ui-doc-glance)
  )

(use-package ccls
  :defer t) ; C Language Server



;;
;; projectile helps setting the right compilation command, and quite some stuff more
;;
(use-package projectile
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))


;;
;; web editing tweaks
;;
(use-package web-mode
  :mode "\\.html?\\'")


;;
;; PHP
;;
(use-package php-mode
  :defer t)


;;
;; JavaScript
;;
(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-mode . js2-imenu-extras-mode)
  :interpreter "node"
  :config (define-key js2-mode-map [remap js-find-symbol] #'lsp-ui-peek-find-definitions))

;;
;; Shell
;;
(use-package sh-script
  :interpreter ("busybox" . shell-script-mode))

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


;;
;; Java
;;
(use-package lsp-java
  :after lsp
  :config (add-hook 'java-mode-hook 'lsp))


;;
;; CMake
;;
(use-package cmake-mode
  :defer t)

;;
;; Rust
;;
(use-package rustic ; use rustic over rust-mode mainly because of the nicer cargo test integration
  :defer t)


