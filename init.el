;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.
;; Goのパスを通す
(add-to-list 'exec-path (expand-file-name "/usr/bin/go"))
;; go get で入れたツールのパスを通す
(add-to-list 'exec-path (expand-file-name "/home/hm/go/bin/"))
;;; Code:
(global-display-line-numbers-mode t)
(setq display-line-numbers "%4d \u2502 ")

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/init.el
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ここにいっぱい設定を書く

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

(leaf use-package :ensure t :require t)

(leaf vscode-dark-plus-theme
  :ensure t
  :require t
  :config
  (load-theme 'vscode-dark-plus t))

(leaf golang
  :config
  (leaf go-mode
    :ensure t
    :leaf-defer t
    :commands (gofmt-before-save)
    :init
    (add-hook 'before-save-hook 'gofmt-before-save)
    (setq tab-width 4)))

(leaf git-gutter
  :init
  (let ((custom--inhibit-theme-enable nil))
    (unless (memq 'use-package custom-known-themes)
      (deftheme use-package)
      (enable-theme 'use-package)
      (setq custom-enabled-themes (remq 'use-package custom-enabled-themes)))
    (custom-theme-set-variables 'use-package
				'(git-gutter:modified-sign "~" nil nil "Customized with use-package git-gutter")
				'(git-gutter:added-sign "+" nil nil "Customized with use-package git-gutter")
				'(git-gutter:deleted-sign "-" nil nil "Customized with use-package git-gutter")))
  (apply #'face-spec-set
	 (backquote
	  (git-gutter:modified
	   ((t
	     (:background "#f1fa8c"))))))
  (apply #'face-spec-set
	 (backquote
	  (git-gutter:added
	   ((t
	     (:background "#50fa7b"))))))
  (apply #'face-spec-set
	 (backquote
	  (git-gutter:deleted
	   ((t
	     (:background "#ff79c6"))))))
  :require t
  :config
  (global-git-gutter-mode 1))

(leaf lsp-mode
  :ensure t
  :require t
  :commands lsp
  :hook
  (go-mode-hook . lsp)
  :config
  (leaf lsp-ui
    :ensure t
    :require t
    :hook
    (lsp-mode-hook . lsp-ui-mode)
    )
  )

  
(leaf company
  :doc "Modular text completion framework"
  :req "emacs-25.1"
  :tag "matching" "convenience" "abbrev" "emacs>=25.1"
  :url "http://company-mode.github.io/"
  :added "2022-11-26"
  :emacs>= 25.1
  :ensure t
  :config
  (global-company-mode)
  (setq lsp-completion-provider :capf)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (setq company-selection-wrap-around t))

(leaf company-box
  :doc "Company front-end with icons"
  :req "emacs-26.0.91" "dash-2.19.0" "company-0.9.6" "frame-local-0.0.1"
  :tag "convenience" "front-end" "completion" "company" "emacs>=26.0.91"
  :url "https://github.com/sebastiencs/company-box"
  :added "2022-11-27"
  :emacs>= 26.0
  :ensure t
  :hook (company-mode-hook . company-box-mode))

(leaf flycheck
  :ensure t
  :init (global-flycheck-mode)
  :config
  (setq flycheck-check-syntax-automatically `(mode-enabled save))
  )

(leaf which-key
  :ensure t
  :commands which-key-mode
  :hook (after-init-hook . which-key-mode))

(leaf doom-modeline
  :ensure t
  :require t
  :hook (after-init-hook . doom-modeline-mode)
  :custom
  (doom-modeline-bar-width . 3)
  (doom-modeline-height . 25)
  (doom-modeline-major-mode-color-icon . t)
  (doom-modeline-minor-modes . t)
  (doom-modeline-github . nil)
  (doom-modeline-mu4e . nil)
  (doom-modeline-irc . nil))

(leaf paren
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :req "emacs-25.1" "compat-28.1.1.2" "dash-20210826" "git-commit-20220222" "magit-section-20220325" "transient-20220325" "with-editor-20220318"
  :tag "vc" "tools" "git" "emacs>=25.1"
  :url "https://github.com/magit/magit"
  :added "2022-11-27"
  :emacs>= 25.1
  :ensure t
  :after compat git-commit magit-section with-editor)

(leaf ivy
  :doc "Incremental Vertical completYon"
  :req "emacs-24.5"
  :tag "matching" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :added "2022-11-27"
  :emacs>= 24.5
  :ensure t
  :blackout t
  :leaf-defer nil
  :custom ((ivy-initial-inputs-alist . nil)
           (ivy-use-selectable-prompt . t))
  :global-minor-mode t
  )

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (blackout el-get hydra leaf-keywords leaf))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
