;;;; cl-contracts/src/util/bytes.lisp - Byte manipulation utilities
;;;;
;;;; Copyright (c) 2025 CLPIC Contributors
;;;; License: BSD-3-Clause

(in-package #:cl-contracts.util)

;;; ============================================================================
;;; Byte Vector Operations
;;; ============================================================================

(deftype byte-vector ()
  "A vector of unsigned bytes."
  '(simple-array (unsigned-byte 8) (*)))

(defun make-byte-vector (size &key (initial-element 0))
  "Create a new byte vector of SIZE bytes."
  (make-array size :element-type '(unsigned-byte 8)
                   :initial-element initial-element))

(defun concat-bytes (&rest byte-vectors)
  "Concatenate multiple byte vectors into one."
  (let* ((total-length (reduce #'+ byte-vectors :key #'length))
         (result (make-byte-vector total-length))
         (offset 0))
    (dolist (bv byte-vectors result)
      (replace result bv :start1 offset)
      (incf offset (length bv)))))

(defun bytes-equal (a b)
  "Check if two byte vectors are equal."
  (and (= (length a) (length b))
       (every #'= a b)))

(defun copy-bytes (source &key (start 0) end)
  "Copy bytes from SOURCE, optionally with START and END bounds."
  (let* ((end (or end (length source)))
         (result (make-byte-vector (- end start))))
    (replace result source :start2 start :end2 end)
    result))

;;; ============================================================================
;;; Padding Operations
;;; ============================================================================

(defun pad-left (bytes target-length &key (pad-byte 0))
  "Pad BYTES on the left to reach TARGET-LENGTH."
  (let ((current-length (length bytes)))
    (if (>= current-length target-length)
        bytes
        (let ((result (make-byte-vector target-length :initial-element pad-byte)))
          (replace result bytes :start1 (- target-length current-length))
          result))))

(defun pad-right (bytes target-length &key (pad-byte 0))
  "Pad BYTES on the right to reach TARGET-LENGTH."
  (let ((current-length (length bytes)))
    (if (>= current-length target-length)
        bytes
        (let ((result (make-byte-vector target-length :initial-element pad-byte)))
          (replace result bytes)
          result))))

(defun pad-to-word (bytes)
  "Pad bytes to 32-byte word boundary (EVM word size)."
  (let ((len (length bytes)))
    (if (zerop (mod len 32))
        bytes
        (pad-right bytes (* 32 (ceiling len 32))))))

;;; ============================================================================
;;; Integer Conversion
;;; ============================================================================

(defun uint256-to-bytes (n)
  "Convert unsigned 256-bit integer N to 32-byte big-endian representation."
  (let ((result (make-byte-vector 32)))
    (loop for i from 31 downto 0
          for byte-index from 0
          do (setf (aref result byte-index)
                   (ldb (byte 8 (* i 8)) n)))
    result))

(defun bytes-to-uint256 (bytes)
  "Convert big-endian byte vector to unsigned 256-bit integer."
  (let ((padded (pad-left bytes 32)))
    (loop for byte across padded
          for result = byte then (+ (ash result 8) byte)
          finally (return result))))

(defun uint64-to-bytes (n)
  "Convert unsigned 64-bit integer to 8-byte big-endian representation."
  (let ((result (make-byte-vector 8)))
    (loop for i from 7 downto 0
          for byte-index from 0
          do (setf (aref result byte-index)
                   (ldb (byte 8 (* i 8)) n)))
    result))

(defun bytes-to-uint64 (bytes)
  "Convert big-endian byte vector to unsigned 64-bit integer."
  (let ((padded (pad-left bytes 8)))
    (loop for byte across padded
          for result = byte then (+ (ash result 8) byte)
          finally (return result))))

;;; ============================================================================
;;; Bit Operations
;;; ============================================================================

(defun xor-bytes (a b)
  "XOR two byte vectors element-wise. Both must have same length."
  (assert (= (length a) (length b)))
  (let ((result (make-byte-vector (length a))))
    (loop for i below (length a)
          do (setf (aref result i)
                   (logxor (aref a i) (aref b i))))
    result))

(defun not-bytes (bytes)
  "Bitwise NOT of all bytes."
  (let ((result (make-byte-vector (length bytes))))
    (loop for i below (length bytes)
          do (setf (aref result i)
                   (logand #xff (lognot (aref bytes i)))))
    result))
