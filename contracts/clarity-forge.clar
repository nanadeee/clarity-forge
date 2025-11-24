;; -----------------------------------------------------------
;; Contract: clarity-forge.clar
;; Purpose:  Modular on-chain Clarity contract factory
;; Author:   nana
;; -----------------------------------------------------------

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-MODULE-NOT-FOUND (err u101))
(define-constant ERR-NAME-TAKEN (err u102))

(define-data-var admin principal tx-sender)
(define-data-var module-counter uint u0)
(define-data-var contract-counter uint u0)

;; -----------------------------------------------------------
;; MAPS
;; -----------------------------------------------------------

(define-map modules
  { id: uint }
  {
    name: (buff 40),
    code-hash: (buff 64),
    active: bool
  }
)

(define-map deployed-contracts
  { id: uint }
  {
    deployer: principal,
    module-id: uint,
    label: (buff 40),
    deployed-at: uint
  }
)

;; -----------------------------------------------------------
;; EVENTS (printed to event logs)
;; -----------------------------------------------------------

;; -----------------------------------------------------------
;; ADMIN FUNCTIONS
;; -----------------------------------------------------------

(define-public (register-module (name (buff 40)) (code-hash (buff 64)))
  (if (is-eq tx-sender (var-get admin))
      (let ((id (+ (var-get module-counter) u1)))
        (match (as-max-len? name u40)
          name-checked
          (match (as-max-len? code-hash u64)
            hash-checked
            (begin
              (map-set modules { id: id } { 
                name: name-checked, 
                code-hash: hash-checked, 
                active: true 
              })
              (var-set module-counter id)
              (ok id)
            )
            (err u103)
          )
          (err u103)
        )
      )
      ERR-NOT-AUTHORIZED
  )
)

(define-public (deactivate-module (id uint))
  (if (is-eq tx-sender (var-get admin))
      (match (map-get? modules { id: id })
        mod
        (begin
          (map-set modules { id: id } { 
            name: (unwrap-panic (as-max-len? (get name mod) u40)), 
            code-hash: (unwrap-panic (as-max-len? (get code-hash mod) u64)), 
            active: false 
          })
          (ok true)
        )
        ERR-MODULE-NOT-FOUND
      )
      ERR-NOT-AUTHORIZED
  )
)

;; -----------------------------------------------------------
;; CORE FUNCTION: DEPLOY CONTRACT
;; -----------------------------------------------------------

(define-public (deploy-from-module (module-id uint) (label (buff 40)))
  (if (> (len label) u0)
    (let ((module (map-get? modules { id: module-id })))
      (match module mod
        (if (not (get active mod))
            ERR-MODULE-NOT-FOUND
            (let ((id (+ (var-get contract-counter) u1)))
              (begin
                ;; In a real setup, deployment would involve contract-call! to a known deployer
                (map-set deployed-contracts { id: id } {
                  deployer: tx-sender,
                  module-id: module-id,
                  label: (unwrap-panic (as-max-len? label u40)),
                  deployed-at: u0
                })
                (var-set contract-counter id)
                (print { event: "contract-deployed", id: id, deployer: tx-sender, module: module-id, label: label })
                (ok id)
              )
            )
        )
        ERR-MODULE-NOT-FOUND
      )
    )
    (err u104)
  )
)

;; -----------------------------------------------------------
;; READ-ONLY FUNCTIONS
;; -----------------------------------------------------------

(define-read-only (get-module (id uint))
  (default-to
    { name: 0x, code-hash: 0x, active: false }
    (map-get? modules { id: id })
  )
)

(define-read-only (list-modules)
  u0
)

(define-read-only (get-deployed (id uint))
  (default-to
    { deployer: tx-sender, module-id: u0, label: 0x, deployed-at: u0 }
    (map-get? deployed-contracts { id: id })
  )
)

(define-read-only (list-deployments)
  u0
)
