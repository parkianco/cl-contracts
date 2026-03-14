;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-contracts/src/util/rlp.lisp - RLP encoding/decoding
;;;;
;;;; Recursive Length Prefix encoding as specified in the Ethereum Yellow Paper.
;;;;
;;;; Copyright (c) 2025 CLPIC Contributors
;;;; License: BSD-3-Clause

(in-package #:cl-contracts.util)

;;; ============================================================================
;;; RLP Encoding
;;; ============================================================================

(defun rlp-encode-length (len offset)
  "Encode length for RLP. OFFSET is 128 for strings, 192 for lists."
  (cond
    ((< len 56)
     (make-array 1 :element-type '(unsigned-byte 8)
                   :initial-element (+ offset len)))
    ((< len (expt 2 64))
     (let* ((len-bytes (loop for n = len then (ash n -8)
                             while (> n 0)
                             collect (logand n #xff)))
            (len-len (length len-bytes)))
       (concatenate '(vector (unsigned-byte 8))
                    (vector (+ offset 55 len-len))
                    (coerce (reverse len-bytes) '(vector (unsigned-byte 8))))))
    (t (error "RLP: length too large: ~A" len))))

(defun rlp-encode (item)
  "RLP-encode an item. ITEM can be:
   - byte vector (encoded as string)
   - integer (converted to minimal byte representation)
   - string (converted to bytes)
   - list (encoded as RLP list)"
  (cond
    ;; Byte vector cases
    ((typep item '(vector (unsigned-byte 8)))
     (let ((len (length item)))
       (cond
         ;; Empty byte vector
         ((zerop len)
          (make-array 1 :element-type '(unsigned-byte 8) :initial-element #x80))
         ;; Single byte 0-127
         ((and (= len 1) (< (aref item 0) 128))
          item)
         ;; General byte vector
         (t (concat-bytes (rlp-encode-length len 128) item)))))

    ;; Integer
    ((integerp item)
     (if (zerop item)
         (make-array 1 :element-type '(unsigned-byte 8) :initial-element #x80)
         (let ((bytes (loop for n = item then (ash n -8)
                            while (> n 0)
                            collect (logand n #xff))))
           (rlp-encode (coerce (reverse bytes) '(vector (unsigned-byte 8)))))))

    ;; String
    ((stringp item)
     (rlp-encode (map '(vector (unsigned-byte 8)) #'char-code item)))

    ;; List
    ((listp item)
     (let* ((encoded-items (mapcar #'rlp-encode item))
            (payload (apply #'concat-bytes encoded-items))
            (len (length payload)))
       (concat-bytes (rlp-encode-length len 192) payload)))

    (t (error "RLP: unsupported type ~A" (type-of item)))))

;;; ============================================================================
;;; RLP Decoding
;;; ============================================================================

(defun rlp-decode-length (bytes offset)
  "Decode RLP length prefix starting at OFFSET. Returns (length, header-size)."
  (let ((prefix (aref bytes offset)))
    (cond
      ;; Single byte
      ((< prefix 128)
       (values 1 0))
      ;; Short string (0-55 bytes)
      ((< prefix 184)
       (values (- prefix 128) 1))
      ;; Long string
      ((< prefix 192)
       (let* ((len-len (- prefix 183))
              (len (loop for i from 1 to len-len
                         for byte = (aref bytes (+ offset i))
                         for acc = byte then (+ (ash acc 8) byte)
                         finally (return acc))))
         (values len (1+ len-len))))
      ;; Short list (0-55 bytes total)
      ((< prefix 248)
       (values (- prefix 192) 1))
      ;; Long list
      (t
       (let* ((len-len (- prefix 247))
              (len (loop for i from 1 to len-len
                         for byte = (aref bytes (+ offset i))
                         for acc = byte then (+ (ash acc 8) byte)
                         finally (return acc))))
         (values len (1+ len-len)))))))

(defun rlp-decode (bytes &optional (offset 0))
  "RLP-decode BYTES starting at OFFSET. Returns (decoded-item, bytes-consumed)."
  (when (>= offset (length bytes))
    (return-from rlp-decode (values nil 0)))

  (let ((prefix (aref bytes offset)))
    (cond
      ;; Single byte 0-127
      ((< prefix 128)
       (values (subseq bytes offset (1+ offset)) 1))

      ;; String (short or long)
      ((< prefix 192)
       (multiple-value-bind (len header-size) (rlp-decode-length bytes offset)
         (let ((start (+ offset header-size))
               (total (+ header-size len)))
           (if (zerop len)
               (values (make-byte-vector 0) total)
               (values (subseq bytes start (+ start len)) total)))))

      ;; List (short or long)
      (t
       (multiple-value-bind (len header-size) (rlp-decode-length bytes offset)
         (let ((list-start (+ offset header-size))
               (list-end (+ offset header-size len))
               (items nil)
               (pos (+ offset header-size)))
           (loop while (< pos list-end)
                 do (multiple-value-bind (item consumed)
                        (rlp-decode bytes pos)
                      (push item items)
                      (incf pos consumed)))
           (values (nreverse items) (+ header-size len))))))))

(defun rlp-decode-all (bytes)
  "Fully decode RLP bytes, returning just the decoded value."
  (multiple-value-bind (item consumed) (rlp-decode bytes)
    (declare (ignore consumed))
    item))
