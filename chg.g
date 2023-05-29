Read("grobner.g");
Read("qop.g");



Cohomologies := function(Q, n, args...)
    local PA, rels, qsize, adj, v, radj, sadj, GBNPGroebnerBasisTrunc, FastNontips, FastBasis, CustomBasis, FastCoefficients, gb, I, grb, QA, quobasis, OmegaBasis, i, p, diff, ranks, Ker, Img, Cohom, ind, dimKer, dimImg, dimHom,
    a, b, k, l, u, j, matrix, countj, be, img, coeff, shift, vker, kerv, coh, cohrepr, rank, newrank, cringe;
    #Display(Q);

    #relations
    if Length(args) = 0 then
        rels := [];
        PA := PathAlgebra( Rationals, Q );
    else 
        PA := args[1];
        rels := args[2];
    fi;
    #adding 2-paths to relations
    qsize := NumberOfVertices(Q);
    adj := NullMat(qsize, qsize, PA);

    for v in ArrowsOfQuiver(Q) do
        a := ElementOfPathAlgebra(PA, SourceOfPath(v));
        b := ElementOfPathAlgebra(PA, TargetOfPath(v));
        k := VertexPosition(a);
        l := VertexPosition(b);
        adj[k][l] := adj[k][l] + ElementOfPathAlgebra(PA, v);
    od;

    radj := StructuralCopy(adj); #adjacent matrix
    adj := adj ^ 2; #matrix of 2-relations
    sadj := StructuralCopy(adj); #2-adjacent matrix
    #Print(sadj);
    for v in VerticesOfQuiver(Q) do
        for u in VerticesOfQuiver(Q) do
            #Display([v,u]);
            k := VertexPosition(ElementOfPathAlgebra(PA, v));
            l := VertexPosition(ElementOfPathAlgebra(PA, u));
            if k = l or u in NeighborsOfVertex(v) then
                adj[k][l] := Zero(PA);
            fi;
        od;
    od;

    for i in [1..qsize] do
        for j in [1..qsize] do
            if adj[i][j] <> Zero(PA) then
                Add(rels, adj[i][j]);
            fi;
        od;
    od;

    Info(InfoGlobal, 1, "Number of relations: ", Length(rels));
    Info(InfoGlobal, 2, "Relations: ", rels);


    GBNPGroebnerBasisTrunc := function( els, pa )
        local q,ord,creps,grob,pgrob, dg, help;

        creps := [];

        q := QuiverOfPathAlgebra(pa);   
        ord := OrderingOfAlgebra(pa);

        #  Check that all elements are in 
        #  the given path algebra 'pa', and that they
        #  are in the Arrow Ideal J,
        #  (i.e. are not vertices):
        if (QPA_InArrowIdeal(els,pa)) then

        # Should convert all given elements 
        #  to their uniform components:
        els := MakeUniform(els);
        #Print(els);
        # Convert list of path algebra elements
        #  to Cohen's format:
        creps := QPA_Path2Cohen(els);
        #PrintNPList(creps);
        #Print(els);
        #Print(creps);
        # Call Cohen to get Groebner basis:
        dg := function(x)
            return 1;
            if IsQuiverVertex(LeadingMonomial(x)) then return 0; else return 1; fi;
        end;
        help := List(GeneratorsOfAlgebra(pa), dg);
        #Print(help);

        grob := GrobnerTrunc(creps, n+1);

        # Convert results back to path algebra
        #  elements:
        pgrob :=  QPA_Cohen2Path(grob,pa);

        else
        Print("Please make sure all elements are in the given path algebra,",
                "\nand each summand of each element is not (only) a constant",
            "\ntimes a vertex.\n");
        pgrob := false;
        fi;

        return pgrob;
    end;

    #modified function for generating nontip elements
    FastNontips := function(grb)
        local nontips, dict, currentNodes, tree, i, nd, node, newNodes, j;
        
        TipReduceGroebnerBasis(grb);
        dict := grb!.staticDict;
        IsFiniteDifference(dict); #just ignore the result :D

        nontips := [];
        tree := dict!.tree;
        currentNodes := [];

        for i in [1..Length(tree.children)] do
            Add(currentNodes, [tree.children[i], tree.labels[i]]);
        od;

        for i in [0..n] do
            newNodes := [];
            for nd in currentNodes do
                if IsEmpty(nd[1].patterns)
                then
                    Add(nontips, nd[2]);
                    for j in [1..Length(nd[1].children)] do
                        Add(newNodes, [nd[1].children[j], nd[2]*nd[1].labels[j]]);
                    od;
                fi;
            od;

            currentNodes := StructuralCopy(newNodes);
        od;

        return nontips;
    end;

    FastBasis := function(A)
        local B, fam, zero, nontips, parent, parentFam, parentOne;
        fam := ElementsFamily( FamilyObj( A ) );
        zero := Zero(LeftActingDomain(A));
        parent := fam!.pathAlgebra;
        parentFam := ElementsFamily( FamilyObj( parent ) );
        parentOne := One(parentFam!.zeroRing);

        B := Objectify( NewType( FamilyObj( A ),
                            IsBasis and IsCanonicalBasisFreeMagmaRingRep ),
                        rec() );
        SetUnderlyingLeftModule( B, A );
        nontips := FastNontips(GroebnerBasisOfIdeal( fam!.ideal ));
        B!.nontips := nontips;
        nontips := List( nontips, 
                            x -> ElementOfMagmaRing( parentFam,
                                                    parentFam!.zeroRing,
                                                    [parentOne],
                                                    [x] ) );
        SetBasisVectors( B,
            List( EnumeratorSorted( nontips ), 
                    x -> ElementOfQuotientOfPathAlgebra( fam, x, true ) ) );
        B!.zerovector := List( BasisVectors( B ), x -> zero );
        SetIsCanonicalBasis( B, true );
        return B;
    end;

    FastCoefficients := function( B, e )
        local coeffs, data, elms, i, fam;

        data := CoefficientsAndMagmaElements( e![1] );
        coeffs := ShallowCopy( B!.zerovector );
        fam := ElementsFamily(FamilyObj( UnderlyingLeftModule( B ) ));
        elms := EnumeratorSorted( B!.nontips );
        for i in [1, 3 .. Length( data )-1 ] do
            coeffs[ PositionSet( elms, data[i] ) ] := data[i+1];
        od;
        return coeffs;
    end;

    #generating Groebner basis
    gb := GBNPGroebnerBasisTrunc( rels, PA );
    I := Ideal( PA, gb );

    #Info(InfoGlobal, 1, "Groebner basis calculated!");

    if Length(gb) = 0 then
        Info(InfoGlobal, 1, "Implementing cringe strategies...");
        Q := AddEdge(AddVertex(AddVertex(Q, "null1"), "null2"), ["null1", "null2"]);
        PA := PathAlgebra(Rationals, Q);
        rels := [ElementOfPathAlgebra(PA, OutgoingArrowsOfVertex(Q.null1)[1])];

        cringe := Cohomologies(Q, n, PA, rels);
        cringe[1] := cringe[1] - 2;
        return cringe;
    fi;


    #grb := GroebnerBasisTrunc(I, gb);
    grb := CompletelyReduceGroebnerBasis(GroebnerBasis( I, gb ));
    #Display("Groebner basis calculated!");
    #Display(grb);
    Info(InfoGlobal, 1, "Groebner basis calculated!");
    Info(InfoGlobal, 2, "Groebner basis: ", grb);
    QA := PA/I;
    quobasis := FastBasis(QA);

    OmegaBasis := [];
    for i in [1..n+1] do
        Add(OmegaBasis, []);
    od;

    for p in quobasis do
        #Display(p);
        #Display(LengthOfPath(p));
        Add(OmegaBasis[LengthOfPath(LeadingMonomial(p))+1], p);
    od;

    Info(InfoGlobal, 2, "Omega basis: ", quobasis);
    for i in [1..Length(OmegaBasis)] do
        Info(InfoGlobal, 1, i, "-th component: ", Length(OmegaBasis[i]));
    od;
    #Display(OmegaBasis);

    diff := function(v) #differential
        local diffm, res;
        diffm := function(v) #differential for monomials
            local res,sgn,path,leftm,rightm,i,j,u;
            
            #Display(v);

            if v = Zero(Q) then 
                return Zero(PA);
            fi;

            res := Zero(PA);

            sgn := 1;
            for u in IncomingArrowsOfVertex(SourceOfPath(v)) do
                res := res + ElementOfPathAlgebra(PA, u*v);
            od;
            sgn := -1;

            path := WalkOfPath(v);
            #Display(path);

            leftm := EmptyPlist(Length(path));
            rightm := EmptyPlist(Length(path));
            if Length(path) > 0 then
                leftm[1] := ElementOfPathAlgebra(PA, SourceOfPath(v));
                rightm[Length(path)] := ElementOfPathAlgebra(PA, TargetOfPath(v));
            fi;
            for i in [2..Length(path)] do
                leftm[i] := leftm[i-1]*radj[VertexPosition(ElementOfPathAlgebra(PA, SourceOfPath(path[i-1])))][VertexPosition(ElementOfPathAlgebra(PA, TargetOfPath(path[i-1])))];
            od;
            for j in [Length(path)-1, Length(path)-2..1] do
                #Print(j);
                rightm[j] := radj[VertexPosition(ElementOfPathAlgebra(PA, SourceOfPath(path[j+1])))][VertexPosition(ElementOfPathAlgebra(PA, TargetOfPath(path[j+1])))]*rightm[j+1];
            od;
            #Display(leftm);
            #Display(rightm);

            for i in [1..Length(path)] do
                k := VertexPosition(ElementOfPathAlgebra(PA, SourceOfPath(path[i])));
                l := VertexPosition(ElementOfPathAlgebra(PA, TargetOfPath(path[i])));
                res := res + sgn*leftm[i]*(sadj[k][l])*rightm[i];
                sgn := -sgn;
            od;

            for u in OutgoingArrowsOfVertex(TargetOfPath(v)) do
                res := res + sgn*ElementOfPathAlgebra(PA, v*u);
            od;
            #Display(res);
            return res;
        end;

        res := Zero(PA);
        while v <> Zero(QA) do
            res := res + LeadingCoefficient(v)*diffm(LeadingMonomial(v));
            v := v - LeadingTerm(v);
        od;
        #Display(res);
        return ElementOfQuotientOfPathAlgebra(FamilyObj(Zero(QA)), res, false);
    end;


    ranks := [];

    Ker := [];
    Img := [[]];
    Cohom := [];

    for ind in [1..n] do  
        #Print(ind-1, "-th:\n");
        matrix := NullMat(Length(OmegaBasis[ind]), Length(quobasis), Rationals);
        countj := 1;
        for be in OmegaBasis[ind] do
            img := diff(be);
            #Display(img);
            coeff := FastCoefficients(quobasis, img);
            matrix[countj] := coeff;
            countj := countj+1;
            #Print("j: ", countj, "\n");
        od;
        #Print(ind-1, "-th:\n");
        #Display(matrix);



        #------------- FOLLOWING STUFF IS OPTIONAL ---------------- (comment if not needed):
        #Let's calculate Ker and Img basis vectors:

        Add(Img, matrix); #RIP operation
        Add(Ker, []);

        if Length(matrix) > 0 then
            shift := Sum(List(OmegaBasis{[1..ind-1]}, Length)); #shift = sum of previous dims
            for kerv in NullspaceMat(matrix) do #appending v in Ker with appropriate number of zeros
                vker := List([1..Length(quobasis)], x->0);
                vker{[shift+1..shift+Length(kerv)]} := kerv;

                Add(Ker[ind], vker);
            od;
        fi;
        Add(Cohom, []);

        rank := 0;
        if Length(Img[ind]) > 0 then
            rank := Rank(Img[ind]);
        fi;
        for be in Ker[ind] do
            Add(Img[ind], be);  
            
            newrank := Rank(Img[ind]);
            
            if newrank > rank then 
                Add(Cohom[ind], be);
                rank := newrank;
            else
                Remove(Img[ind]);
            fi;
        od;

        Info(InfoGlobal, 1, ind-1, "-th Cohomology basis:");
        for coh in Cohom[ind] do
            cohrepr := Zero(QA);
            for i in [1..Length(coh)] do 
                cohrepr := cohrepr + coh[i]*quobasis[i];
            od;
            Info(InfoGlobal, 1, "\t", cohrepr);
        od;
        #------------- THE STUFF AVOVE IS OPTIONAL ---------------- (comment if not needed)

        Info(InfoGlobal, 1, ind-1, "-th matrix calculated!");
        rank := 0;
        if Length(OmegaBasis[ind]) > 0 then
            rank := Rank(matrix);
        fi;
        Add(ranks, rank);
        Info(InfoGlobal, 1, ind-1, "-th rank: ", rank);
    od;

    Info(InfoGlobal, 1, "Omega basis: ", quobasis);
    Info(InfoGlobal, 1, "Ranks: ", ranks);
    #Print("Calculating dimensions:\n");
    dimKer := [];
    dimImg := [0];
    dimHom := [];

    for i in [1..n] do
        Add(dimKer, Length(OmegaBasis[i]) - ranks[i]);
        Add(dimImg, ranks[i]);
        Add(dimHom, dimKer[i] - dimImg[i]);
    od;
    Info(InfoGlobal, 1, "Omega dims: ", List(OmegaBasis, Length));
    Info(InfoGlobal, 1, "Ker dims: ", dimKer);
    Info(InfoGlobal, 1, "Img dims: ", dimImg);
    Info(InfoGlobal, 1, "Cohom dims: ", dimHom);
    #Display(dimKer);
    #Display(dimImg);
    #Display(dimHom);

    return dimHom;
end;