# cl-contracts

Smart Contract Lifecycle Management for Common Lisp

## Overview

cl-contracts provides comprehensive tools for Ethereum-compatible smart contract management:

- **Deployment**: CREATE, CREATE2, factory patterns, proxy contracts
- **Storage**: EVM storage semantics, layouts, proofs, snapshots
- **ABI**: Full Ethereum ABI encoding/decoding specification
- **Verification**: Bytecode verification, security scanning, gas analysis

Pure Common Lisp implementation with **no external dependencies**. Requires SBCL.

## Installation

```lisp
;; Clone to your ASDF source registry
(asdf:load-system :cl-contracts)
```

## Quick Start

```lisp
(use-package :cl-contracts)

;; Compute CREATE2 address
(compute-create2-address deployer salt init-code-hash)

;; Encode a function call
(encode-function-call "transfer(address,uint256)"
                      '("0x..." 1000000000000000000))

;; Verify contract bytecode
(verify-bytecode deployed-bytecode expected-bytecode)
```

## Modules

### Deployment (`cl-contracts.deployment`)

```lisp
;; CREATE deployment
(deploy-create bytecode constructor-args)

;; CREATE2 with deterministic address
(let ((address (compute-create2-address deployer salt init-hash)))
  (deploy-create2 bytecode salt))

;; Minimal proxy (EIP-1167)
(deploy-minimal-proxy implementation-address)

;; UUPS proxy
(deploy-uups-proxy implementation-address init-data)
```

### Storage (`cl-contracts.storage`)

```lisp
;; Compute mapping slot
(compute-mapping-slot base-slot key)

;; Generate Merkle proof
(generate-storage-proof account slot state-root)

;; Transient storage (EIP-1153)
(tstore slot value)
(tload slot)
```

### ABI (`cl-contracts.abi`)

```lisp
;; Parse contract ABI
(parse-abi abi-json-string)

;; Encode function call
(encode-function-call "approve(address,uint256)"
                      (list spender-address amount))

;; Decode return data
(decode-function-result "balanceOf(address)" return-bytes)

;; Compute selector
(compute-selector "transfer(address,uint256)")
;; => #(#xa9 #x05 #x9c #xbb)
```

### Verification (`cl-contracts.verification`)

```lisp
;; Security scan
(scan-security bytecode)
;; => (:findings ((:type :reentrancy :severity :high :location 42)))

;; Gas analysis
(analyze-gas bytecode)
;; => (:total-gas 21000 :hotspots (...))
```

## Standards Compliance

- EIP-1014: Skinny CREATE2
- EIP-1153: Transient storage (TLOAD/TSTORE)
- EIP-1167: Minimal Proxy Contract
- EIP-1967: Standard Proxy Storage Slots
- EIP-2535: Diamond Standard
- EIP-2929: Cold/warm access costs
- EIP-3860: Initcode size limits
- ERC-1822: UUPS Proxy Standard
- Full Ethereum ABI Specification

## License

BSD-3-Clause. See [LICENSE](LICENSE).

## Origin

Extracted from [CLPIC](https://github.com/clpic/clpic) - Common Lisp P2P Intellectual Property Chain.
