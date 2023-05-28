Read("QAC_classes.g");
Read("chg.g");

SetInfoLevel(InfoGlobal, 1);

hn := 4;

#LogTo("cohoms.txt");

success := false;
for i in [1..Length(AC_classes)] do
    for j in [i..Length(AC_classes)] do
        g := AC_classes[i];
        h := AC_classes[j];

        a := Quiver(g[1], g[2]);
        b := Quiver(h[1], h[2]);

        Print("Trying:\n", a, " " , b, "\n");
        c := StrongProduct(a, b);
        
        ch := Cohomologies(c, hn);
        
        if not ch = [1,0,0,0] then 
            Print(a, " ", b, "\n-----------------------\n");
            success := true;
            break;
        fi;
    od;
    if success then 
        Print("NO WAY!!!!\n");
        break;
    fi;
od;