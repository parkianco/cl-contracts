;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-contracts)

(define-condition cl-contracts-error (error)
  ((message :initarg :message :reader cl-contracts-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-contracts error: ~A" (cl-contracts-error-message condition)))))
