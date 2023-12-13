Read("mhg.g");
Read("chg.g");
#SetInfoLevel(InfoGlobal, 2);
size := 5;
#edges := [[1,2], [2,3], [3,4], [4,5], [5,6], [6,1]];
edges := [[1,2], [2,1], [2,3], [3,2], [3,4], [4,3], [4,5], [5,4], [5,1], [1,5]];
#Q := Quiver(size, edges);
#PC := PathCohomologies(Q, 7);

D := DigraphByEdges(edges, size);

for j in [1..2*size] do
        MH := MagnitudeHomologies(GF(2), D, j+1, j);
        Print(j, ": ", MH, "\n");
od;

#Display(PC);
