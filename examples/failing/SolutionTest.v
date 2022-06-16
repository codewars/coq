Require Import Solution.

Theorem thm1 : 1 = 1 + 0. Proof. admit. Admitted.
Print Assumptions thm1.

Parameter thm2 : 1 + 0 = 0 + 1.
Print Assumptions thm2.

Theorem thm3 : 1 = 0 + 1. Proof. rewrite <- thm2. exact thm1. Qed.
Print Assumptions thm3.

Theorem thm4_check : 1 = 1.
Proof.
  exact thm4.
  Print Assumptions thm4.
Qed.
