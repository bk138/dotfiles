
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
(use-package gnu-elpa-keyring-update
    :defer 1)


;; modern alternative to tabbar, uses Emacs 27 tab-line
(use-package centaur-tabs
  :demand
  :config
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-plain-icons t)
  (setq centaur-tabs-gray-out-icons 'buffer)
  (centaur-tabs-group-by-projectile-project)
  (centaur-tabs-mode t)
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward)
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  (git-commit-mode . centaur-tabs-local-mode))

;; make sure lsp-treemacs is loaded before doom-themes,
;; kinda ugly workaround for https://github.com/emacs-lsp/lsp-treemacs/issues/89
(use-package lsp-treemacs
  :init
  (setq lsp-keymap-prefix "C-c l"))

(use-package doom-themes
  :config
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config)
  ;; treemacs theming
  (setq doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)
  )

(use-package all-the-icons)

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
		;; fixes grey icon background when switching from light to dark theme
		(centaur-tabs-init-tabsets-store)
		(if (string-equal theme "doom-acario-light")
		    (progn
		      (message "adapting for doom-acario-light")
		      ;; reset to default
		      (setq lsp-diagnostics-attributes '((unnecessary :foreground "dim gray")(deprecated :strike-through t)))
                      ;; brighter header line
                      (set-face-background 'header-line "gray80")
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
		      ))
                ;; make selected centaur tab have same background as header line
                (set-face-background 'centaur-tabs-selected (face-attribute 'header-line :background nil 'default))
                (set-face-background 'centaur-tabs-selected-modified (face-attribute 'header-line :background nil 'default))
                ))
  (circadian-setup))



;;
;; highlight doxygen comments
;;
(use-package highlight-doxygen
  :hook (prog-mode . highlight-doxygen-mode))


;;
;; fast syntax highlight via tree-sitter
;;
(use-package tree-sitter-langs)
(use-package tree-sitter
  :after (tree-sitter-langs)
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))


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
  (global-set-key (kbd "C-h M") 'manual-entry)

  ;; finally an OK scroll
  (pixel-scroll-precision-mode 1)

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
  (setq show-paren-context-when-offscreen 'overlay)

  ;; highlight current line
  (global-hl-line-mode t)

  ;; line numbers
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)

  ;; show columns and lines in modeline
  (setq column-number-mode t)

  ;; more undo
  (setq undo-limit 16000000)

  ;; show current function or similar thing in modeline
  (which-function-mode 1)

  ;; highlight trailing whitespace
  (add-hook 'prog-mode-hook (lambda ()(setq show-trailing-whitespace 1)))

  ;; use spaces instead of tabs for indent
  (setq-default indent-tabs-mode nil)

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

  ;; don't pop up warnings buffer on background native compilation
  (setq native-comp-async-report-warnings-errors 'silent)
  )


;; and also surrounding ones ;;-)
(use-package highlight-parentheses
  :hook (prog-mode . highlight-parentheses-mode)
  :config (setq hl-paren-colors '("red1" "turquoise" "magenta" "dodger blue")))



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
  :defer 1
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
  :defer 1
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
  :config (counsel-mode)
  :bind
  ("C-c g" . counsel-git) ; search file in current git project
  ("C-c j" . counsel-git-grep) ; search regexp in current project via git grep
  ("C-c c" . counsel-compile)
  ("C-c k" . counsel-ag) ; search regexp occurence in current project via ag
  ("C-x l" . counsel-locate)
  ("C-c i" . counsel-imenu)) ; list things in file

(use-package company-emoji  ; we just use its symbol list for ivy-emoji
    :defer 1)
(use-package ivy-emoji ; nice 🌴 insert
  :bind ("C-c e" . ivy-emoji)
  :after (company-emoji)
  :config
  ;; https://github.com/Sbozzolo/ivy-emoji#installation to use company-emoji's list
  (require 'company-emoji-list)
  (setq ivy-emoji-list
	(mapcar '(lambda (emoji)
                   (concat
                    (get-text-property 0 :unicode emoji) " "
                    (substring-no-properties emoji)))     ;; Print the name
		(company-emoji-list-create)))
  (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji") nil 'prepend)
)

(use-package smex) ; counsel-M-x will use this for recently-used

(use-package marginalia ; show item doc in minibuffer
  :init (marginalia-mode))

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
  (setq treemacs-select-when-already-in-treemacs 'stay) ; don't jump back to recently used file when scrolling
  (treemacs-git-mode 'simple)
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
;; move line or selection up an down. also sweet!
;;
(use-package move-text
  :config (move-text-default-bindings))

;;
;; mark things at point with increasing region
;;
(use-package expand-region
  :bind ("C-+" . er/expand-region))


;;
;; show recent files
;;
(use-package recentf
  :bind ("C-x C-r" . recentf-open-files)
  :init
  (setq recentf-max-saved-items 50)
  (setq recentf-max-menu-items 50)
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
  :if (memq window-system '(mac ns))
  :config
  (exec-path-from-shell-initialize))


;;
;; a terminal that doesn't suck
;;
(use-package vterm
  :defer t)

;;
;; restart emacs from whitin emacs
;;
(use-package restart-emacs
  :defer t)

;;
;; google helper
;;
(use-package google-this
  :defer 1
  :config (google-this-mode 1))

;;
;; nicer package menu
;;
(use-package paradox
  :defer 1
  :config (paradox-enable))
(use-package async) ; for upgrades in the background

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
  (setq company-tooltip-limit 20)
  :bind
  ("TAB" . indent-or-complete))

;; nicer company frontend, also more compact in terms of screen real estate
(use-package company-posframe
  :hook (company-mode . company-posframe-mode))


;;
;; flycheck syntax checker
;;
(use-package flycheck
  :defer 1
  ;; have a shortcut for this
  :bind ("C-," . flycheck-next-error)
  :config
  (global-flycheck-mode)
  ;; change key prefix
  (define-key flycheck-mode-map flycheck-keymap-prefix nil)
  (setq flycheck-keymap-prefix (kbd "C-c f"))
  (define-key flycheck-mode-map flycheck-keymap-prefix
    flycheck-command-map)
  ;; cycle through errors https://emacs.stackexchange.com/a/27511/14002
  (defun flycheck-next-error-loop-advice (orig-fun &optional n reset)
					; (message "flycheck-next-error called with args %S %S" n reset)
    (condition-case err
	(apply orig-fun (list n reset))
      ((user-error)
       (let ((error-count (length flycheck-current-errors)))
	 (if (and
              (> error-count 0)                   ; There are errors so we can cycle.
              (equal (error-message-string err) "No more Flycheck errors"))
             ;; We need to cycle.
             (let* ((req-n (if (numberp n) n 1)) ; Requested displacement.
					; An universal argument is taken as reset, so shouldn't fail.
                    (curr-pos (if (> req-n 0) (- error-count 1) 0)) ; 0-indexed.
                    (next-pos (mod (+ curr-pos req-n) error-count))) ; next-pos must be 1-indexed
					; (message "error-count %S; req-n %S; curr-pos %S; next-pos %S" error-count req-n curr-pos next-pos)
					; orig-fun is flycheck-next-error (but without advise)
					; Argument to flycheck-next-error must be 1-based.
               (apply orig-fun (list (+ 1 next-pos) 'reset)))
           (signal (car err) (cdr err)))))))
  (advice-add 'flycheck-next-error :around #'flycheck-next-error-loop-advice))


;;
;; LSP
;;
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  (defun dotfiles--lsp-if-supported ()
    "Run `lsp' if it's a supported mode."
    (unless (derived-mode-p 'emacs-lisp-mode)
      (lsp)))
  (add-hook 'prog-mode-hook #'dotfiles--lsp-if-supported)
  :hook (lsp-mode . lsp-enable-which-key-integration)
  :config
  (setq lsp-prefer-flymake nil)
  (setq lsp-file-watch-threshold nil)
  (setq read-process-output-max (* 1024 1024)) ;; 1mb
  (setq gc-cons-threshold 100000000)
  (setq lsp-signature-function 'lsp-signature-posframe)
  (setq lsp-rust-analyzer-proc-macro-enable t)
  (setq lsp-rust-analyzer-diagnostics-disabled ["unresolved-macro-call"]) ;; still false warnings, so disable for the time being
  (setq lsp-treemacs-error-list-current-project-only t)
  (defun after-lsp ()
    (progn
      (when (derived-mode-p 'c-mode) (setq lsp-enable-indentation nil))
      (when (derived-mode-p 'sh-mode) (eldoc-mode -1))))
  (add-hook 'lsp-after-initialize-hook 'after-lsp)
  (add-hook 'lsp-after-apply-edits-hook (lambda (&rest _) (save-buffer)))
  )

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

(use-package lsp-ui
  :config
  ;; Show the peek view even if there is only 1 cross reference
  (setq lsp-ui-peek-always-show t)
  (setq lsp-ui-peek-fontify (quote always))
  ;; sideline config
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-show-hover t)
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-diagnostic-max-line-length 80) ; we have treemacs taking up space
  (setq lsp-ui-sideline-ignore-duplicate t)
  ;; doc popup config
  (setq lsp-ui-doc-show-with-cursor nil)
  (setq lsp-ui-doc-show-with-mouse nil)
  ;; remap xref bindings to use peek
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
  ;; custom sideline
  :bind ("M-RET" . lsp-execute-code-action)
  :bind ("C-c h" . lsp-ui-doc-show)
  )


;; C Language Server
(use-package ccls
  :defer t
  :config (setq lsp-lens-enable nil) ; takes ages with large header files
  )



;;
;; projectile helps setting the right compilation command, and quite some stuff more
;;
(use-package projectile
  :defer 1
  :config
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))


;;
;; web editing tweaks
;;
(use-package web-mode
  :mode "\\.html?\\'"
  :init
  (defun indent-region-in-web-mode (start end)
    "Indent the selected region using web-mode.

     This function indents the specified region according to the
     indentation rules of the web-mode major mode. It calculates the
     indentation of the first line in the region and uses it as the
     baseline for the entire region, preserving the existing
     indentation style."
    (interactive "r")
    (let* ((buffer (generate-new-buffer "*temp-indent-buffer*"))
           (first-line-indent (save-excursion
                                (goto-char start)
                                (beginning-of-line)
                                (current-indentation))))
      (unwind-protect
          (progn
            (copy-to-buffer buffer start end)
            (with-current-buffer buffer
              (web-mode)
              (goto-char (point-min))
              (indent-region (point-min) (point-max) nil)
              (while (re-search-forward "^" nil t)
                (replace-match (make-string first-line-indent ?\s) nil nil)))
            (delete-region start end)
            (insert-buffer-substring buffer))
        (kill-buffer buffer))))
  (global-set-key (kbd "C-c I") 'indent-region-in-web-mode)
  :config
  (setq web-mode-enable-auto-indentation nil)
  )


;;
;; PHP
;;
(use-package php-mode
  :mode "\\.php\\'"
  :defer t
  :config
  ; already taken by goto-last-chg
  (unbind-key "C-." php-mode-map))


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
  :defer t
  ;; and nicer compile mode with colours
  :bind (:map rustic-mode-map
	      ("<f5>" . rustic-compile))
  )

;;
;; NSIS
;;
(use-package nsis-mode)


;;
;; Dockerfile
;;
(use-package dockerfile-mode)
