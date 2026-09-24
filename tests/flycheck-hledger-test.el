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
    :expected-message "The error message.\n"
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
    :expected-message "The error message.\n"
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
    :expected-message "The error message.\n"
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
    :expected-message "The error message.\n"
    :output "hledger: Error: ./file.ledger:1:10-20:
3 | 2022-01-01
  |     a               1

The error message.
"))

(defconst flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers
  '(
    :expected-file "./file.ledger"
    :expected-line "2"
    :expected-message "Strict account checking is enabled, and
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

(defconst flycheck-hledger-test-error-standard-line-with-context
  '(
    :expected-file "./file.ledger"
    :expected-line "5"
    :expected-message "Ordered dates checking is enabled, and this transaction's
date (2023-12-12) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date."
    :output "hledger: Error: ./file.ledger:5:
1 | 2023-12-14 Payment 2
  |     card             USD -50
  |     expenses          USD 50

5 | 2023-12-12 Payment 1
  | ^^^^^^^^^^
  |     card             USD -25
  |     expenses          USD 25

Ordered dates checking is enabled, and this transaction's
date (2023-12-12) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date."))

(defconst flycheck-hledger-test-compressed-error
  '(
    :expected-file "./file.ledger"
    :expected-line "2"
    :expected-column "13"
    :expected-message "unexpected newline
expecting '+', '-', or number
"
    :output "hledger.exe: Error: ./file.ledger:2:13:
  |
2 |   card  -USD
  |             ^
unexpected newline
expecting '+', '-', or number
"))

(defconst flycheck-hledger-test-error-include-csv
  '(
    :expected-file nil
    :expected-line nil
    :expected-column nil
    :expected-message "sorry, CSV files can't be included yet"
    :output "hledger: Error: sorry, CSV files can't be included yet"))

(defconst flycheck-hledger-test-error-standard-line-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "1"
    :expected-message "The error message.\n"
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
    :expected-message "The error message.\n"
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
    :expected-message "The error message.\n"
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
    :expected-message "The error message.\n"
    :output "hledger: error: C:\\data\\file.ledger:1:10-20:
3 | 2022-01-01
  |     a               1

The error message.
"))

(defconst flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "2"
    :expected-message "Strict account checking is enabled, and
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

(defconst flycheck-hledger-test-error-standard-line-with-context-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "5"
    :expected-message "Ordered dates checking is enabled, and this transaction's
date (2023-12-12) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date."
    :output "hledger.exe: Error: C:\\data\\file.ledger:5:
1 | 2023-12-14 Payment 2
  |     card             USD -50
  |     expenses          USD 50

5 | 2023-12-12 Payment 1
  | ^^^^^^^^^^
  |     card             USD -25
  |     expenses          USD 25

Ordered dates checking is enabled, and this transaction's
date (2023-12-12) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date."))

(defconst flycheck-hledger-test-compressed-error-windows
  '(
    :expected-file "C:\\data\\file.ledger"
    :expected-line "2"
    :expected-column "13"
    :expected-message "unexpected newline
expecting '+', '-', or number
"
    :output "hledger.exe: Error: C:\\data\\file.ledger:2:13:
  |
2 |   card  -USD
  |             ^
unexpected newline
expecting '+', '-', or number
"))

(defconst flycheck-hledger-test-error-ordereddates-hledger1
  '(
    :expected-file "./file.ledger"
    :expected-line "10"
    :expected-message "Ordered dates checking is enabled, and this transaction's
date (2022-01-01) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date.
"
    :output "hledger: Error: ./file.ledger:10:
7 | 2022-01-02 p
  |     (a)                                            1
 
10 | 2022-01-01 p
   | ^^^^^^^^^^
   |     (a)                                            1

Ordered dates checking is enabled, and this transaction's
date (2022-01-01) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date.
"))

(defconst flycheck-hledger-test-error-ordereddates-hledger2
  '(
    :expected-file "./file.ledger"
    :expected-line "10"
    :expected-message "Ordered dates checking is enabled, and this transaction's
date (2022-01-01) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date.
"
    :output "hledger: Error: ./file.ledger:10:
7 | 2022-01-02 p
  |     (a)                                            1

10 | 2022-01-01 p
   | ^^^^^^^^^^
   |     (a)                                            1

Ordered dates checking is enabled, and this transaction's
date (2022-01-01) is out of order with the previous transaction.
Consider moving this entry into date order, or adjusting its date.
"))

(defconst flycheck-hledger-test-error-uniqueleafnames-hledger1
  '(
    :expected-file "./file.ledger"
    :expected-line "12"
    :expected-message "Checking for unique account leaf names is enabled, and
account leaf name \"c\" is not unique.
It appears in these account names, which are used in 2 places:
a:c
b:c

Consider changing these account names so their last parts are different.
"
    :output "hledger: Error: ./file.ledger:12:
  | 2022-01-01 p
9 |     (a:c)                                          1
 ...
   | 2022-01-01 p
12 |     (b:c)                                          1
   |        ^

Checking for unique account leaf names is enabled, and
account leaf name \"c\" is not unique.
It appears in these account names, which are used in 2 places:
a:c
b:c

Consider changing these account names so their last parts are different.
"))

(defconst flycheck-hledger-test-error-uniqueleafnames-hledger2
  '(
    :expected-file "./file.ledger"
    :expected-line "12"
    :expected-message "Checking for unique account leaf names is enabled, and
account leaf name \"c\" is not unique.
It appears in these account names, which are used in 2 places:
a:c
b:c

Consider changing these account names so their last parts are different.
"
    :output "hledger: Error: ./file.ledger:12:
  | 2022-01-01 p
9 |     (a:c)                                          1

   | 2022-01-01 p
12 |     (b:c)                                          1
   |        ^

Checking for unique account leaf names is enabled, and
account leaf name \"c\" is not unique.
It appears in these account names, which are used in 2 places:
a:c
b:c

Consider changing these account names so their last parts are different.
"))

(defconst flycheck-hledger-test-error-lots-hledger2
  '(
    :expected-file "./file.ledger"
    :expected-line "8"
    :expected-message "Postings were read as: dispose, unclassified.
Insufficient lots for commodity AAPL in account assets:stocks: need 15 but only 10 available
Lots matching {$50}:
  {2022-01-01, $50}  10
  Total: 10 AAPL
"
    :output "hledger: Error: ./file.ledger:8:
  | 2022-02-01 sell
8 |     assets:stocks                                -15 AAPL {$50} @ $55
  |     assets:checking                             $825

Postings were read as: dispose, unclassified.
Insufficient lots for commodity AAPL in account assets:stocks: need 15 but only 10 available
Lots matching {$50}:
  {2022-01-01, $50}  10
  Total: 10 AAPL
"))

(defconst flycheck-hledger-test-error-multiline-no-position
  '(
    :expected-file nil
    :expected-line nil
    :expected-column nil
    :expected-message "in CSV rules:
record: 2022-01-03,1,2
  %1   2022-01-03
  %2   1
  %3   2
while calculating amount for posting 1
rule \"amount-in %2\" assigned value \"1\"       (./file.csv.rules:3)
rule \"amount-out %3\" assigned value \"2\"      (./file.csv.rules:4)

Multiple non-zero amounts were assigned for an amount field.
Please ensure just one non-zero amount is assigned, perhaps with an if rule.
"
    :output "hledger: Error: in CSV rules:
record: 2022-01-03,1,2
  %1   2022-01-03
  %2   1
  %3   2
while calculating amount for posting 1
rule \"amount-in %2\" assigned value \"1\"       (./file.csv.rules:3)
rule \"amount-out %3\" assigned value \"2\"      (./file.csv.rules:4)

Multiple non-zero amounts were assigned for an amount field.
Please ensure just one non-zero amount is assigned, perhaps with an if rule.
"))

(defconst flycheck-hledger-test-error-symbols
  '(flycheck-hledger-test-error-standard-line
    flycheck-hledger-test-error-standard-line-column
    flycheck-hledger-test-error-standard-line-line
    flycheck-hledger-test-error-standard-line-col-col
    flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers
    flycheck-hledger-test-compressed-error
    flycheck-hledger-test-error-include-csv
    flycheck-hledger-test-error-standard-line-with-context
    flycheck-hledger-test-error-standard-line-windows
    flycheck-hledger-test-error-standard-line-column-windows
    flycheck-hledger-test-error-standard-line-line-windows
    flycheck-hledger-test-error-standard-line-col-col-windows
    flycheck-hledger-test-error-excerpt-with-shuffled-line-numbers-windows
    flycheck-hledger-test-error-standard-line-with-context-windows
    flycheck-hledger-test-compressed-error-windows
    flycheck-hledger-test-error-ordereddates-hledger1
    flycheck-hledger-test-error-ordereddates-hledger2
    flycheck-hledger-test-error-uniqueleafnames-hledger1
    flycheck-hledger-test-error-uniqueleafnames-hledger2
    flycheck-hledger-test-error-lots-hledger2
    flycheck-hledger-test-error-multiline-no-position))

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
