;;; flycheck-hledger.el --- Flycheck module to check hledger journals  -*- lexical-binding: t; -*-

;; Copyright (C) 2020-2023  Damien Cassou

;; Author: Damien Cassou <damien@cassou.me>
;; Url: https://github.com/DamienCassou/flycheck-hledger/
;; Package-requires: ((emacs "27.1") (flycheck "31"))
;; Version: 0.3.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package is a flycheck [1] checker for hledger files [2].
;;
;; [1] https://www.flycheck.org/en/latest/
;; [2] https://hledger.org/

;;; Code:

(require 'flycheck)

(flycheck-def-option-var flycheck-hledger-strict nil hledger
  "Whether to enable strict mode.

See URL https://hledger.org/hledger.html#strict-mode"
  :type 'boolean)

(flycheck-def-option-var flycheck-hledger-checks nil hledger
  "List of additional checks to run.

Checks include: accounts, commodities, ordereddates, payees and
uniqueleafnames.  More information at URL
https://hledger.org/hledger.html#check."
  :type '(repeat string))

(defun flycheck-hledger--enabled-p ()
  "Return non-nil if flycheck-hledger should be enabled in the current buffer."
  (or
   ;; Either the user is using `hledger-mode':
   (derived-mode-p 'hledger-mode)
   ;; or the user is using `ledger-mode' with the binary path pointing
   ;; to "hledger":
   (and (bound-and-true-p ledger-binary-path)
        (string-suffix-p "hledger" ledger-binary-path))))

(flycheck-define-checker hledger
  "A checker for errors in hledger journals, optionally with --strict checking and/or extra checks supported by the check command."
  :modes (ledger-mode hledger-mode)
  ;; Activate the checker only if ledger-binary-path ends with "hledger":
  :predicate flycheck-hledger--enabled-p
  :command ("hledger" "-f" source-inplace "--auto" "check"
            (option-flag "--strict" flycheck-hledger-strict)
            (eval flycheck-hledger-checks))
  :error-filter (lambda (errors) (flycheck-sanitize-errors (flycheck-fill-empty-line-numbers errors)))
  :error-parser flycheck-parse-with-patterns
  :error-patterns
  (
   ;; hledger error messages have changed over time. There was a significant cleanup in hledger 1.26.
   ;; Here we try to support 2024's hledger 1.40 and up. Most error messages
   ;; start with a line like "hledger: Error: PATH:LINE[-ENDLINE][:COL[-ENDCOL]]:",
   ;; followed by a multiline excerpt which we ignore here,
   ;; followed by one or more lines of explanation which we use as the flycheck message.
   ;; Eg (see also https://github.com/simonmichael/hledger/tree/master/hledger/test/errors):
   ;;
   ;;     hledger: Error: /Users/simon/src/hledger/hledger/test/errors/./assertions.j:4:8:
   ;;       | 2022-01-01
   ;;     4 |     a               0 = 1
   ;;       |                       ^^^
   ;;
   ;;     Balance assertion failed in a
   ;;     In commodity "" at this point, excluding subaccounts, ignoring costs,
   ;;     the asserted balance is:        1
   ;;     but the calculated balance is:  0
   ;;     (difference: 1)
   ;;     To troubleshoot, check this account's running balance with assertions disabled, eg:
   ;;     hledger reg -I 'a$' cur:
   ;; 
   ;; There are a few variations of this - some message are missing newlines etc.
   (error
    bol "hledger" (optional ".exe") ": Error: " (file-name (optional alpha ":") (+ (not ":"))) ":" line (optional "-" end-line) (optional ":" column (optional "-" end-column)) ":\n"
    (one-or-more  ; usually there's one excerpt, but ordereddates error shows two
        (one-or-more (or (seq (one-or-more digit) " ") (>= 2 " ")) "|" (zero-or-more nonl) "\n")
        (? "\n"))
    (message (one-or-more bol (zero-or-more nonl) (? "\n"))))

   ;; And there are still some error messages without position info. Eg:
   ;; hledger: Error: sorry, CSV files can't be included yet
   (error
    bol "hledger" (optional ".exe") ": Error: " (message (one-or-more nonl) (? "\n")))))


(add-to-list 'flycheck-checkers 'hledger)

(provide 'flycheck-hledger)
;;; flycheck-hledger.el ends here

;;; LocalWords:  flycheck-hledger
