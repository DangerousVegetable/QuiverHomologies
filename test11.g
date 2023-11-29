Read("chg.g");

SetInfoLevel(InfoGlobal, 2);

n := 5;
e := [[1,4], [4,1], [1,5], [5,1], [2,4], [4,2], [2,5], [5,2], [3,4], [4,3], [3,5], [5,3]];

Q := Quiver(n, e);
Display(PathCohomologies(Rationals, Q, 9));