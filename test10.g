Read("mhg.g");
Read("chg.g");
SetInfoLevel(InfoGlobal, 2);
size := 8;
edges := [[1,2], [1,3], [2,4], [2,5], [3,4], [3,5], [4,6], [5,6], [4,7], [5,7], [6,8], [7,8], [1,5], [4,8]];

Q := Quiver(size, edges);
PC := PathCohomologies(Q, 7);

D := DigraphByEdges(edges, size);
MH := MagnitudeHomologies(D, 4, 3);

Display(PC);
Display(MH);
