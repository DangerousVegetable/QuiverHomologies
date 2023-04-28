Read("graphdatabase.g");
Read("chg.g");

SetInfoLevel(InfoGlobal, 2);


hn := 7;

while true do 
    g1 := Random(graph_database);
    g2 := Random(graph_database);

    a := Quiver(g1[1], g1[2]);
    b := Quiver(g2[1], g2[2]);

    Print("Trying:\n", a, "\n", b, "\n");

    cs := Cohomologies(StrongProduct(a, b), hn);
    cb := Cohomologies(BoxProduct(a, b), hn);

    if cs <> cb then
        Display("NO FREAKING WAY!!!!");
        Display(a);
        Display(b);
        break;
    fi;
od;


