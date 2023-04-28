Read("chg.g");

#Q := Quiver(4, [[2, 1], [2, 4], [3, 1], [3, 2], [4, 1], [4, 3]]);

#Display(Cohomologies(BoxProduct(Q,Q), 5));
#Display(Cohomologies(StrongProduct(Q,Q), 5));

#Q := Quiver(8, [[1,2], [2,3], [3,4], [4,1], [5,6], [6,7], [7,8], [8,5], [1,5], [2, 8], [3, 7], [4, 6]]);

n := 100;
e := [];
for i in [1..n] do
    Add(e, [i, (i mod n)+1]);
    Add(e, [i+n, (i mod n)+1+n]);
    Add(e, [i, 2*n-i+1]);
od;

Q := Quiver(2*n, e);
Display(Cohomologies(Q, 7));