Read("chg.g");

#Q := Quiver(4, [[2, 1], [2, 4], [3, 1], [3, 2], [4, 1], [4, 3]]);

#Display(Cohomologies(BoxProduct(Q,Q), 5));
#Display(Cohomologies(StrongProduct(Q,Q), 5));

#Q := Quiver(8, [[1,2], [2,3], [3,4], [4,1], [5,6], [6,n], [7,8], [8,5], [1,5], [2, 8], [3, 7], [4, 6]]);

SetInfoLevel(InfoGlobal, 1);

LogTo("GodHelpMe.txt");

n := 7;
e := [];
for i in [0..n-1] do
    Add(e, [i, (i+1) mod n]);
    Add(e, [i, (i+2) mod n]);
    Add(e, [i, (i+4) mod n]);
    Add(e, [n+i, n+((i+1) mod n)]);
    Add(e, [n+i, n+((i+2) mod n)]);
    Add(e, [n+i, n+((i+4) mod n)]);

    Add(e, [i, 2*n-1-i]);
    Add(e, [2*n-1-i, i]);

    Add(e, [i, (2*n-1-((i-1) mod n))]);
    Add(e, [(2*n-1-((i-1) mod n)), i]);
od;

e := List(e, x -> [x[1]+1, x[2]+1, NewName(x[1]+1, x[2]+1)]);
for edge in e do
    Print(edge[1], " ", edge[2], "\n");
od;
Display("\n");
for edge in e do
    Print("[", edge[1], ", ", edge[2], "],\n");
od;

Display("\n");

Q := Quiver(2*n, e);
Display(Q);
Display(Cohomologies(Q, 6));