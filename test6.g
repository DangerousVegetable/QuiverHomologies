Read("quiverhomotopyclasses6.g");
Read("chg.g");

#SetInfoLevel(InfoGlobal, 2);


hn := 7;

LogTo("cohoms.txt");

chTypes := Set([]);

count := 1;
for g in HQ_classes do
    a := Quiver(g[1], g[2]);

    #Print("Trying:\n", a, "\n");

    ch := Cohomologies(a, hn);
    
    AddSet(chTypes, ch);

    Print(count, ")\t", ch, ":\n");
    for e in g[2] do
        Print(e[1]-1, " ", e[2]-1, "\n");
    od;
    Print("\n");
    count := count+1;
od;

Print(chTypes);
