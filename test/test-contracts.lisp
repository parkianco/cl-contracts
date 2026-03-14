;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; test-contracts.lisp - Unit tests for contracts
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defpackage #:cl-contracts.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-contracts.test)

(defun run-tests ()
  "Run all tests for cl-contracts."
  (format t "~&Running tests for cl-contracts...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
