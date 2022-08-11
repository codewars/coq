Require Solution.
From CW Require Import Loader.

CWGroup "Solution.thm4".
  CWTest "should have the correct type".
    CWAssert Solution.thm4 : (1 = 1).
  CWTest "should be closed under the global context".
    CWAssert Solution.thm4 Assumes.
CWEndGroup.
