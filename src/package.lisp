;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

;;;; cl-contracts/package.lisp - Package definitions for cl-contracts
;;;;
;;;; Defines the main package and sub-packages for the smart contract
;;;; lifecycle management system.
;;;;
;;;; Copyright (c) 2025 CLPIC Contributors
;;;; License: Apache-2.0

(in-package #:cl-user)

;;; ============================================================================
;;; Main Package
;;; ============================================================================

(defpackage #:cl-contracts
  (:use #:cl)
  (:nicknames #:contracts)
  (:documentation
   "Smart contract lifecycle management for Ethereum-compatible blockchains.

    This package provides comprehensive tools for:
    - Contract deployment (CREATE, CREATE2, proxies, factories)
    - EVM storage management (layouts, proofs, snapshots)
    - ABI encoding/decoding (full Ethereum spec)
    - Contract verification and security scanning

    Pure Common Lisp with no external dependencies.")

  (:export
   #:contracts-execute
   #:contracts-context
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-contracts-timing
   #:contracts-batch-process
   #:contracts-health-check;; Module initialization
   #:initialize-contracts-module
   #:shutdown-contracts-module
   #:module-version

   ;; Re-export deployment package symbols
   #:deploy-create
   #:deploy-create2
   #:compute-create-address
   #:compute-create2-address
   #:deploy-proxy
   #:deploy-minimal-proxy
   #:upgrade-proxy

   ;; Re-export storage package symbols
   #:storage-slot
   #:compute-slot
   #:compute-mapping-slot
   #:compute-array-slot
   #:storage-layout
   #:generate-storage-proof
   #:verify-storage-proof

   ;; Re-export ABI package symbols
   #:encode-abi
   #:decode-abi
   #:compute-selector
   #:parse-abi
   #:encode-function-call
   #:decode-function-result

   ;; Re-export verification package symbols
   #:verify-contract
   #:verify-bytecode
   #:scan-security
   #:analyze-gas))

;;; ============================================================================
;;; Deployment Sub-Package
;;; ============================================================================

(defpackage #:cl-contracts.deployment
  (:use #:cl)
  (:nicknames #:contracts.deploy)
  (:documentation
   "Smart contract deployment system.

    Provides CREATE and CREATE2 deployment, deterministic address calculation,
    init code handling, factory patterns, proxy deployment, upgradeable
    contracts, and gas estimation.")

  (:export
   #:contracts-execute
   #:contracts-context
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-contracts-timing
   #:contracts-batch-process
   #:contracts-health-check;; Configuration
   #:*deployment-config*
   #:*default-gas-limit*
   #:*max-initcode-size*
   #:*max-contract-size*

   ;; Core deployment types
   #:deployment-request
   #:make-deployment-request
   #:deployment-result
   #:make-deployment-result
   #:init-code
   #:make-init-code

   ;; CREATE deployment
   #:deploy-create
   #:compute-create-address
   #:simulate-create
   #:estimate-create-gas

   ;; CREATE2 deployment
   #:deploy-create2
   #:compute-create2-address
   #:generate-salt
   #:find-salt-for-address

   ;; Init code handling
   #:build-init-code
   #:analyze-init-code
   #:validate-init-code
   #:extract-runtime-code

   ;; Factory patterns
   #:deploy-via-factory
   #:deploy-clone
   #:clone-bytecode

   ;; Proxy deployment
   #:deploy-proxy
   #:deploy-transparent-proxy
   #:deploy-uups-proxy
   #:deploy-beacon-proxy
   #:deploy-minimal-proxy
   #:deploy-diamond

   ;; Proxy storage slots (EIP-1967)
   #:+implementation-slot+
   #:+admin-slot+
   #:+beacon-slot+

   ;; Upgrades
   #:upgrade-proxy
   #:upgrade-implementation
   #:check-upgrade-safety
   #:compare-storage-layouts

   ;; Gas estimation
   #:estimate-deployment-gas
   #:compute-gas-breakdown

   ;; Validation
   #:validate-deployment
   #:validate-eip-3860

   ;; Conditions
   #:deployment-error
   #:initcode-too-large-error
   #:contract-too-large-error
   #:insufficient-gas-error))

;;; ============================================================================
;;; Storage Sub-Package
;;; ============================================================================

(defpackage #:cl-contracts.storage
  (:use #:cl)
  (:nicknames #:contracts.storage #:evm-storage)
  (:documentation
   "EVM-compatible smart contract storage management.

    Provides complete support for storage slot calculation, mapping/array
    slot derivation, packed storage, transient storage (EIP-1153),
    cold/warm access tracking (EIP-2929), storage diffs, Merkle proofs,
    and snapshot management.")

  (:export
   #:contracts-execute
   #:contracts-context
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-contracts-timing
   #:contracts-batch-process
   #:contracts-health-check;; Configuration
   #:*storage-word-size*
   #:*transient-storage-enabled*
   #:*access-tracking-enabled*

   ;; Storage slot types
   #:storage-slot
   #:make-storage-slot
   #:storage-value
   #:make-storage-value

   ;; Layout types
   #:storage-layout
   #:make-storage-layout
   #:storage-variable
   #:make-storage-variable

   ;; Slot computation
   #:compute-slot
   #:create-slot
   #:slot-index
   #:slot-offset

   ;; Mapping slots
   #:compute-mapping-slot
   #:encode-mapping-key

   ;; Array slots
   #:compute-array-slot
   #:compute-dynamic-array-slot

   ;; Packed storage
   #:pack-variables
   #:unpack-from-slot
   #:get-packed-value

   ;; Transient storage (EIP-1153)
   #:tload
   #:tstore
   #:clear-transient-storage

   ;; Cold/warm access (EIP-2929)
   #:slot-cold-p
   #:slot-warm-p
   #:mark-slot-warm
   #:compute-sload-gas
   #:compute-sstore-gas

   ;; Storage diffs
   #:storage-diff
   #:generate-diff
   #:apply-diff

   ;; Merkle proofs
   #:storage-proof
   #:generate-storage-proof
   #:verify-storage-proof

   ;; Snapshots
   #:storage-snapshot
   #:create-snapshot
   #:revert-to-snapshot

   ;; Conditions
   #:storage-error
   #:slot-not-found-error
   #:proof-verification-error))

;;; ============================================================================
;;; ABI Sub-Package
;;; ============================================================================

(defpackage #:cl-contracts.abi
  (:use #:cl)
  (:nicknames #:contracts.abi #:solidity-abi)
  (:documentation
   "Ethereum ABI encoding and decoding system.

    Full implementation of the Ethereum ABI specification including
    static types, dynamic types, tuples, arrays, function selectors,
    event signatures, packed encoding, multicall, and error decoding.")

  (:export
   #:contracts-execute
   #:contracts-context
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-contracts-timing
   #:contracts-batch-process
   #:contracts-health-check;; Configuration
   #:*abi-strict-mode*
   #:*abi-selector-cache*

   ;; Type definitions
   #:abi-type
   #:make-abi-type
   #:abi-parameter
   #:abi-function
   #:abi-event
   #:abi-error
   #:contract-abi

   ;; Type constructors
   #:make-uint-type
   #:make-int-type
   #:make-address-type
   #:make-bool-type
   #:make-bytes-type
   #:make-string-type
   #:make-array-type
   #:make-tuple-type

   ;; Type predicates
   #:uint-type-p
   #:int-type-p
   #:address-type-p
   #:dynamic-type-p

   ;; Parsing
   #:parse-abi
   #:parse-abi-string
   #:parse-abi-type
   #:validate-abi

   ;; Encoding
   #:encode-abi
   #:encode-function-call
   #:encode-constructor-data
   #:encode-value

   ;; Decoding
   #:decode-abi
   #:decode-function-result
   #:decode-event-data
   #:decode-error

   ;; Function selectors
   #:compute-selector
   #:function-signature
   #:lookup-selector

   ;; Event signatures
   #:compute-event-topic
   #:parse-log

   ;; Packed encoding
   #:encode-packed

   ;; Calldata
   #:build-calldata
   #:parse-calldata

   ;; Multicall
   #:encode-multicall
   #:decode-multicall-result

   ;; Error handling
   #:decode-revert-reason
   #:decode-panic-code

   ;; Conditions
   #:abi-error
   #:abi-encoding-error
   #:abi-decoding-error))

;;; ============================================================================
;;; Verification Sub-Package
;;; ============================================================================

(defpackage #:cl-contracts.verification
  (:use #:cl)
  (:nicknames #:contracts.verify)
  (:documentation
   "Contract verification and security scanning.

    Provides source verification, bytecode analysis, security scanning,
    gas analysis, storage layout verification, and upgrade safety checks.")

  (:export
   #:contracts-execute
   #:contracts-context
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-contracts-timing
   #:contracts-batch-process
   #:contracts-health-check;; Configuration
   #:*verification-config*
   #:*security-rules*

   ;; Verification types
   #:verification-result
   #:make-verification-result
   #:security-finding
   #:gas-report

   ;; Source verification
   #:verify-source
   #:match-source-to-bytecode
   #:extract-metadata

   ;; Bytecode verification
   #:verify-bytecode
   #:compare-bytecode
   #:analyze-bytecode

   ;; Security scanning
   #:scan-security
   #:detect-reentrancy
   #:detect-overflow
   #:detect-selfdestruct
   #:get-security-findings

   ;; Gas analysis
   #:analyze-gas
   #:estimate-function-gas
   #:find-gas-hotspots

   ;; Storage layout
   #:verify-storage-layout
   #:detect-storage-collisions

   ;; Upgrade verification
   #:verify-upgrade-safety
   #:check-storage-compatibility
   #:check-function-compatibility

   ;; Conditions
   #:verification-error
   #:verification-failed-error
   #:security-vulnerability-error))

;;; ============================================================================
;;; Utility Sub-Package
;;; ============================================================================

(defpackage #:cl-contracts.util
  (:use #:cl)
  (:nicknames #:contracts.util)
  (:documentation
   "Utility functions for cl-contracts.

    Provides byte manipulation, hex encoding, hashing, and RLP encoding
    utilities used throughout the system.")

  (:export
   #:contracts-execute
   #:contracts-context
   #:memoize-function
   #:deep-copy-list
   #:group-by-count
   #:identity-list
   #:flatten
   #:map-keys
   #:now-timestamp
#:with-contracts-timing
   #:contracts-batch-process
   #:contracts-health-check;; Byte utilities
   #:bytes-to-hex
   #:hex-to-bytes
   #:concat-bytes
   #:pad-left
   #:pad-right
   #:uint256-to-bytes
   #:bytes-to-uint256

   ;; Hash utilities
   #:keccak256
   #:keccak256-bytes

   ;; RLP encoding
   #:rlp-encode
   #:rlp-decode

   ;; Address utilities
   #:address-to-bytes
   #:bytes-to-address
   #:checksum-address
   #:valid-address-p))
