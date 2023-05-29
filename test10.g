Read("chg.g");

SetInfoLevel(InfoGlobal, 1);
Q := Quiver(3,  [[1,2, "a"], [2,3, "b"], [3,1, "c"]]);
Q := Quiver(5, [ [ 3, 1 ], [ 3, 2 ], [ 3, 5 ], [ 4, 1 ], [ 4, 2 ], [ 4, 3 ], [ 5, 1 ], [ 5, 2 ], [ 5, 4 ] ]);
Cohomologies(Q, 4);