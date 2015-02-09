
;
; Convenient package handling in emacs
;
(require 'package)

;; use packages from marmalade
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
;; and the old elpa repo
(add-to-list 'package-archives '("elpa-old" . "http://tromey.com/elpa/"))
;; and automatically parsed versiontracking repositories.
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))

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
; set f5 hotkey to invoke make
;
(global-set-key [f5] 'compile)


;
; disable mouse whell scroll accel
;
(setq mouse-wheel-progressive-speed nil)


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



;; Highlight TODO and FIXME in comments 
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
; open a new speedbar frame if there isn't one already
;
(speedbar-frame-mode 1)
(global-set-key  [f8] 'speedbar-get-focus)



; minimap 
;;(add-to-list 'load-path "~/.emacs.d/elpa/minimap-1.2/")
;
(package-require 'minimap)
(minimap-mode 1)
(setq minimap-update-delay 0)
(setq minimap-width-fraction 0.05)
(setq minimap-window-location (quote right))
(setq minimap-minimum-width 25)



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
; autocompletion from debian
;
(package-require 'auto-complete)
    (add-to-list 'ac-dictionary-directories "/usr/share/auto-complete/dict/")
    (require 'auto-complete-config)
    (ac-config-default)



;
; flycheck syntax checker
;
(package-require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)






