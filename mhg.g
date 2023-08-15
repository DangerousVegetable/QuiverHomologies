LoadPackage("digraphs");

MagnitudeHomologies := function(F, D, N, L)
    local size, distmat, totalDist, allSeq, i, j, seq, isRegular, getIndex, diff, ranks, Ker, Img, Hom, matrix, w, coeff;
    distmat := DigraphShortestDistances(D);

    N := N+1;
    size := Length(DigraphVertices(D));

    Info(InfoGlobal, 2, "distmat: ", distmat);

    totalDist := function(l)
        local add, copyl;
        add := function(a, b)
            if a[2] = fail or distmat[a[1]][b] = fail then
                return [b,fail];
            fi;
            return [b, a[2] + distmat[a[1]][b]];
        end;

        copyl := ShallowCopy(l);
        copyl[1] := [copyl[1], 0];
        return Iterated(copyl, add)[2];
    end;

    isRegular := function(l)
        local i;
        for i in [2..Length(l)] do
            if l[i] = l[i-1] then return false; fi;
        od;

        return totalDist(l) = L;
    end;
    
    getIndex := function(l)
        local add;
        add := function(a, b)
            return (a-1)*size + b;
        end;
        return Iterated(l,add);
    end;
    #Display(totalDist([1,8]));
    #Display(getIndex([1,1,1]));

    allSeq := function(n)
        return Cartesian(List([1..n], x->DigraphVertices(D)));
    end;

    #Display(allSeq(2));
    
    seq := [];
    for i in [1..N] do
        Add(seq, Filtered(allSeq(i), x -> isRegular(x)));
    od;
    Info(InfoGlobal, 2, "Seq Space: ", seq);

    diff := function(l)
        local i, copyl, res;

        res := List([1..size^(Length(l)-1)], x -> Zero(F));
        for i in [1..Length(l)] do
            copyl := ShallowCopy(l);
            Remove(copyl, i);
            if isRegular(copyl) then 
                #Print(copyl, " ", getIndex(copyl), "\n");
                res[getIndex(copyl)] := (-1)^i * One(F);
            fi;
        od;    
        return res;     
    end;

    #Display(diff([4,3,4,2]));
    ranks := [];
    for i in [1..N] do 
        matrix := NullMat(Length(seq[i]), size^(i-1), F);
        for j in [1..Length(seq[i])] do
            w := seq[i][j];
            coeff := diff(w);
            matrix[j] := coeff;
        od;
        
        #Print(i, ":------------------------\n");
        #for w in matrix do
        #    Print(w, "\n");
        #od;

        if Length(seq[i]) = 0 then Add(ranks, 0); continue; fi;
        Add(ranks, Rank(matrix));
    od;

    Info(InfoGlobal, 2, "Ranks: ", ranks);

    Ker := [Length(seq[1])];
    Img := [];
    Hom := [];

    for i in [2..N] do
        Add(Img, ranks[i]);
        Add(Ker, Length(seq[i]) - ranks[i]);
        Add(Hom, Ker[i-1]-Img[i-1]);
    od;
    
    Info(InfoGlobal, 1, "Ker: ", Ker);
    Info(InfoGlobal, 1, "Img: ", Img);
    Info(InfoGlobal, 1, "Hom: ", Hom);

    return Hom;
end;