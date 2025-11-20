;; Token Mortgage Contract (for SIP-010 fungible tokens) 

;; Token transfer calls are left as TODO comments and should be re-enabled when a token contract is available.

;; Import local SIP-010 trait definition
(use-trait ft-trait .sip-010-trait-ft-standard.sip-010-trait)
;; ====================================== 
;; CONSTANTS & ERRORS 
;; ====================================== 
(define-constant ERR-NOT-BORROWER (err u100)) 
(define-constant ERR-NOT-LENDER (err u101)) 
(define-constant ERR-ALREADY-REPAID (err u102)) 
(define-constant ERR-NOT-EXPIRED (err u103)) 
(define-constant ERR-NO-COLLATERAL (err u104)) 
(define-constant ERR-NOT-INITIALIZED (err u105)) 
(define-constant ERR-ALREADY-INITIALIZED (err u106)) 
(define-constant ERR-TRANSFER-FAIL (err u107)) 
(define-constant ERR-ALREADY-LIQUIDATED (err u108))
 
;; ====================================== 
;; CONTRACT STATE 
;; ====================================== 
(define-data-var lender principal 'SP000000000000000000002Q6VF78) 
(define-data-var borrower principal 'SP000000000000000000002Q6VF78) 
(define-data-var collateral-token principal 'SP000000000000000000002Q6VF78.token) 
(define-data-var collateral-amount uint u0) 
(define-data-var loan-amount uint u0) 
(define-data-var interest-rate uint u10) ;; 10% interest 
(define-data-var duration uint u0) 
(define-data-var repaid bool false) 
(define-data-var liquidated bool false) 
(define-data-var repay-amount uint u0) 
(define-data-var active bool false) 
 
;; ====================================== 
;; MORTGAGE INITIALIZATION 
;; ====================================== 
 
(define-public (initialize 
 (init-lender principal) 
 (init-borrower principal) 
 (init-collateral-token principal) 
 (init-collateral-amount uint) 
 (init-loan-amount uint) 
 (init-interest-rate uint) 
 (init-duration uint)) 
 (begin 
 (asserts! (not (var-get active)) ERR-ALREADY-INITIALIZED) 
 (var-set lender init-lender) 
 (var-set borrower init-borrower) 
 (var-set collateral-token init-collateral-token) 
 (var-set collateral-amount init-collateral-amount) 
 (var-set loan-amount init-loan-amount) 
 (var-set interest-rate init-interest-rate) 
 (var-set duration init-duration) 
 (var-set repaid false) 
 (var-set liquidated false) 
 (var-set repay-amount u0) 
 (var-set active true) 
 (ok true) 
 ) 
) 
 
;; ====================================== 
;; DEPOSIT COLLATERAL 
;; ====================================== 
;; The borrower must call this after initialization 
 
(define-public (deposit-collateral) 
 (let 
 ( 
 (coll-token (var-get collateral-token)) 
 (local-collateral-amount (var-get collateral-amount)) 
 (borrower-addr (var-get borrower)) 
 ) 
 (asserts! (is-eq tx-sender borrower-addr) ERR-NOT-BORROWER) 
 ;; replaced invalid '=' operator with valid comparison 'is-eq'
 (asserts! (not (is-eq local-collateral-amount u0)) ERR-NO-COLLATERAL) 
 ;; call the token contract's transfer via contract-call? using the stored principal
 ;; Transfer collateral from borrower to contract
 ;; TODO: call token contract transfer to move collateral from borrower to this contract
 ;; (try! (contract-call? (contract-of ft-trait coll-token) transfer local-collateral-amount tx-sender (as-contract tx-sender)))
 (ok true)
 ) 
) 
 
;; ====================================== 
;; LENDER PROVIDES LOAN 
;; ====================================== 
(define-public (provide-loan) 
 (let 
 ( 
 (lender (var-get lender)) 
 (borrower (var-get borrower)) 
 (loan-amt (var-get loan-amount)) 
 ) 
 (asserts! (is-eq tx-sender lender) ERR-NOT-LENDER) 
 (try! (stx-transfer? loan-amt tx-sender borrower)) 
 (ok true)
 ) 
) 
 
;; ====================================== 
;; REPAY LOAN 
;; ====================================== 
(define-public (repay) 
  (let ((borrower (var-get borrower))
        (lender (var-get lender))
        (loan-amt (var-get loan-amount))
        (interest-rate (var-get interest-rate))
        (already-repaid (var-get repaid))
        (coll-token (var-get collateral-token))
        (local-collateral-amount (var-get collateral-amount)))
    (asserts! (is-eq tx-sender borrower) ERR-NOT-BORROWER)
    (asserts! (not already-repaid) ERR-ALREADY-REPAID)
    (let ((total-repay (+ loan-amt (/ (* loan-amt interest-rate) u100))))
      (begin
        (try! (stx-transfer? total-repay tx-sender lender))
        (var-set repaid true)
        ;; transfer collateral from this contract back to the borrower
  ;; TODO: call token contract transfer to return collateral to borrower
  ;; (try! (contract-call? (contract-of ft-trait coll-token) transfer local-collateral-amount (as-contract tx-sender) borrower))
  (ok true))))) 
;; ====================================== 
;; LIQUIDATE - Lender claims if expired and not repaid 
;; ====================================== 
(define-public (liquidate)
  (let ((already-repaid (var-get repaid))
        (already-liquidated (var-get liquidated))
        (lender (var-get lender)))
    ;; only lender may liquidate when loan not repaid
    (asserts! (is-eq tx-sender lender) ERR-NOT-LENDER)
    (asserts! (not already-repaid) ERR-ALREADY-REPAID)
    (asserts! (not already-liquidated) ERR-ALREADY-LIQUIDATED)
    (var-set liquidated true)
    ;; TODO: transfer collateral to lender via token contract when available
    (ok true)))
 
;; ====================================== 
;; READ-ONLY HELPERS 
;; ====================================== 
 
(define-read-only (get-mortgage-state) 
 { 
 lender: (var-get lender), 
 borrower: (var-get borrower), 
 collateral-token: (var-get collateral-token), 
 collateral-amount: (var-get collateral-amount), 
 loan-amount: (var-get loan-amount), 
 interest-rate: (var-get interest-rate), 
 duration: (var-get duration), 
 start-block: (var-get start-block), 
 repaid: (var-get repaid), 
 liquidated: (var-get liquidated), 
 repay-amount: (var-get repay-amount), 
 active: (var-get active) 
 } 
)

(define-read-only (calculate-repay-amount) 
 (let 
 ( 
 (loan-amt (var-get loan-amount)) 
 (interest-rate (var-get interest-rate)) 
 ) 
 (+ loan-amt (/ (* loan-amt interest-rate) u100)) 
 ) 
)
