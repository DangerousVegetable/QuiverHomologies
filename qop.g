LoadPackage("qpa");

NewName := function(u, v)
    return Concatenation("", String(u), "_", String(v), "");
end;

BoxProduct := function(q1, q2)
    local u, v, vq1, vq2, vert, edges, o;

    vq1 := VerticesOfQuiver(q1);
    vq2 := VerticesOfQuiver(q2);

    vert := []; 
    edges := [];
    for u in vq1 do
        for v in vq2 do
            Add(vert, NewName(u, v));

            for o in OutgoingArrowsOfVertex(u) do
                Add(edges, [NewName(u,v), NewName(TargetOfPath(o),v), NewName(o, v)]);
            od;

            for o in OutgoingArrowsOfVertex(v) do
                Add(edges, [NewName(u,v), NewName(u, TargetOfPath(o)), NewName(u, o)]);
            od;
        od;
    od;
    
    return Quiver(vert, edges);
end;

StrongProduct := function(q1, q2)
    local u, v, vq1, vq2, vert, edges, o, e;

    vq1 := VerticesOfQuiver(q1);
    vq2 := VerticesOfQuiver(q2);

    vert := []; 
    edges := [];
    for u in vq1 do
        for v in vq2 do
            Add(vert, NewName(u,v));

            for o in OutgoingArrowsOfVertex(u) do
                for e in OutgoingArrowsOfVertex(v) do
                    Add(edges, [NewName(u,v), NewName(TargetOfPath(o),TargetOfPath(e)), NewName(o, e)]);
                od;
            od;

            for o in OutgoingArrowsOfVertex(u) do
                Add(edges, [NewName(u,v), NewName(TargetOfPath(o),v), NewName(o, v)]);
            od;

            for o in OutgoingArrowsOfVertex(v) do
                Add(edges, [NewName(u,v), NewName(u, TargetOfPath(o)), NewName(u, o)]);
            od;
        od;
    od;
    
    return Quiver(vert, edges);
end;

SemiStrongProduct := function(q1, q2)
    local u, v, vq1, vq2, vert, edges, o, e, dia;

    vq1 := VerticesOfQuiver(q1);
    vq2 := VerticesOfQuiver(q2);

    vert := []; 
    edges := [];

    dia := Set([]);
    for u in vq1 do
        for v in vq2 do
            Add(vert, NewName(u,v));

            for o in OutgoingArrowsOfVertex(u) do
                for e in OutgoingArrowsOfVertex(v) do
                    AddSet(dia, [NewName(u,v), NewName(TargetOfPath(o),TargetOfPath(e))]);
                od;
            od;

            for o in OutgoingArrowsOfVertex(u) do
                Add(edges, [NewName(u,v), NewName(TargetOfPath(o),v), NewName(o, v)]);
            od;

            for o in OutgoingArrowsOfVertex(v) do
                Add(edges, [NewName(u,v), NewName(u, TargetOfPath(o)), NewName(u, o)]);
            od;
        od;
    od;
    
    return [Quiver(vert, edges), dia];
end;

Join := function(q1, q2)
    local u, v, vq1, vq2, vert, edges, o, e;

    vq1 := VerticesOfQuiver(q1);
    vq2 := VerticesOfQuiver(q2);

    vert := []; 
    edges := [];
    for u in vq1 do
        Add(vert, NewName(1, u));
        for o in OutgoingArrowsOfVertex(u) do
            Add(edges, [NewName(1,u), NewName(1, TargetOfPath(o)), NewName(1, o)]);
        od;
    od;

    for v in vq2 do
        Add(vert, NewName(2, v));
        for o in OutgoingArrowsOfVertex(v) do
            Add(edges, [NewName(2,v), NewName(2, TargetOfPath(o)), NewName(2, o)]);
        od;
    od;

    for u in vq1 do
        for v in vq2 do
            Add(edges, [NewName(1, u), NewName(2, v), NewName(u, v)]);
        od;
    od;
    
    return Quiver(vert, edges);
end;

Trapez := function(k)
    local vertices, edges, i;
    vertices := ["a", "d"];
    edges := [];
    for i in [1..k] do
        Add(vertices, Concatenation("b", String(i)));
        Add(vertices, Concatenation("c", String(i)));
        Add(edges, ["a", Concatenation("b", String(i)), Concatenation("e", String(i))]);
        #Add(edges, [Concatenation("b", String(i)), Concatenation("b", String((i mod k) + 1)), Concatenation("f", String(i))]);
        Add(edges, [Concatenation("b", String(i)), Concatenation("c", String(i)), Concatenation("g", String(i))]);
        Add(edges, [Concatenation("b", String(i)), Concatenation("c", String((i mod k) + 1)), Concatenation("h", String(i))]);
        Add(edges, [Concatenation("c", String(i)), "d", Concatenation("i", String(i))]);
    od;

    return Quiver(vertices, edges);
end;

QuiverCycle := function(k)
    local vertices, edges, i;
    vertices := k;
    edges := [];
    for i in [1..k] do
        Add(edges, [i, (i mod k)+1]);
    od;

    return Quiver(vertices, edges);
end;

Diagonals := function(Q)
    local u, diag, a, b, k, l;
    diag := Set([]);
    for u in VerticesOfQuiver(Q) do
        for a in IncomingArrowsOfVertex(u) do
            for b in OutgoingArrowsOfVertex(u) do
                k := SourceOfPath(a);
                l := TargetOfPath(b);
                if not l in NeighborsOfVertex(k)
                then
                    AddSet(diag, [k, l]);
                fi;
            od;
        od;
    od;

    return diag;
end;

SquareDiagonals := function(Q)
    local u, diag, a, b, k, l, num, i, count, idiag, ans;
    diag := Diagonals(Q);
    if Length(diag) = 0 then
        return [];
    fi;
    idiag := NewDictionary(diag[1], true);
    for i in [1..Length(diag)] do
        AddDictionary(idiag, diag[i], i);
    od;
    count := List([1..Length(diag)], x -> 0);

    for u in VerticesOfQuiver(Q) do
        for a in IncomingArrowsOfVertex(u) do
            for b in OutgoingArrowsOfVertex(u) do
                k := SourceOfPath(a);
                l := TargetOfPath(b);
                if not l in NeighborsOfVertex(k)
                then
                    i := LookupDictionary(idiag, [k,l]);
                    count[i] := count[i] + 1;
                fi;
            od;
        od;
    od;

    #Display(diag);
    #Display(count);

    ans := [];
    for i in [1..Length(diag)] do
        if count[i] = 2 then
            Add(ans, diag[i]);
        fi;
    od;
    #Display(ans);
    return ans;
end;

AddEdge := function(Q, e)
    local l;
    if Length(e) = 2 then
        l := List(ArrowsOfQuiver(Q), x -> [String(SourceOfPath(x)), String(TargetOfPath(x))]);
        #Display(l);
        Add(l, [String(e[1]), String(e[2])]);
        #Display(l);
        return Quiver(List(VerticesOfQuiver(Q), String), l);
    else
        l := List(ArrowsOfQuiver(Q), x -> [String(SourceOfPath(x)), String(TargetOfPath(x)), String(x)]);
        #Display(l);
        Add(l, [String(e[1]), String(e[2]), e[3]]);
        #Display(l);
        return Quiver(List(VerticesOfQuiver(Q), String), l);
    fi;  
end;

AddVertex := function(Q, v)
    local l;
    l := List(VerticesOfQuiver(Q), String);
    Add(l, v);

    #Display(l);
    #Display(l);
    return Quiver(l, List(ArrowsOfQuiver(Q), x -> [String(SourceOfPath(x)), String(TargetOfPath(x))]));
end;