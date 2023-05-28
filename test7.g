Read("chg.g");

#Q := Quiver(4, [[2, 1], [2, 4], [3, 1], [3, 2], [4, 1], [4, 3]]);

#Display(Cohomologies(BoxProduct(Q,Q), 5));
#Display(Cohomologies(StrongProduct(Q,Q), 5));

#Q := Quiver(8, [[1,2], [2,3], [3,4], [4,1], [5,6], [6,7], [7,8], [8,5], [1,5], [2, 8], [3, 7], [4, 6]]);

SetInfoLevel(InfoGlobal, 1);

n := 6;
e := [];
for i in [0..n-1] do
    Add(e, [i, (i+1) mod n]);
    Add(e, [i, (i-1) mod n]);
    Add(e, [i, (i+2) mod n]);
od;

e := List(e, x -> [x[1]+1, x[2]+1]);
for edge in e do
    Print(edge, ", ");
od;

Display("\n");

Q := Quiver(n, e);
Display(Cohomologies(Q, 5));