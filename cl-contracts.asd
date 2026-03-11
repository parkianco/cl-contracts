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
  :author "CLPIC Contributors"
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
       (:file "rlp")))

     ;; =====================================================
     ;; Layer 1: Type Definitions
     ;; =====================================================
     (:module "types"
      :serial t
      :components
      ((:file "deployment-types")
       (:file "storage-types")
       (:file "abi-types")
       (:file "verification-types")))

     ;; =====================================================
     ;; Layer 2: Deployment Module
     ;; =====================================================
     (:module "deployment"
      :serial t
      :components
      ((:file "address")
       (:file "create")
       (:file "create2")
       (:file "initcode")
       (:file "factory")
       (:file "proxy")
       (:file "upgrade")
       (:file "gas")
       (:file "validation")))

     ;; =====================================================
     ;; Layer 3: Storage Module
     ;; =====================================================
     (:module "storage"
      :serial t
      :components
      ((:file "layout")
       (:file "slots")
       (:file "mapping")
       (:file "array")
       (:file "packed")
       (:file "transient")
       (:file "cold-warm")
       (:file "diff")
       (:file "proof")
       (:file "snapshot")))

     ;; =====================================================
     ;; Layer 4: ABI Module
     ;; =====================================================
     (:module "abi"
      :serial t
      :components
      ((:file "parser")
       (:file "encoder")
       (:file "decoder")
       (:file "selector")
       (:file "event")
       (:file "dynamic")
       (:file "packed-encoding")
       (:file "calldata")
       (:file "multicall")
       (:file "error-decoding")))

     ;; =====================================================
     ;; Layer 5: Verification Module
     ;; =====================================================
     (:module "verification"
      :serial t
      :components
      ((:file "source-verifier")
       (:file "bytecode-verifier")
       (:file "security-scanner")
       (:file "gas-analyzer")
       (:file "storage-layout")
       (:file "upgrade-verifier")))))))
