;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;
;;; General configuration

(setq user-full-name "Paul Townsend"
      user-mail-address "paul@kobol.org")


;;
;;; UI

;;; Frames/Windows

;; Tidy up titlebar
(when IS-MAC
  (setq ns-use-proxy-icon nil))
(setq frame-title-format nil)

;; Set default frame size to 160x80
(add-to-list 'default-frame-alist '(width . 160))
(add-to-list 'default-frame-alist '(height . 80))

;; Enable menu bar
(when (window-system)
  (menu-bar-mode 1))

;;; Fonts

(when IS-MAC
  (setq doom-font (font-spec :family "SF Mono" :size 12)
        ns-use-thin-smoothing t))


;;
;;; Editor

;;; Scrolling

;; Overwrite Doom default for smoother scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))


;;
;;; Keybinds

;; Use right-alt/option to get at `€' and `#' on macOS
(when IS-MAC
  (setq mac-right-option-modifier 'none))


;;
;;; Modules

;;; :ui doom-dashboard
(setq fancy-splash-image (concat doom-private-dir "splash.png"))

;;; :editor evil
(setq evil-split-window-below t
      evil-vsplit-window-right t)

;;; :lang javascript
(after! js2-mode
  (setq js2-basic-offset 2))

;;; :lang org
(add-hook 'org-mode-hook #'auto-fill-mode)

(setq org-directory "~/Documents/org/"
      org-ellipsis " ▼ "

      org-journal-dir (concat org-directory "journal/")
      org-journal-file-format "%Y-%m.org"
      org-journal-date-format "%A, %d/%m/%y"
      org-journal-file-type 'monthly

      +org-roam-open-buffer-on-find-file nil
      org-roam-directory (concat org-directory "notes/")
      org-roam-db-location (concat org-roam-directory ".org-roam.db"))

;;; :lang python
(after! python
  (setq python-shell-interpreter "python3"))

(after! lsp-python-ms
  (set-lsp-priority! 'mspyls 1))

;;; :lang web
(after! web-mode
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

(after! css-mode
  (setq css-indent-offset 2))

;;; :email mu4e
(after! mu4e
  (setq mu4e-root-maildir "~/Mail"
        mu4e-sent-folder "/Sent"
        mu4e-drafts-folder "/Drafts"
        mu4e-trash-folder "/Trash"
        mu4e-refile-folder "/Archive"
        mu4e-maildir-shortcuts
        '(("/INBOX" . ?i)
          ("/Sent" . ?s)
          ("/Drafts" . ?d)
          ("/Trash" . ?t)
          ("/Archive" . ?a))
        mu4e-attachment-dir "~/Downloads")

  ;; Don't set the `T' flag when moving a message to the trash
  ;; https://github.com/djcb/mu/issues/1136#issuecomment-486177435
  (setf (alist-get 'trash mu4e-marks)
        (list :char "d"
              :prompt "dtrash"
              :dyn-target (lambda (target msg)
                            (mu4e-get-trash-folder msg))
              :action (lambda (docid msg target)
                        (mu4e~proc-move docid (mu4e~mark-check-target target) "+S-u-N"))))

  ;; Add a `Folder' column to the headers view to give context to messages
  (add-to-list 'mu4e-header-info-custom
               '(:folder
                 :name "Folder"
                 :shortname "Folder"
                 :help "Which folder this email belongs to"
                 :function
                 (lambda (msg)
                   (let ((maildir (mu4e-message-field msg :maildir)))
                     (format "%s" (substring maildir 1 (string-match-p "/" maildir 1)))))))

  (setq mu4e-headers-fields
        '((:folder . 12)
          (:human-date . 12)
          (:flags . 4)
          (:from . 25)
          (:subject))
        mu4e-headers-date-format "%Y-%m-%d"
        mu4e-headers-time-format "%H:%M"
        mu4e-use-fancy-chars nil)

  ;; Don't apply format=flowed to outgoing messages
  (setq mu4e-compose-format-flowed nil)

  ;; The hostname used in the `Message-ID' header
  (setq message-user-fqdn "kobol.org")

  ;; Prefer msmtp over smtpmail
  (setq sendmail-program "/usr/local/bin/msmtp"
        send-mail-function 'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function 'message-send-mail-with-sendmail))
