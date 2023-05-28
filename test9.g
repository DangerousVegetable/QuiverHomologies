Read("quiverhomotopyclasses6.g");
Read("chg.g");

#SetInfoLevel(InfoGlobal, 2);


hn := 7;

LogTo("acyclic6.txt");

for g in HQ_classes do
    a := Quiver(g[1], g[2]);

    ch := Cohomologies(a, hn);
    if ch = [1,0,0,0,0,0,0] then 
        Print(g, "\n");
    fi;
od;
