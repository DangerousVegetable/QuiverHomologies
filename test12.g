Read("mhg.g");
Read("chg.g");
#SetInfoLevel(InfoGlobal, 2);
size := 3;
iterations := 7;
edges := [];;

### C_size \times 0<->1
#for i in [1..size] do 
#        Add(edges, [i, i mod size + 1]);
#        Add(edges, [i mod size + 1, i]);
#        
#        Add(edges, [size + i, size + i mod size + 1]);
#        Add(edges, [size + i mod size + 1, size + i]);
#
#        Add(edges, [i, i+size]);
#        Add(edges, [i+size, i]);
#od;
###

### Moebius-like 
for i in [1..size-1] do 
        Add(edges, [i, i mod size + 1]);
        Add(edges, [i mod size + 1, i]);
        
        Add(edges, [size + i, size + i mod size + 1]);
        Add(edges, [size + i mod size + 1, size + i]);

        Add(edges, [i, i+size]);
        Add(edges, [i+size, i]);
od;
Append(edges, [[size, 2*size], [2*size, size], [size-1, size], [size, size-1], [2*size-1, 2*size], [2*size, 2*size-1], [size, size+1], [size+1, size], [2*size, 1], [1, 2*size]]);
###

#Display(edges);

D := DigraphByEdges(edges, 2*size);

for j in [1..iterations] do
        MH := MagnitudeHomologies(Rationals, D, j+1, j);
        Print(j, ": ", MH, "\n");
od;
