
;
; Convenient package handling in emacs
;
(require 'package)

;; use packages from marmalade
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
;; and the old elpa repo
(add-to-list 'package-archives '("elpa-old" . "http://tromey.com/elpa/"))
;; and automatically parsed versiontracking repositories.
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
(package-require 'theme-changer)
(change-theme 'tango 'tango-dark)



;
; no startscreen
;
(setq inhibit-startup-message t)


;
; start maximized
;
(custom-set-variables
 '(initial-frame-alist (quote ((fullscreen . maximized)))))


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


;
; set indentation
;
(setq c-basic-offset 4)


;
; line numbers
;
(global-linum-mode t)


;
; shwo changes on the fly
;
(package-require 'diff-hl)
(global-diff-hl-mode 1)
(diff-hl-flydiff-mode 1)


;
; Highlight TODO and FIXME in comments 
;
(package-require 'fic-ext-mode)
(defun add-something-to-mode-hooks (mode-list something)
  "helper function to add a callback to multiple hooks"
  (dolist (mode mode-list)
    (add-hook (intern (concat (symbol-name mode) "-mode-hook")) something)))

(add-something-to-mode-hooks '(c c++ tcl emacs-lisp python text markdown latex) 'fic-ext-mode)


;
; tabs
;
(package-require 'tabbar)
(tabbar-mode t)


;
; use same frame speedbar on the left
;
(package-require 'sr-speedbar)
(setq speedbar-show-unknown-files t) ; show all files
(setq speedbar-use-images nil) ; use text for buttons
(setq sr-speedbar-right-side nil) ; put on left side
(add-hook 'speedbar-mode-hook (lambda () (linum-mode -1))) ; no line numbers
(setq speedbar-directory-unshown-regexp "^$") ; show hidden files as well
(setq sr-speedbar-width 15)
(sr-speedbar-open)
;; avoid accidently deleting window
(defadvice delete-other-windows (after my-sr-speedbar-delete-other-window-advice activate)
  "Check whether we are in speedbar, if it is, jump to next window."
  (let ()
    (when (and (sr-speedbar-window-exist-p sr-speedbar-window)
               (eq sr-speedbar-window (selected-window)))
      (other-window 1)
    )))
(ad-enable-advice 'delete-other-windows 'after 'my-sr-speedbar-delete-other-window-advice)
(ad-activate 'delete-other-windows)


;
; go to the last change. sweet!
;
(package-require 'goto-chg)
(global-set-key [(control .)] 'goto-last-change)


;
; If I reopen a file, I want to start at the line at which I was when I closed it.
;
(package-require 'saveplace)
(setq-default save-place t)



;
; show recent files
;
(package-require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 1000)


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
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))


;
; markdown
;
(package-require 'markdown-mode)


;
; YAML
;
(package-require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
