;;;; cl-contracts/src/util/hex.lisp - Hexadecimal encoding utilities
;;;;
;;;; Copyright (c) 2025 CLPIC Contributors
;;;; License: BSD-3-Clause

(in-package #:cl-contracts.util)

;;; ============================================================================
;;; Hex Encoding/Decoding
;;; ============================================================================

(defparameter *hex-chars* "0123456789abcdef"
  "Hexadecimal character set (lowercase).")

(defun bytes-to-hex (bytes &key (prefix t))
  "Convert byte vector to hex string. If PREFIX is true, prepend '0x'."
  (let ((hex (make-string (* 2 (length bytes)))))
    (loop for byte across bytes
          for i from 0 by 2
          do (setf (char hex i) (char *hex-chars* (ash byte -4))
                   (char hex (1+ i)) (char *hex-chars* (logand byte #x0f))))
    (if prefix
        (concatenate 'string "0x" hex)
        hex)))

(defun hex-char-value (char)
  "Get numeric value of a hex character."
  (cond
    ((char<= #\0 char #\9) (- (char-code char) (char-code #\0)))
    ((char<= #\a char #\f) (+ 10 (- (char-code char) (char-code #\a))))
    ((char<= #\A char #\F) (+ 10 (- (char-code char) (char-code #\A))))
    (t (error "Invalid hex character: ~A" char))))

(defun hex-to-bytes (hex-string)
  "Convert hex string to byte vector. Handles optional '0x' prefix."
  (let* ((hex (if (and (>= (length hex-string) 2)
                       (string= (subseq hex-string 0 2) "0x"))
                  (subseq hex-string 2)
                  hex-string))
         ;; Handle odd-length hex strings by prepending 0
         (hex (if (oddp (length hex))
                  (concatenate 'string "0" hex)
                  hex))
         (len (/ (length hex) 2))
         (result (make-byte-vector len)))
    (loop for i below len
          for j from 0 by 2
          do (setf (aref result i)
                   (+ (ash (hex-char-value (char hex j)) 4)
                      (hex-char-value (char hex (1+ j))))))
    result))

(defun valid-hex-p (string)
  "Check if STRING is a valid hex string (with optional 0x prefix)."
  (let ((hex (if (and (>= (length string) 2)
                      (string= (subseq string 0 2) "0x"))
                 (subseq string 2)
                 string)))
    (and (> (length hex) 0)
         (every (lambda (c)
                  (or (char<= #\0 c #\9)
                      (char<= #\a c #\f)
                      (char<= #\A c #\F)))
                hex))))

;;; ============================================================================
;;; Address Formatting
;;; ============================================================================

(defun normalize-hex (hex-string &key (bytes 32) (prefix t))
  "Normalize hex string to specified byte length."
  (let* ((bytes-vec (hex-to-bytes hex-string))
         (padded (pad-left bytes-vec bytes)))
    (bytes-to-hex padded :prefix prefix)))

(defun format-address (bytes-or-hex)
  "Format as Ethereum address (20 bytes, 0x-prefixed)."
  (let ((bytes (if (stringp bytes-or-hex)
                   (hex-to-bytes bytes-or-hex)
                   bytes-or-hex)))
    ;; Take last 20 bytes if longer
    (when (> (length bytes) 20)
      (setf bytes (subseq bytes (- (length bytes) 20))))
    (bytes-to-hex (pad-left bytes 20) :prefix t)))

(defun format-bytes32 (bytes-or-hex)
  "Format as 32-byte hex string."
  (let ((bytes (if (stringp bytes-or-hex)
                   (hex-to-bytes bytes-or-hex)
                   bytes-or-hex)))
    (bytes-to-hex (pad-left bytes 32) :prefix t)))
