;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-contracts.test
  (:use #:cl #:cl-contracts)
  (:export #:run-tests))

(in-package #:cl-contracts.test)

(defun run-tests ()
  (format t "Running professional test suite for cl-contracts...~%")
  (assert (initialize-contracts))
  (format t "Tests passed!~%")
  t)
