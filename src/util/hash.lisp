;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-contracts/src/util/hash.lisp - Hash function utilities
;;;;
;;;; Copyright (c) 2025 CLPIC Contributors
;;;; License: BSD-3-Clause

(in-package #:cl-contracts.util)

;;; ============================================================================
;;; Keccak-256 (SHA3-256 variant used by Ethereum)
;;; ============================================================================

;;; This is a minimal pure-CL implementation of Keccak-256.
;;; For production use, consider using a verified implementation.

(defconstant +keccak-256-rate+ 136
  "Rate in bytes for Keccak-256 (1600 - 2*256) / 8 = 136.")

(defconstant +keccak-256-output-bytes+ 32
  "Output size in bytes for Keccak-256.")

(defparameter *keccak-round-constants*
  #(#x0000000000000001 #x0000000000008082 #x800000000000808a
    #x8000000080008000 #x000000000000808b #x0000000080000001
    #x8000000080008081 #x8000000000008009 #x000000000000008a
    #x0000000000000088 #x0000000080008009 #x000000008000000a
    #x000000008000808b #x800000000000008b #x8000000000008089
    #x8000000000008003 #x8000000000008002 #x8000000000000080
    #x000000000000800a #x800000008000000a #x8000000080008081
    #x8000000000008080 #x0000000080000001 #x8000000080008008)
  "Keccak round constants.")

(defparameter *keccak-rotation-offsets*
  #2A((0 36 3 41 18)
      (1 44 10 45 2)
      (62 6 43 15 61)
      (28 55 25 21 56)
      (27 20 39 8 14))
  "Keccak rotation offsets.")

(defun keccak-f-1600 (state)
  "Apply Keccak-f[1600] permutation to STATE (5x5 array of 64-bit words)."
  (let ((c (make-array 5 :element-type '(unsigned-byte 64)))
        (d (make-array 5 :element-type '(unsigned-byte 64)))
        (b (make-array '(5 5) :element-type '(unsigned-byte 64))))
    (dotimes (round 24)
      ;; Theta step
      (dotimes (x 5)
        (setf (aref c x)
              (logxor (aref state x 0) (aref state x 1)
                      (aref state x 2) (aref state x 3) (aref state x 4))))
      (dotimes (x 5)
        (setf (aref d x)
              (logxor (aref c (mod (+ x 4) 5))
                      (ldb (byte 64 0)
                           (logior (ash (aref c (mod (+ x 1) 5)) 1)
                                   (ash (aref c (mod (+ x 1) 5)) -63))))))
      (dotimes (x 5)
        (dotimes (y 5)
          (setf (aref state x y)
                (logxor (aref state x y) (aref d x)))))
      ;; Rho and Pi steps
      (dotimes (x 5)
        (dotimes (y 5)
          (let ((rot (aref *keccak-rotation-offsets* x y)))
            (setf (aref b y (mod (+ (* 2 x) (* 3 y)) 5))
                  (ldb (byte 64 0)
                       (logior (ash (aref state x y) rot)
                               (ash (aref state x y) (- rot 64))))))))
      ;; Chi step
      (dotimes (x 5)
        (dotimes (y 5)
          (setf (aref state x y)
                (logxor (aref b x y)
                        (logandc2 (aref b (mod (+ x 1) 5) y)
                                  (aref b (mod (+ x 2) 5) y))))))
      ;; Iota step
      (setf (aref state 0 0)
            (logxor (aref state 0 0)
                    (aref *keccak-round-constants* round))))
    state))

(defun keccak256 (data)
  "Compute Keccak-256 hash of DATA (byte vector). Returns 32-byte vector."
  (let ((data (if (stringp data)
                  (map '(vector (unsigned-byte 8)) #'char-code data)
                  data))
        (state (make-array '(5 5) :element-type '(unsigned-byte 64)
                                  :initial-element 0))
        (rate-bytes +keccak-256-rate+))
    ;; Pad the data
    (let* ((pad-len (- rate-bytes (mod (1+ (length data)) rate-bytes)))
           (padded (make-byte-vector (+ (length data) 1 pad-len))))
      (replace padded data)
      (setf (aref padded (length data)) #x01)
      (setf (aref padded (1- (length padded)))
            (logior (aref padded (1- (length padded))) #x80))
      ;; Absorb
      (loop for block-start from 0 below (length padded) by rate-bytes
            do (loop for i below (/ rate-bytes 8)
                     for x = (mod i 5)
                     for y = (floor i 5)
                     do (setf (aref state x y)
                              (logxor (aref state x y)
                                      (loop for j below 8
                                            sum (ash (aref padded (+ block-start (* i 8) j))
                                                     (* j 8))))))
               (keccak-f-1600 state)))
    ;; Squeeze
    (let ((result (make-byte-vector +keccak-256-output-bytes+)))
      (loop for i below 4
            for x = (mod i 5)
            for y = (floor i 5)
            do (loop for j below 8
                     do (setf (aref result (+ (* i 8) j))
                              (ldb (byte 8 (* j 8)) (aref state x y)))))
      result)))

(defun keccak256-bytes (bytes)
  "Alias for keccak256 on byte vectors."
  (keccak256 bytes))

(defun keccak256-hex (hex-string)
  "Compute Keccak-256 of hex-encoded data."
  (keccak256 (hex-to-bytes hex-string)))
