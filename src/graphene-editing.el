;;; graphene-editing.el --- Graphene editing defaults
;;
;; Copyright (c) @YEAR Robert Dallas Gray
;;
;; Author: Robert Dallas Gray <mail@robertdallasgray.com>
;; URL: https://github.com/rdallasgray/graphene
;; Version: @VERSION
;; Keywords: defaults

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Graphene is a set of default settings and functionality to make Emacs a little friendlier.
;; The editing defaults target the text editing environment, with particular relevance to prog modes.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

;; Delete marked text on typing
(delete-selection-mode t)

;; Soft-wrap lines
(global-visual-line-mode t)

;; Nicer scrolling with mouse wheel/trackpad.
(unless (and (boundp 'mac-mouse-wheel-smooth-scroll) mac-mouse-wheel-smooth-scroll)
  (global-set-key [wheel-down] (lambda () (interactive) (scroll-up-command 1)))
  (global-set-key [wheel-up] (lambda () (interactive) (scroll-down-command 1)))
  (global-set-key [double-wheel-down] (lambda () (interactive) (scroll-up-command 2)))
  (global-set-key [double-wheel-up] (lambda () (interactive) (scroll-down-command 2)))
  (global-set-key [triple-wheel-down] (lambda () (interactive) (scroll-up-command 4)))
  (global-set-key [triple-wheel-up] (lambda () (interactive) (scroll-down-command 4))))

;; Character encodings default to utf-8.
(prefer-coding-system 'utf-8)
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

;; apply syntax highlighting to all buffers
(global-font-lock-mode t)

;; no overlay in smartparens
(eval-after-load 'smartparens
  '(progn
     (require 'smartparens-config)
     (require 'graphene-smartparens-config)
     (setq sp-highlight-pair-overlay nil)))

;; Use web-mode for editing code embedded in HTML.
(require 'web-mode)
(push '("php" . "\\.phtml\\'") web-mode-engine-file-regexps)
(dolist (engine-regexp web-mode-engine-file-regexps)
  (when (cdr engine-regexp)
    (add-to-list 'auto-mode-alist `(,(cdr engine-regexp) . web-mode))))

;; Autocomplete defaults
;; ESC to get out of autocomplete menu
(eval-after-load 'auto-complete
  '(progn
     (require 'auto-complete-config)
     (ac-config-default)
     (define-key ac-completing-map (kbd "ESC") 'ac-stop)
     (setq ac-auto-show-menu 0.2
           ac-auto-start 3
           ac-quick-help-delay 2.0
           ac-ignore-case nil
           ac-candidate-menu-min 2
           ac-use-quick-help nil
           ac-limit 10)

     (setq-default ac-sources '(ac-source-words-in-buffer
                                ac-source-words-in-same-mode-buffers
                                ac-source-dictionary
                                ac-source-filename))))

;; Linum format to avoid graphics glitches in fringe
(setq linum-format " %4d ")

;; Show matching parens immediately.

;; Main hook to be run on entering de facto prog modes, enabling linum, autopair,
;; autocomplete, plus setting binding newline key to newline-and-indent
(add-hook 'graphene-prog-mode-hook
          (lambda ()
            (when graphene-linum-auto
              (linum-mode t))
            (when graphene-autocomplete-auto
              (require 'auto-complete)
              (auto-complete-mode t))
            (when graphene-autopair-auto
              (require 'smartparens)
              (smartparens-mode t)
              (when 'graphene-parens-auto
                (show-paren-mode nil)
                (show-smartparens-mode t)
                (setq sp-show-pair-delay 0)))
            (define-key (current-local-map) [remap newline] 'newline-and-indent)))

;; Fix newline-and-indent in ruby-mode
(add-hook 'ruby-mode-hook
          (lambda ()
            (define-key (current-local-map) [remap newline] 'reindent-then-newline-and-indent)))

;; Attach de facto prog mode hooks after loading init file
(add-hook 'after-init-hook
          (lambda ()
            (dolist (hook graphene-prog-mode-hooks)
              (add-hook hook (lambda () (run-hooks 'graphene-prog-mode-hook))))))

(provide 'graphene-editing)
