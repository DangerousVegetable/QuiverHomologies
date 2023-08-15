Read("chg.g");

SetInfoLevel(InfoGlobal, 2);

n := 7;
e := [];
for i in [0..n-1] do
    Add(e, [i, (i+1) mod n]);
    Add(e, [i, (i+2) mod n]);
    Add(e, [i, (i+4) mod n]);
od;

e := List(e, x -> [x[1]+1, x[2]+1]);
for edge in e do
    Print(edge, ", ");
od;

Display("\n");

Q := Quiver(n, e);
Display(PathCohomologies(GF(2), Q, 5));