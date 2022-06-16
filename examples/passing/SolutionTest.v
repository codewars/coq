Require Import Solution.
Theorem plus_n_O_check : forall n:nat, n = n + 0.
Proof.
  exact plus_n_O.
  Print Assumptions plus_n_O.
Qed.
