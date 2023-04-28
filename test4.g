Read("graphdatabase.g");
Read("chg.g");

SetInfoLevel(InfoGlobal, 1);


hn := 5;

count := 0;
while true do
#for i in [1..Length(graph_database)] do
#    for j in [i..Length(graph_database)] do
#        g1 := graph_database[i];
#        g2 := graph_database[j];
        g1 := Random(graph_database);
        g2 := Random(graph_database);
        a := Quiver(g1[1], g1[2]);
        b := Quiver(g2[1], g2[2]);

        Print("Trying:\n", a, "\n", b, "\n");
        Print("Done: ", count, " out of ", Length(graph_database)*(Length(graph_database)-1)/2, "\n");

        cb := Cohomologies(BoxProduct(a, b), hn);
        cs := Cohomologies(StrongProduct(a, b), hn);

        if cs <> cb then
            Display("___________________");
            Display("NO FREAKING WAY!!!!");
            Display("___________________");
            Display(a);
            Display(b);
            Display(cb);
            Display(cs);
            return;
        fi;
        count := count+1;
    #od;
od;
