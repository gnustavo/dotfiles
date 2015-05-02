;-*-mode:emacs-lisp-*-
;  $Id: .emacs,v 1.10 2007/01/10 16:52:18 gustavo Exp gustavo $

(setq load-path
      (append (list (expand-file-name "~/share/emacs"))
	      load-path))

; http://opal.cabochon.com/~stevey/blog-rants/effective-emacs.html
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
;(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
;(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(defun try-to-require (lib &optional file)
  (condition-case nil (require lib file) (error nil)))

(defun try-to-load-library (lib &optional afterwork)
  (if (load lib 'noerror 'nomessage)
      (eval afterwork)
    (beep)
    (message "Can't find the %s library." lib)))

(try-to-require 'site-start)

(try-to-require 'window+)

(cond (window-system
       (global-font-lock-mode t)
       (scroll-bar-mode -1)
       (tool-bar-mode 0)
       (transient-mark-mode 0)
       (and (>= emacs-major-version 21)
	    (mouse-wheel-mode 1)
	    ;(mouse-avoidance-mode 'exile)
	    )))

;(try-to-require 'tex-site)

; MINOR CUSTOMIZATIONS

;(setq-default 'default-buffer-file-coding-system "mule-utf-8")

(autoload 'todo-mode "todo-mode"
          "Major mode for editing TODO lists." t)
(autoload 'todo-show "todo-mode"
          "Show TODO items." t)
(autoload 'todo-insert-item "todo-mode"
          "Add TODO item." t)

(setq compile-command "make -k ")

;(enable-flow-control-on "vt100" "vt200" "vt220")

;; My auto-insert's
(add-hook 'find-file-hooks 'auto-insert)
(defun my-license-notice ()
  "Inserts a properly commented FSF style license notice."
  (interactive)
  (push-mark nil 'nomsg t)
  (insert
   "This program is free software; you can redistribute it and/or modify\n"
   "it under the terms of the GNU General Public License as published by\n"
   "the Free Software Foundation; either version 2 of the License, or\n"
   "(at your option) any later version.\n\n"

   "This program is distributed in the hope that it will be useful,\n"
   "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
   "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
   "GNU General Public License for more details.\n\n"

   "You should have received a copy of the GNU General Public License\n"
   "along with this program; if not, write to the Free Software\n"
   "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA\n")
  (comment-region (point) (mark))
  (pop-mark))

(defalias 'perl-mode 'cperl-mode)
(define-auto-insert '("\\.pl\\'" . "Perl script") "perl")
(define-auto-insert '("\\.pod\\'" . "POD document") "pod")
(define-auto-insert '(sh-mode . "Shell script") "shell")
(define-auto-insert '(latex-mode . "LaTeX document") "latex")
(define-auto-insert '(c-mode . "C source") "c++")
(define-auto-insert '(c++-mode . "C++ source") "c++")
(define-auto-insert '(python-mode . "Python source") "python")

(eval-after-load "cperl-mode"
  '(add-hook 'cperl-mode-hook 'perlcritic-mode))
(eval-after-load "perl-mode"
  '(add-hook 'perl-mode-hook 'perlcritic-mode))

(add-hook 'shell-mode-hook
	  (function
	   (lambda ()
	     (setq comint-prompt-regexp "^[^#$%>\n]*[#$%>] *"))))

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(add-hook 'LaTeX-mode-hook
	  (function
	   (lambda ()
	     (setq TeX-command-default "LaTeX PDF"))))

; MODE HOOKS

;; Customizations for both c-mode and c++-mode
(add-hook 'c-mode-common-hook
	  (function
	   (lambda ()
	     ;; set up for my preferred indentation style
	     ;; but only do it once.
	     (c-set-offset 'substatement-open 0)
	     (c-set-offset 'statement-case-open '+)
	     ;; other customizations
	     (setq c-basic-offset 4
		   tab-width 8
		   indent-tabs-mode nil
		   c-cleanup-list '(empty-defun-braces
				    defun-close-semi
				    scope-operator))
	     (c-toggle-auto-hungry-state 1))))

(add-hook 'c++-mode-hook
	  (function
	   (lambda ()
	     (local-set-key "\C-c\C-h" 'c++-copyright-notice)
	     (local-set-key "\C-c\C-i" 'c++-include))))

(autoload 'c++-copyright-notice "cplusplus" nil t)
(autoload 'c++-include "cplusplus" nil t)

;(autoload 'w3m "w3m" "Interface for w3m on Emacs." t)

(add-hook 'change-log-mode-hook
	  (function
	   (lambda ()
	     (local-set-key "\C-c\C-c" 'change-log-exit))))

(defun change-log-exit ()
  (interactive)
  (save-buffer)
  (bury-buffer)
  (if (or (not (= (window-height) (1- (frame-height))))
	  (not (= (window-width) (frame-width))))
      (delete-window)))

(add-hook 'gdb-mode-hook
	  (function
	   (lambda ()
	     (local-set-key "\t" 'comint-dynamic-complete)
	     (local-set-key "\e?" 'comint-dynamic-list-completions))))

(add-hook 'text-mode-hook
	  (function (lambda () (turn-on-auto-fill))))

(add-hook 'TeX-mode-hook
	  (function (lambda () (outline-minor-mode 1))))

(add-to-list 'auto-mode-alist '("\\.o[dt][bcfghimpst]\\'" . archive-mode))
(add-to-list 'auto-mode-alist '("\\.s[xt][cdgimw]\\'" . archive-mode))

(autoload 'pod-mode "pod")

(autoload 'perlcritic        "perlcritic" "" t)
(autoload 'perlcritic-region "perlcritic" "" t)
(autoload 'perlcritic-mode   "perlcritic" "" t)

;; KEYBOARD CUSTOMIZATION

; my special bindings
(defun my-changelog ()
  (interactive)
  (let ((add-log-current-defun-function (lambda () nil))
	(add-log-buffer-file-name-function (lambda () nil)))
    (add-change-log-entry-other-window nil "/home/gustavo/.logbook")))

(defun my-changelog-pwd ()
  (interactive)
  (let ((add-log-current-defun-function (lambda () nil))
	(add-log-buffer-file-name-function (lambda () nil)))
    (add-change-log-entry-other-window nil "CHANGELOG")))

(global-set-key "\C-c=" 'ediff)
(global-set-key "\C-c4a" 'my-changelog)
(global-set-key "\C-c4c" 'my-changelog-pwd)
(global-set-key "\C-cA" 'align)
(global-set-key "\C-ca" 'rda)
(global-set-key "\C-cb" 'bury-buffer)
(global-set-key "\C-cC" 'calculator)
(global-set-key "\C-cc" 'compile)
(global-set-key "\C-cd" 'gdb)
(global-set-key "\C-ce" 'bbdb)
(global-set-key "\C-cE" 'bbdb-create)
; "\C-cf"
(global-set-key "\C-cG" 'goto-line)
(global-set-key "\C-cg" 'magit-status)
; "\C-ch"
(global-set-key "\C-cI" 'insert-buffer)
(global-set-key "\C-ci" 'todo-insert-item)
; "\C-cj"
(global-set-key "\C-ck" 'bbdb-complete-name)
(global-set-key "\C-cl" 'load-file)
(global-set-key "\C-cL" 'load-library)
(global-set-key "\C-cm" 'woman)
; "\C-co"
; "\C-cp"
; "\C-cq"
;(global-set-key "\C-cr" 'gnus)
(global-set-key "\C-cs" 'grep)
(global-set-key "\C-ct" 'todo-show)
;(global-set-key "\C-cu" 'svn-status)
(global-set-key "\C-cv" 'set-variable)
(global-set-key "\C-c\C-v" 'view-file)
(global-set-key "\C-cw" 'what-line)
(global-set-key "\C-cx" 'imenu)
; "\C-cy"
; "\C-cz"
(global-set-key "\C-c\M-%" 'query-replace-regexp)

(global-set-key "\C-c\C-z." 'browse-url-at-point)
(global-set-key "\C-c\C-zb" 'browse-url-of-buffer)
(global-set-key "\C-c\C-zr" 'browse-url-of-region)
(global-set-key "\C-c\C-zu" 'browse-url)
(global-set-key "\C-c\C-zv" 'browse-url-of-file)

(global-set-key "\C-x\C-b" 'buffer-menu)
(global-set-key "\C-xm" 'gnus-group-mail)

(global-set-key "\C-c/e" 'mc-encrypt)
(global-set-key "\C-c/d" 'mc-decrypt)

; Bind dired-jump before dired-x.el is loaded.
(define-key global-map "\C-x\C-j" 'dired-jump)

; Marmalade - http://marmalade-repo.org/
(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize)

; ENABLING SOME ADVANCED COMMANDS
(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)

(server-start)

(show-paren-mode t)
(auto-compression-mode 1)

;(try-to-load-library "ispell")
;(try-to-load-library "psgml-init")
;(try-to-load-library "g")

;;; Fixing a problem with sending attached PDFs
;(require 'mm-encode)
; force PDFs go 8bit
;(setq mm-content-transfer-encoding-defaults
;      (cons '("application/pdf" base64)
;	    mm-content-transfer-encoding-defaults))
; redefine mm-encode-buffer
;(defun mm-encode-buffer (type)
;  "Encode the buffer which contains data of TYPE.
;The encoding used is returned."
;  (let* ((mime-type (if (stringp type) type (car type)))
;	 (encoding
;	  (or (and (listp type)
;		   (cadr (assq 'encoding type)))
;	      (mm-content-transfer-encoding mime-type)))
;	 (bits (mm-body-7-or-8)))
;    (mm-encode-content-transfer-encoding encoding mime-type)
;    encoding))

;;; Fixing a problem with saving MIME parts
;(require 'mm-decode)
;(defun mm-save-part (handle)
;  "Write HANDLE to a file."
;  (let* ((name (mail-content-type-get (mm-handle-type handle) 'name))
;	 (filename (mail-content-type-get
;		    (mm-handle-disposition handle) 'filename))
;	 file)
;    (when name
;      (setq name (rfc2047-decode-string name)))
;    (when filename
;      (setq filename (rfc2047-decode-string (file-name-nondirectory filename))))
;    (setq file
;	  (read-file-name "Save MIME part to: "
;			  (expand-file-name
;			   (or filename name "")
;			   (or mm-default-directory default-directory))))
;    (setq mm-default-directory (file-name-directory file))
;    (when (or (not (file-exists-p file))
;	      (yes-or-no-p (format "File %s already exists; overwrite? "
;				   file)))
;      (mm-save-part-to-file handle file))))

;;; Based on browse-url-netscape
;(defvar browse-url-new-tab-flag t)

;(defmacro browse-url-maybe-new-tab (arg)
;  `(if (interactive-p)
;       ,arg
;     browse-url-new-tab-flag))

;(defun browse-url-firefox (url &optional new-tab)
;  "Ask the Firefox WWW browser to load URL.
;Default to the URL around or before point.  The strings in variable
;`browse-url-mozilla-arguments' are also passed to Mozilla.
;
;When called interactively, if variable `browse-url-new-tab-flag' is
;non-nil, load the document in a new Firefox tab, otherwise use a
;random existing one.  A non-nil interactive prefix argument reverses
;the effect of `browse-url-new-tab-flag'.
;
;When called non-interactively, optional second argument NEW-TAB is
;used instead of `browse-url-new-tab-flag'."
;  (interactive (browse-url-interactive-arg "URL: "))
;  ;; URL encode any `confusing' characters in the URL.  This needs to
;  ;; include at least commas; presumably also close parens.
;  (while (string-match "[,)]" url)
;    (setq url (replace-match
;	       (format "%%%x" (string-to-char (match-string 0 url))) t t url)))
;  (let* ((process-environment (browse-url-process-environment))
;         (process (apply 'start-process
;			 (concat "firefox " url) nil
;			 browse-url-mozilla-program
;			 (append
;			  browse-url-netscape-arguments
;			  (if (eq window-system 'w32)
;			      (list url)
;			    (append
;			     (list "-remote"
;				   (concat "openURL(" url
;					   (if (browse-url-maybe-new-tab
;						new-tab)
;					       ",new-tab")
;					   ")"))))))))
;    (set-process-sentinel process
;			  `(lambda (process change)
;			     (browse-url-netscape-sentinel process ,url)))))

;;; Functions to save a message with a descriptive name
;(defun gnus-compose-verbose-filename (date info)
;  (let ((time (condition-case ()
;		  (date-to-time date)
;		(error '(0 0))))
;	(msg info)
;	(i 0))
;    (while (string-match "[^()+,-.0-~]" msg i)
;      (setq i (match-end 0))
;      (store-substring msg (match-beginning 0) ?\_))
;    (concat
;     (format-time-string "%Y%m%dT%H%M%S" time)
;     "_" msg)))

;(defun gnus-subject-save-name (newsgroup headers &optional last-file)
;  "Generate file name from NEWSGROUP, HEADERS, and optional LAST-FILE.
;The file basename is of the form YYYYMMDDHHMMSS_Subject.
;If variable `gnus-use-long-file-name' is non-nil, it is
;~/News/news.group/basename. Otherwise, it is like ~/News/news/group/basename."
;  (let ((dir (if last-file
;		 (file-name-directory last-file)
;	       (if (gnus-use-long-file-name 'not-save)
;		   newsgroup
;		 (gnus-newsgroup-directory-form newsgroup))))
;	(file (gnus-compose-verbose-filename
;	       (mail-header-date headers)
;	       (mail-header-subject headers))))
;    (expand-file-name
;     (concat dir "/" file))))

;; From: Arnaldo Mandel <am@ime.usp.br>
;; Subject: Re: MS Word mode?
;; Date: Fri, 8 Nov 2002 11:52:33 -0200
;(defun no-word ()
;  "Run antiword on the entire buffer."
;  (interactive)
;  (if (string-match "Microsoft "
;		    (shell-command-to-string (concat "file \"" buffer-file-name "\"")))
;      (shell-command-on-region (point-min) (point-max) "antiword - " t t)))
;(add-to-list 'auto-mode-alist '("\\.doc\\'" . no-word))

;;; Interactive customizations.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Man-notify-method (quote pushy))
 '(TeX-auto-save t)
 '(TeX-brace-indent-level 0)
 '(TeX-command-list (quote (("TeX" "tex '\\nonstopmode\\input %t'" TeX-run-TeX nil t) ("TeX Interactive" "tex %t" TeX-run-interactive nil t) ("LaTeX" "%l '\\nonstopmode\\input{%t}'" TeX-run-LaTeX nil t) ("LaTeX Interactive" "%l %t" TeX-run-interactive nil t) ("LaTeX2e" "latex2e '\\nonstopmode\\input{%t}'" TeX-run-LaTeX nil t) ("View" "%v " TeX-run-silent t nil) ("Print" "%p " TeX-run-command t nil) ("Queue" "%q" TeX-run-background nil nil) ("File" "dvips %d -o %f " TeX-run-command t nil) ("BibTeX" "bibtex %s" TeX-run-BibTeX nil nil) ("Index" "makeindex %s" TeX-run-command nil t) ("Check" "lacheck %s" TeX-run-compile nil t) ("Spell" "<ignored>" TeX-run-ispell-on-document nil nil) ("Other" "" TeX-run-command t t) ("LaTeX PDF" "pdflatex '\\nonstopmode\\input{%t}'" TeX-run-LaTeX nil t) ("View PDF" "acroread %P" TeX-run-silent nil "nil") ("Makeinfo" "makeinfo %t" TeX-run-compile nil t) ("Makeinfo HTML" "makeinfo --html %t" TeX-run-compile nil t) ("AmSTeX" "amstex '\\nonstopmode\\input %t'" TeX-run-TeX nil t))))
 '(TeX-electric-escape t)
 '(TeX-expand-list (quote (("%p" TeX-printer-query) ("%q" (lambda nil (TeX-printer-query TeX-queue-command 2))) ("%v" (lambda nil (TeX-style-check TeX-view-style))) ("%l" (lambda nil (TeX-style-check LaTeX-command-style))) ("%s" file nil t) ("%t" file t t) ("%n" TeX-current-line) ("%d" file "dvi" t) ("%f" file "ps" t) ("%b" TeX-current-file-name-nondirectory) ("%P" file "pdf" t))))
 '(TeX-master nil)
 '(TeX-parse-self t)
 '(align-rules-list (quote ((lisp-second-arg (regexp . "\\(^\\s-+[^( 	
]\\|(\\(\\S-+\\)\\s-+\\)\\S-+\\(\\s-+\\)") (group . 3) (modes . align-lisp-modes) (run-if lambda nil current-prefix-arg)) (lisp-alist-dot (regexp . "\\(\\s-*\\)\\.\\(\\s-*\\)") (group 1 2) (modes . align-lisp-modes)) (open-comment (regexp lambda (end reverse) (funcall (if reverse (quote re-search-backward) (quote re-search-forward)) (concat "[^ 	
\\\\]" (regexp-quote comment-start) "\\(.+\\)$") end t)) (modes . align-open-comment-modes)) (c-macro-definition (regexp . "^\\s-*#\\s-*define\\s-+\\S-+\\(\\s-+\\)") (modes . align-c++-modes)) (c-variable-declaration (regexp . "[*&0-9A-Za-z_]>?[&*]*\\(\\s-+[*&]*\\)[A-Za-z_][0-9A-Za-z:_]*\\s-*\\(\\()\\|=[^=
].*\\|(.*)\\|\\(\\[.*\\]\\)*\\)?\\s-*[;,]\\|)\\s-*$\\)") (group . 1) (modes . align-c++-modes) (justify . t) (valid lambda nil (not (or (save-excursion (goto-char (match-beginning 1)) (backward-word 1) (looking-at "\\(goto\\|return\\|new\\|delete\\|throw\\)")) (if (and (boundp (quote font-lock-mode)) font-lock-mode) (eq (get-text-property (point) (quote face)) (quote font-lock-comment-face)) (eq (caar (c-guess-basic-syntax)) (quote c))))))) (c-assignment (regexp . "[^-=!^&*+<>/| 	
]\\(\\s-*[-=!^&*+<>/|]*\\)=\\(\\s-*\\)\\([^= 	
]\\|$\\)") (group 1 2) (modes . align-c++-modes) (justify . t) (tab-stop)) (perl-assignment (regexp . "[^=!^&*-+<>/| 	
]\\(\\s-*\\)=[~>]?\\(\\s-*\\)\\([^>= 	
]\\|$\\)") (group 1 2) (modes . align-perl-modes) (tab-stop)) (python-assignment (regexp . "[^=!<> 	
]\\(\\s-*\\)=\\(\\s-*\\)\\([^>= 	
]\\|$\\)") (group 1 2) (modes quote (python-mode)) (tab-stop)) (make-assignment (regexp . "^\\s-*\\w+\\(\\s-*\\):?=\\(\\s-*\\)\\([^	
 \\\\]\\|$\\)") (group 1 2) (modes quote (makefile-mode)) (tab-stop)) (c-comma-delimiter (regexp . ",\\(\\s-*\\)[^/ 	
]") (repeat . t) (modes . align-c++-modes) (run-if lambda nil current-prefix-arg)) (basic-comma-delimiter (regexp . ",\\(\\s-*\\)[^# 	
]") (repeat . t) (modes append align-perl-modes (quote (python-mode))) (run-if lambda nil current-prefix-arg)) (c++-comment (regexp . "\\(\\s-*\\)\\(//.*\\|/\\*.*\\*/\\s-*\\)$") (modes . align-c++-modes) (column . comment-column) (valid lambda nil (save-excursion (goto-char (match-beginning 1)) (not (bolp))))) (c-chain-logic (regexp . "\\(\\s-*\\)\\(&&\\|||\\|\\<and\\>\\|\\<or\\>\\)") (modes . align-c++-modes) (valid lambda nil (save-excursion (goto-char (match-end 2)) (looking-at "\\s-*\\(/[*/]\\|$\\)")))) (perl-chain-logic (regexp . "\\(\\s-*\\)\\(&&\\|||\\|\\<and\\>\\|\\<or\\>\\)") (modes . align-perl-modes) (valid lambda nil (save-excursion (goto-char (match-end 2)) (looking-at "\\s-*\\(#\\|$\\)")))) (python-chain-logic (regexp . "\\(\\s-*\\)\\(\\<and\\>\\|\\<or\\>\\)") (modes quote (python-mode)) (valid lambda nil (save-excursion (goto-char (match-end 2)) (looking-at "\\s-*\\(#\\|$\\|\\\\\\)")))) (c-macro-line-continuation (regexp . "\\(\\s-*\\)\\\\$") (modes . align-c++-modes) (column . c-backslash-column)) (basic-line-continuation (regexp . "\\(\\s-*\\)\\\\$") (modes quote (python-mode makefile-mode))) (tex-record-separator (regexp lambda (end reverse) (align-match-tex-pattern "&" end reverse)) (group 1 2) (modes . align-tex-modes) (repeat . t)) (tex-tabbing-separator (regexp lambda (end reverse) (align-match-tex-pattern "\\\\[=>]" end reverse)) (group 1 2) (modes . align-tex-modes) (repeat . t) (run-if lambda nil (eq major-mode (quote latex-mode)))) (tex-record-break (regexp . "\\(\\s-*\\)\\\\\\\\") (modes . align-tex-modes)) (text-column (regexp . "\\(^\\|\\>\\)\\(\\s-+\\)\\(\\<\\|$\\)") (group . 2) (modes append align-text-modes (quote (fundamental-mode))) (repeat . t) (tab-stop)))))
 '(align-text-modes (quote (text-mode outline-mode)))
 '(ange-ftp-ftp-program-name "eftp")
 '(auto-insert-directory "~/.emacs-auto-insert.d/")
 '(auto-insert-mode t)
 '(bbdb-complete-name-allow-cycling t)
 '(bbdb-north-american-phone-numbers-p nil)
 '(bbdb-offer-save (quote savenoprompt))
 '(bbdb-quiet-about-name-mismatches nil)
 '(bbdb-use-pop-up nil)
 '(bbdb/mail-auto-create-p nil)
 '(browse-url-browser-function (quote browse-url-default-browser))
 '(browse-url-generic-program "/opt/google/chrome/google-chrome")
 '(c-default-style (quote ((c++-mode . "") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(cperl-close-paren-offset -4)
 '(cperl-continued-statement-offset 4)
 '(cperl-hairy t)
 '(cperl-indent-level 4)
 '(cperl-indent-parens-as-block t)
 '(current-language-environment "Brazilian Portuguese")
 '(desktop-save-mode t)
 '(display-time-24hr-format t)
 '(display-time-mail-file "/l/disk0/Mail/spool/Newmail.spool")
 '(ediff-highlight-all-diffs nil)
 '(fill-column 76)
 '(g-user-email "gnustavo@gmail.com")
 '(gblogger-user-email "gnustavo@gmail.com")
 '(gnus-newsgroup-ignored-charsets (quote (unknown-8bit x-unknown unknown)))
 '(gnus-summary-line-format "%U%R%z%I%5N%(%[%5us: %-20,20n%]%) %s
")
 '(gnus-visible-headers (quote ("^From:" "^Newsgroups:" "^Subject:" "^Date:" "^Followup-To:" "^Reply-To:" "^Organization:" "^Summary:" "^Keywords:" "^To:" "^[BGF]?Cc:" "^Posted-To:" "^Mail-Copies-To:" "^Apparently-To:" "^Gnus-Warning:" "^Resent-From:" "^X-Sent:" "^X-Spam" "^X-Greylist")))
 '(indent-tabs-mode nil)
 '(ispell-dictionary "american")
 '(ispell-dictionary-alist (quote (("american" "[a-zA-Z]" "[^a-zA-Z]" "[']" nil ("-d" "american") nil utf-8) ("brasileiro" "[a-záéíóúàèìòùãõçüâêôA-ZÁÉÍÓÚÀÈÌÒÙÃÕÇÜÂÊÔ]" "[^a-záéíóúàèìòùãõçüâêôA-ZÁÉÍÓÚÀÈÌÒÙÃÕÇÜÂÊÔ]" "[---']" t ("-d" "brasileiro") nil utf-8) (nil "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-B") nil utf-8))) t)
 '(ispell-local-dictionary nil)
 '(lpr-command "mpage2")
 '(lpr-switches nil)
 '(magit-repo-dirs (quote ("/home/gustavo/git/mine")))
 '(mail-archive-file-name "~gustavo/Mail/Outgoings")
 '(mail-default-reply-to "gustavo@cpqd.com.br")
 '(mail-source-crash-box "/l/disk0/Mail/.emacs-mail-crash-box")
 '(message-signature nil)
 '(nxml-sexp-element-flag t)
 '(outline-minor-mode-prefix "")
 '(perl-tab-to-comment t)
 '(printer-name "imp_002_lpd")
 '(ps-default-bg "white")
 '(ps-default-fg "black")
 '(ps-lpr-command "lpr")
 '(ps-paper-type (quote a4))
 '(ps-print-color-p nil)
 '(ps-printer-name nil)
 '(puppet-indent-level 2)
 '(reftex-plug-into-AUCTeX t)
 '(require-final-newline (quote ask))
 '(ruby-indent-level 4)
 '(safe-local-variable-values (quote ((todo-categories "iSCSI" "Pessoal" "CPqD") (todo-categories "Pessoal" "CPqD"))))
 '(sc-attrib-selection-list (quote (("from" (("mhelena@" . "Baby") ("gaseta@" . "Gaseta"))))))
 '(sc-auto-fill-region-p nil)
 '(sc-citation-leader "  ")
 '(sc-cite-region-limit 300)
 '(sc-nested-citation-p t)
 '(sc-preferred-attribution-list (quote ("sc-lastchoice" "x-attribution" "sc-consult" "firstname" "initials" "lastname")))
 '(sc-preferred-header-style 1)
 '(scroll-step 1)
 '(show-paren-mode t)
 '(terminal-escape-char 27)
 '(tool-bar-mode nil)
 '(transient-mark-mode nil)
 '(use-file-dialog nil)
 '(user-mail-address "gustavo@cpqd.com.br")
 '(vc-handled-backends nil)
 '(woman-cache-filename "~/.wmncach.el")
 '(woman-topic-at-point nil)
 '(woman-use-own-frame nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(put 'LaTeX-hide-environment 'disabled nil)

(set-language-info-alist
 "Brazilian Portuguese" '((tutorial . "TUTORIAL.pt_BR")
	    (charset unicode)
	    (coding-system utf-8 iso-latin-1 iso-latin-9)
	    (coding-priority utf-8 iso-latin-1)
	    (nonascii-translation . iso-8859-1)
	    (unibyte-display . iso-8859-1)
	    (input-method . "latin-1-prefix")
	    (sample-text . "Oi")
	    (documentation . "Support for Brazilian Portuguese."))
 '("European"))
(prefer-coding-system 'utf-8)
