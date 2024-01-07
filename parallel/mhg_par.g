SetInfoLevel(InfoPackageLoading,4);

#LoadPackage("digraphs");
LoadPackage("QPA");

QuiverShortestDistances := function(Q)
    local PA, distmat, size, edges, i, j, k, e, from, to;

    PA := PathAlgebra( Rationals, Q );

    size := NumberOfVertices(Q);
    distmat := NullMat(size, size);
    for i in [1..size] do   
        for j in [1..size] do 
            if not i = j then distmat[i][j] := fail; fi;
        od; 
    od;

    #edges := NumberOfArrows(Q);
    
    for k in [1..size+1] do 
        for e in ArrowsOfQuiver(Q) do
            from := VertexPosition(ElementOfPathAlgebra(PA, SourceOfPath(e)));
            to := VertexPosition(ElementOfPathAlgebra(PA, TargetOfPath(e)));
            for i in [1..size] do 
                if not distmat[i][from] = fail then 
                    distmat[i][to] := Minimum(distmat[i][from]+1, distmat[i][to]); 
                fi;
            od;
        od;
    od;

    return distmat;
end;

MagnitudeHomologies := function(F, Q, N, L, THREADS)
    local size, distmat, totalDist, allSeq, i, j, k, seq, isRegular, getIndex, diff, tasks, t, Hom, fixedHom, temp;
    #TODO
    distmat := QuiverShortestDistances(Q);
    #Display(distmat);
    N := N+1;
    size := NumberOfVertices(Q);

    #TODO
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
        return Cartesian(List([1..n], x->[1..size]));
    end;

    #Display(allSeq(2));
    
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
    
    seq := [];
    for i in [1..N] do
        Add(seq, Filtered(allSeq(i), x -> isRegular(x)));
    od;
    Info(InfoGlobal, 2, "Seq Space: ", seq);

    MakeReadOnlyObj(seq);

    fixedHom := function(startInd, endInd)
        local i, j, fixedSeq, fixedRanks, fixedDiffMatrix, coeff, w, 
            fixedKer, fixedImg, fixedHom;

        fixedSeq := [];
        for i in [1..N] do
            Add(fixedSeq, Filtered(seq[i], x -> x[1] = startInd and x[Length(x)] = endInd));
        od;

        fixedRanks := [];
        for i in [1..N] do 
            fixedDiffMatrix := NullMat(Length(fixedSeq[i]), size^(i-1), F);
            for j in [1..Length(fixedSeq[i])] do
                w := fixedSeq[i][j];
                coeff := diff(w);
                fixedDiffMatrix[j] := coeff;
            od;

            if Length(fixedSeq[i]) = 0 then Add(fixedRanks, 0); continue; fi;
            Add(fixedRanks, Rank(fixedDiffMatrix));

            Print("Hello from: ", CurrentThread(), "\n");
            
        od;

        #Info(InfoGlobal, 2, "Ranks: ", ranks);

        fixedKer := [Length(fixedSeq[1])];
        fixedImg := [];
        fixedHom := [];

        for i in [2..N] do
            Add(fixedImg, fixedRanks[i]);
            Add(fixedKer, Length(fixedSeq[i]) - fixedRanks[i]);
            Add(fixedHom, fixedKer[i-1]-fixedImg[i-1]);
        od;
    
        #Info(InfoGlobal, 1, "Ker: ", Ker);
        #Info(InfoGlobal, 1, "Img: ", Img);
        #Info(InfoGlobal, 1, "Hom: ", Hom);
        return fixedHom;
    end;

    tasks := [];
    for i in [1..size] do
        for j in [1..size] do
            if Length(tasks) < THREADS then 
                Add(tasks, RunTask(fixedHom, i, j));                
            else 
                Add(tasks, ScheduleTask(tasks{[Length(tasks)-THREADS+1]}, fixedHom, i, j));
            fi;
            #Print("Added: ", i, " ", j, "\n");
        od;
    od;

    Hom := List([2..N], x -> 0);

    for t in tasks do
        for i in [1..Length(TaskResult(t))] do
            Hom[i] := Hom[i] + TaskResult(t)[i];
        od;
    od;


    return Hom;
end;