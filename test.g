Read("chg.g");

B := Quiver(3,  [[1,2, "a"], [2,1,"A"], [2,3, "b"], [3,2,"B"], [3,1, "c"], [1,3,"C"]]);
Q := Trapez(3);
#Q := Quiver(2, [[1,2]]);
#B := Quiver(3,  [[1,2, "a"], [2,3, "b"], [3,1, "c"]]);
#Q := StrongProduct(B,B);
QS := SemiStrongProduct(Q,B);
Q := QS[1];
dia := QS[2];
n := 7;

#Display(AdjacencyMatrixOfQuiver(Q));

SetInfoLevel(InfoGlobal, 2);
#SetInfoLevel(InfoGBNP, 2);

prev := [];
#prev := Cohomologies(Q, n);
addedDia := [];
#dia := SquareDiagonals(Q);
Display(prev);
Display(dia);

success := false;

for i in [1..Length(dia)] do
    Print("Trying ", i, "-th iteration. ", Length(dia), " left\n");
    j := Random(dia);
    Add(addedDia, j);
    Display(addedDia);
    RemoveSet(dia, j);
    #Add(j, NewName(j[1], j[2]));
    Q := AddEdge(Q, j);
    #Display(Q); 
    new := Cohomologies(Q, n);
    Display(new);
    if new <> prev 
    then
        Display(i);
        Display(Q);
        Display(addedDia);
        success := true;
        break;
    fi;
od;

if success then
    Print("Success! :D\n");
else
    Print("Nothing interesting found :(\n");
fi;