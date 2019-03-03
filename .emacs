
;
; Convenient package handling in emacs
;
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

;; Make sure a package is installed
(defun package-require (package)
  "Install a PACKAGE unless it is already installed 
or a feature with the same name is already active.

Usage: (package-require 'package)"
  ; try to activate the package with at least version 0.
  (package-activate package '(0))
  ; try to just require the package. Maybe the user has it in his local config
  (condition-case nil
      (require package)
    ; if we cannot require it, it does not exist, yet. So install it.
    (error (package-install package))))

;; Initialize installed packages
(package-initialize)  
;; package init not needed, since it is done anyway in emacs 24 after reading the init
;; but we have to load the list of available packages
(when (not package-archive-contents)
    (package-refresh-contents))


;
; theme accroding to day/night
;
(setq calendar-location-name "Berlin") 
(setq calendar-latitude 52.30)
(setq calendar-longitude 13.25)
(package-require 'circadian)
(setq circadian-themes '((:sunrise . tango)
			 (:sunset  . tango-dark)))
(add-hook 'circadian-after-load-theme-hook
          #'(lambda (theme)
	      (if (circadian-a-earlier-b-p (circadian-now-time) (circadian-sunset))
		  (progn
		    (message "setting day theme")
		    )
		(progn
		  (message "setting night theme")
		  ))))
(circadian-setup)
; disable native scroll, annoying on dark theme
(scroll-bar-mode -1)


;
; highlight doxygen comments
;
(package-require 'highlight-doxygen)
(highlight-doxygen-global-mode 1)


;
; highlight numbers
;
(package-require 'highlight-numbers)
(add-hook 'prog-mode-hook 'highlight-numbers-mode)


;
; no startscreen
;
(setq inhibit-startup-message t)


;
; start maximized, no toolbar
;
(tool-bar-mode -1)
(setq initial-frame-alist '( (fullscreen . maximized)))



;
; hide menubar per default, make toggable
;
(global-set-key (kbd "<f12>") 'menu-bar-mode)
(unless (string-equal system-type "darwin")
  (menu-bar-mode -1))

;
; set f5 hotkey to invoke make
;
(global-set-key [f5] 'compile)


;
; disable mouse whell scroll accel
;
(setq mouse-wheel-progressive-speed nil)


;
; disable bell-on-scroll-end
;
(defun my-bell-function ()
  (unless (memq this-command
        '(isearch-abort abort-recursive-edit exit-minibuffer
              keyboard-quit mwheel-scroll down up next-line previous-line
              backward-char forward-char))
    (ding)))
(setq ring-bell-function 'my-bell-function)


;
; paren matching on
;
(show-paren-mode t)
; and also surrounding ones ;-)
(package-require 'highlight-parentheses)
(setq hl-paren-colors '("red1" "turquoise" "magenta" "dodger blue"))
(add-hook 'prog-mode-hook 'highlight-parentheses-mode)

;
; set indentation
;
(setq c-basic-offset 4)
(package-require 'editorconfig)
(editorconfig-mode 1)


;
; line numbers
;
(add-hook 'prog-mode-hook 'linum-mode)


;
; delete to trash
;
(setq delete-by-moving-to-trash t)


;
; shwo changes on the fly
;
(package-require 'diff-hl)
(global-diff-hl-mode 1)
(diff-hl-flydiff-mode 1)


;
; use magit
;
(package-require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)


;
; auto-refresh all buffers when files have changed on disk
;
(global-auto-revert-mode t)

;
; Highlight TODO and FIXME in comments 
;
(package-require 'hl-todo)
(global-hl-todo-mode)

;
; tabs, https://amitp.blogspot.com/2018/10/emacs-prettier-tabbar.html
;
(package-require 'tabbar)
(customize-set-variable 'tabbar-separator '(1))
(set-face-attribute 'tabbar-default nil
                    :background "gray"
                    :foreground "gray60"
                    :distant-foreground "gray50"
                    :box nil)
(set-face-attribute 'tabbar-unselected nil
        :foreground "black" :box nil)
(set-face-attribute 'tabbar-modified nil
        :foreground "red4" :box nil
        :inherit 'tabbar-unselected)
(set-face-attribute 'tabbar-selected nil
        :background "#4090c0" :foreground "white" :box nil)
(set-face-attribute 'tabbar-selected-modified nil
        :inherit 'tabbar-selected :foreground "GoldenRod2" :box nil)
(set-face-attribute 'tabbar-button nil
        :box nil)
(tabbar-mode t)


;
; which-key
;
(package-require 'which-key)
(which-key-mode)

;
; use treemacs on the left
;
(package-require 'treemacs)
(package-require 'treemacs-magit)
(define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)
; make scrolling activate the treemacs window so the follow modes don't reset the position all the time
(if (string-equal system-type "gnu/linux") ; linux
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
(treemacs)


;
; go to the last change. sweet!
;
(package-require 'goto-chg)
(global-set-key [(control .)] 'goto-last-change)


;
; If I reopen a file, I want to start at the line at which I was when I closed it.
;
(save-place-mode 1)


;
; show recent files
;
(package-require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 1000)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)


;
; autocompletion
;
(package-require 'company)
(package-require 'company-irony) ; for C
(global-company-mode 1)
(defun indent-or-complete ()
    (interactive)
    (if (looking-at "\\_>")
        (company-complete-common)
      (indent-according-to-mode)))
(global-set-key "\t" 'indent-or-complete) ; tab to complete or indent


;
; flycheck syntax checker
;
(package-require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
(package-require 'flycheck-pos-tip)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))


;
; make autocompletion and flycheck work much better for CMake-based projects
;
(package-require 'cpputils-cmake)
(add-hook 'c-mode-common-hook
          (lambda ()
            (if (derived-mode-p 'c-mode 'c++-mode)
                (cppcm-reload-all)
              )))


;
; objc-mode tweaks
;
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

;
; web editing tweaks
;
(package-require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))


;
; JavaScript
;
(package-require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;; Better imenu
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode)


;
; TypeScript
;
(package-require 'tide)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))
;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)
;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)
(add-hook 'typescript-mode-hook #'setup-tide-mode)


;
; markdown
;
(package-require 'markdown-mode)


;
; YAML
;
(package-require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
