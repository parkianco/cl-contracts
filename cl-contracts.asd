;;;; cl-contracts.asd - Smart Contract Lifecycle Management System
;;;;
;;;; Standalone Common Lisp library for Ethereum-compatible smart contract
;;;; management including deployment (CREATE/CREATE2), storage semantics,
;;;; ABI encoding/decoding, and verification.
;;;;
;;;; Pure Common Lisp - No external dependencies.
;;;; Requires SBCL for threading primitives (sb-thread).
;;;;
;;;; Copyright (c) 2025 CLPIC Contributors
;;;; License: BSD-3-Clause

(asdf:defsystem #:cl-contracts
  :name "cl-contracts"
  :version "1.0.0"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :description "Smart contract lifecycle management for Ethereum-compatible blockchains"
  :long-description "Comprehensive smart contract system providing:
  - Deployment (CREATE, CREATE2, factory patterns, proxies)
  - Storage (EVM semantics, layouts, proofs, snapshots)
  - ABI encoding/decoding (full Ethereum ABI specification)
  - Verification (bytecode, source, security scanning)

Pure Common Lisp implementation with no external dependencies.
Designed for SBCL, using sb-thread for concurrency primitives."

  :depends-on ()  ; Pure CL - no external dependencies

  :serial t
  :components
  ((:file "package")
   (:module "src"
    :serial t
    :components
    (;; =====================================================
     ;; Layer 0: Core Utilities
     ;; =====================================================
     (:module "util"
      :serial t
      :components
      ((:file "bytes")
       (:file "hex")
       (:file "hash")
       (:file "rlp")))))))
