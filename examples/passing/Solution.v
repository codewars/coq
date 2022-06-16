Theorem plus_n_O : forall n:nat, n = n + 0.
Proof.
  intros n.
  induction n.
  - reflexivity.
  - simpl. rewrite <- IHn. reflexivity.
Qed.
