;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-contracts)

;;; Core types for cl-contracts
(deftype cl-contracts-id () '(unsigned-byte 64))
(deftype cl-contracts-status () '(member :ready :active :error :shutdown))
