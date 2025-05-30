;; Facility Verification Contract
;; Validates consciousness-aware water systems

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-facility-not-found (err u101))
(define-constant err-already-verified (err u102))

(define-map facilities
  { facility-id: uint }
  {
    owner: principal,
    location: (string-ascii 100),
    consciousness-level: uint,
    verified: bool,
    verification-timestamp: uint
  }
)

(define-map facility-counter principal uint)

(define-public (register-facility (location (string-ascii 100)) (consciousness-level uint))
  (let
    (
      (facility-id (+ (default-to u0 (map-get? facility-counter tx-sender)) u1))
    )
    (map-set facility-counter tx-sender facility-id)
    (map-set facilities
      { facility-id: facility-id }
      {
        owner: tx-sender,
        location: location,
        consciousness-level: consciousness-level,
        verified: false,
        verification-timestamp: u0
      }
    )
    (ok facility-id)
  )
)

(define-public (verify-facility (facility-id uint))
  (let
    (
      (facility (unwrap! (map-get? facilities { facility-id: facility-id }) err-facility-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (get verified facility)) err-already-verified)
    (map-set facilities
      { facility-id: facility-id }
      (merge facility {
        verified: true,
        verification-timestamp: block-height
      })
    )
    (ok true)
  )
)

(define-read-only (get-facility (facility-id uint))
  (map-get? facilities { facility-id: facility-id })
)

(define-read-only (is-facility-verified (facility-id uint))
  (match (map-get? facilities { facility-id: facility-id })
    facility (get verified facility)
    false
  )
)
