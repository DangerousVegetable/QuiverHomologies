Read("mhg.g");
Read("chg.g");
#SetInfoLevel(InfoGlobal, 2);
size := 6;
edges := [[1,2], [2,3], [3,4], [4,5], [5,6], [6,1]];

#Q := Quiver(size, edges);
#PC := PathCohomologies(Q, 7);

D := DigraphByEdges(edges, size);

for j in [1..2*size] do
        MH := MagnitudeHomologies(D, j+1, j);
        Print(j, ": ", MH, "\n");
od;

#Display(PC);
