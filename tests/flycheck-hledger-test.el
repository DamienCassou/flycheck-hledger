;;; flycheck-hledger-test.el --- Tests for flycheck-hledger  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  Damien Cassou

;; Author: Damien Cassou <damien@cassou.me>

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

;; Tests for flycheck-hledger.

;;; Code:
(require 'flycheck-hledger)
(require 'ert)

(defconst flycheck-hledger-test-error-standard-line
  '(
    :expected-file "./file.ledger"
    :expected-line "1"
    :expected-message "\nThe error message.\n"
    :output "hledger: Error: ./file.ledger:1:
  | 2022-01-01
4 |     (a)               1
  |      ^

The error message.
"))

(defconst flycheck-hledger-test-error-standard-line-column
  '(
    :expected-file "./file.ledger"
    :expected-line "1"
    :expected-column "10"
    :expected-message "\nThe error message.\n"
    :output "hledger: Error: ./file.ledger:1:10:
  | 2022-01-01
4 |     a               0 = 1
  |                       ^^^

The error message.
"))

(defconst flycheck-hledger-test-error-standard-line-line
  '(
    :expected-file "./file.ledger"
    :expected-line "1"
    :expected-end-line "2"
    :expected-message "\nThe error message.\n"
    :output "hledger: Error: ./file.ledger:1-2:
3 | 2022-01-01
  |     a               1

The error message.
"))

(defconst flycheck-hledger-test-error-standard-line-col-col
  '(
    :expected-file "./file.ledger"
    :expected-line "1"
    :expected-column "10"
    :expected-end-column "20"
    :expected-message "\nThe error message.\n"
    :output "hledger: Error: ./file.ledger:1:10-20:
3 | 2022-01-01
  |     a               1

The error message.
"))

(defconst flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers
  '(
    :expected-file "./file.ledger"
    :expected-line "2"
    :expected-message "\nStrict account checking is enabled, and
account \"a\" has not been declared.
Consider adding an account directive. Examples:

account a
account a    ; type:A  ; (L,E,R,X,C,V)\n"
    :output "hledger.exe: Error: ./file.ledger:2:
  | 2022-01-01
2 |     (a)               1
  |      ^

Strict account checking is enabled, and
account \"a\" has not been declared.
Consider adding an account directive. Examples:

account a
account a    ; type:A  ; (L,E,R,X,C,V)
"))

(defconst flycheck-hledger-test-error-standard-line-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "1"
    :expected-message "\nThe error message.\n"
    :output "hledger: error: C:\\data\\file.ledger:1:
  | 2022-01-01
4 |     (a)               1
  |      ^

The error message.
"))

(defconst flycheck-hledger-test-error-standard-line-column-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "1"
    :expected-column "10"
    :expected-message "\nThe error message.\n"
    :output "hledger: error: C:\\data\\file.ledger:1:10:
  | 2022-01-01
4 |     a               0 = 1
  |                       ^^^

The error message.
"))

(defconst flycheck-hledger-test-error-standard-line-line-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "1"
    :expected-end-line "2"
    :expected-message "\nThe error message.\n"
    :output "hledger: error: C:\\data\\file.ledger:1-2:
3 | 2022-01-01
  |     a               1

The error message.
"))

(defconst flycheck-hledger-test-error-standard-line-col-col-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "1"
    :expected-column "10"
    :expected-end-column "20"
    :expected-message "\nThe error message.\n"
    :output "hledger: error: C:\\data\\file.ledger:1:10-20:
3 | 2022-01-01
  |     a               1

The error message.
"))

(defconst flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "2"
    :expected-message "\nStrict account checking is enabled, and
account \"a\" has not been declared.
Consider adding an account directive. Examples:

account a
account a    ; type:A  ; (L,E,R,X,C,V)\n"
    :output "hledger.exe: Error: C:\\data\\file.ledger:2:
  | 2022-01-01
2 |     (a)               1
  |      ^

Strict account checking is enabled, and
account \"a\" has not been declared.
Consider adding an account directive. Examples:

account a
account a    ; type:A  ; (L,E,R,X,C,V)
"))

(defconst flycheck-hledger-test-error-symbols
  '(flycheck-hledger-test-error-standard-line
    flycheck-hledger-test-error-standard-line-column
    flycheck-hledger-test-error-standard-line-line
    flycheck-hledger-test-error-standard-line-col-col
    flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers
    flycheck-hledger-test-error-standard-line-windows
    flycheck-hledger-test-error-standard-line-column-windows
    flycheck-hledger-test-error-standard-line-line-windows
    flycheck-hledger-test-error-standard-line-col-col-windows
    flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers-windows))

(ert-deftest flycheck-hledger-test-error-patterns ()
  (let* ((error-patterns (flycheck-checker-get 'hledger 'error-patterns)))
    (dolist (error-symbol flycheck-hledger-test-error-symbols)
      (with-temp-buffer
        (let ((error-object (eval error-symbol)))
          (insert (map-elt error-object :output))
          (unless (flycheck-hledger--check-at-least-one-pattern-matches error-object error-patterns)
            (ert-fail (list
                       error-symbol
                       error-object))))))))

(defun flycheck-hledger--check-at-least-one-pattern-matches (error-object error-patterns)
  "Return non-nil if and only if one of ERROR-PATTERNS matches the current buffer.
The matched text is checked against expected values in ERROR-OBJECT."
  (seq-find
   (apply-partially #'flycheck-hledger--pattern-match-p error-object)
   error-patterns))

(defun flycheck-hledger--pattern-match-p (error-object error-pattern)
  "Return non-nil if and only if ERROR-PATTERN matches the current buffer.
The matched text is checked against expected values in ERROR-OBJECT."
  (goto-char (point-min))
  (when (re-search-forward (car error-pattern) nil t)
    (let* ((expected-file (map-elt error-object :expected-file))
           (expected-line (map-elt error-object :expected-line))
           (expected-end-line (map-elt error-object :expected-end-line))
           (expected-column (map-elt error-object :expected-column))
           (expected-end-column (map-elt error-object :expected-end-column))
           (expected-message (map-elt error-object :expected-message))
           (actual-file (match-string 1))
           (actual-line (match-string 2))
           (actual-end-line (match-string 6))
           (actual-column (match-string 3))
           (actual-end-column (match-string 7))
           (actual-message (match-string 4)))
      (and
       (or (not expected-file) (string= actual-file expected-file))
       (or (not expected-line) (string= actual-line expected-line))
       (or (not expected-end-line) (string= actual-end-line expected-end-line))
       (or (not expected-column) (string= actual-column expected-column))
       (or (not expected-end-column) (string= actual-end-column expected-end-column))
       (or (not expected-message) (string= actual-message expected-message))))))

(provide 'flycheck-hledger-test)
;;; flycheck-hledger-test.el ends here
