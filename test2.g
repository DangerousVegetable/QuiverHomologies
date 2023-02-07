Read("chg.g");

#success := false;
#for i in [3..10] do
#    if success then break; fi;
#    for j in [i..10] do
#        Q1 := QuiverCycle(i);
#        Q2 := QuiverCycle(j);
#        Q := StrongProduct(Q1, Q2);
#        cb := Cohomologies(BoxProduct(Q1, Q2), 7);
#        cs := Cohomologies(Q, 7);
#        Print(i, " ", j, ":\n", cb, "\n", cs, "\n");
#        if cb <> cs then 
#            Print("NO WAY!!!!!!");
#            break;
#            success := true;
#        fi;
#    od;
#od;


Q := Quiver(["v0", "v1", "v2", "v3", "v1'", "v2'", "v3'", "A", "B"], 
   [["v0", "v1"], ["v0", "v3"], ["v0", "A"], ["v0", "B"],
   ["v1", "v1'"], ["v2", "v2'"], ["v3", "v3'"],
   ["v3", "v2"], ["v1", "v2"],
   ["v3'", "v2'"], ["v1'", "v2'"],
   ["B", "v3'"], ["B", "v2'"],
   ["A", "v1'"], ["A", "v2'"]]); 

#R := Trapez(4);

for i in [3..10] do
   cs := Cohomologies(StrongProduct(Q, QuiverCycle(i)), 7);
   cb := Cohomologies(BoxProduct(Q, QuiverCycle(i)), 7);

   Print(i, ": ", cs, "\n");
   if cb <> cs then
      break;
   fi;
od;