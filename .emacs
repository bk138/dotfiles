
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

;;;; Make sure a package is installed
;;;; FIXME can be removed once everything is using use-package
(defun package-require (package)
  "Install a PACKAGE unless it is already installed 
or a feature with the same name is already active.

Usage: (package-require 'package)"
  ;; try to activate the package with at least version 0.
  (package-activate package '(0))
  ;; try to just require the package. Maybe the user has it in his local config
  (condition-case nil
      (require package)
    ;; if we cannot require it, it does not exist, yet. So install it.
    (error (package-install package))))


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
;; disable native scroll, annoying on dark theme
(scroll-bar-mode -1)


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
;; no startscreen
;;
(setq inhibit-startup-message t)


;;
;; start maximized, no toolbar
;;
(tool-bar-mode -1)
(setq initial-frame-alist '( (fullscreen . maximized)))
(set-frame-parameter nil 'undecorated t) ; and no wm title bar either

;;
;; use winner mode.
;;
(winner-mode 1)


;;
;; hide menubar per default, make toggable
;;
(global-set-key (kbd "<f12>") 'menu-bar-mode)
(unless (string-equal system-type "darwin")
  (menu-bar-mode -1))

;;
;; set f5 hotkey to invoke make
;;
(global-set-key [f5] 'compile)


;;
;; disable mouse whell scroll accel
;;
(setq mouse-wheel-progressive-speed nil)

;;
;; remap home and end keys on OSX
;;
(if (string-equal system-type "darwin")
    (progn
      (global-set-key (kbd "<home>") 'beginning-of-line)
      (global-set-key (kbd "<end>") 'end-of-line)))

;;
;; disable bell
;;
(setq ring-bell-function 'ignore)


;;
;; paren matching on
;;
(show-paren-mode t)
;; and also surrounding ones ;;-)
(use-package highlight-parentheses
  :hook (prog-mode . highlight-parentheses-mode)
  :config (setq hl-paren-colors '("red1" "turquoise" "magenta" "dodger blue")))

;;
;; set indentation
;;
(setq c-basic-offset 4)
(package-require 'editorconfig)
(editorconfig-mode 1)


;;
;; line numbers
;;
(add-hook 'prog-mode-hook 'linum-mode)


;;
;; delete to trash
;;
(setq delete-by-moving-to-trash t)


;;
;; shwo changes on the fly
;;
(use-package diff-hl
  :init
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))


;;
;; use magit
;;
(use-package magit
  :bind ("C-x g" . magit-status))


;;
;; auto-refresh all buffers when files have changed on disk
;;
(global-auto-revert-mode t)

;;
;; Highlight TODO and FIXME in comments 
;;
(use-package hl-todo
  :init (global-hl-todo-mode))


;;
;; which-key
;;
(use-package which-key
 :init (which-key-mode))

;;
;; even better search in file
;;
(use-package swiper
  :bind ("C-s" . swiper))

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
;; If I reopen a file, I want to start at the line at which I was when I closed it.
;;
(save-place-mode 1)


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
  :defer t
  :init
  (exec-path-from-shell-initialize)
  )


;;
;; autocompletion
;;
(package-require 'company)
(package-require 'company-irony) ;; for C
(global-company-mode 1)
(defun indent-or-complete ()
    (interactive)
    (if (looking-at "\\_>")
        (company-complete-common)
      (indent-according-to-mode)))
(global-set-key "\t" 'indent-or-complete) ;; tab to complete or indent


;;
;; flycheck syntax checker
;;
(package-require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
(package-require 'flycheck-pos-tip)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))


;;
;; make autocompletion and flycheck work much better for CMake-based projects
;;
(package-require 'cpputils-cmake)
(add-hook 'c-mode-common-hook
          (lambda ()
            (if (derived-mode-p 'c-mode 'c++-mode)
                (cppcm-reload-all)
              )))


;;
;; objc-mode tweaks
;;
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
;; TypeScript
;;
(package-require 'tide)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;;;; company is an optional dependency. You have to
  ;;;; install it separately via package-install
  ;;;; `M-x package-install [ret] company`
  (company-mode +1))
;;;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)
;;;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)
(add-hook 'typescript-mode-hook #'setup-tide-mode)


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

