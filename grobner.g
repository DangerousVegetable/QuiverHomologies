LoadPackage("GBNP");


SGrobnerLoopsTrunc := function(G,todo,funcs) 
    local i,lG,count,ltspoly,spoly,sltspoly,spo,l,h,Gset,genlist,b,OT,todoheap,iterations,
    hsum;
    if not IsBound(funcs.pg) then
    	funcs.pg:=GBNP.GetOptions().pg;
    else
    	if (funcs.pg<>0) then
		GBNP.SetOption("pg",funcs.pg); # XXX check that funcs.pg is not
					       # erroneously 0
	fi;
    fi;

    # if G is empty or one, no iterations are needed
    if (G=[]) or (Length(G)=1 and G[1][1]=[[]] and IsOne(G[1][2][1])) then 
      return rec(G:=G, todo:=[], completed:=true, iterations:=0);
    fi;

    
    genlist:=[1..Maximum(Flat(List(G,x->x[1])))]; # largest generator used in G
    Gset:=List(LMonsNP(G),x->BlistList(genlist,Set(x)));
    OT:=rec();

    #if IsBound(funcs.GB) then
    #	OT.GBL:=GBNP.CreateOccurTreePTSLR(LMonsNP(funcs.GB),funcs.pg,true);
    #fi;
    OT.GL:=GBNP.CreateOccurTreePTSLR(LMonsNP(G),funcs.pg,true);
    OT.GR:=GBNP.CreateOccurTreePTSLR(LMonsNP(G),funcs.pg,false);

    OT.todoL:=GBNP.CreateOccurTreePTSLR(LMonsNP(todo),funcs.pg,true);
    lG:=Length(G); 
    todoheap:=THeapOT(todo, OT.todoL);
    #Print("debug: start\n");
    #GBNP.THeapOTCheck(todoheap);
    #Print("debug: start 2\n");
    count:=[Length(todoheap)];
    iterations:=0;
    while not IsTHeapOTEmpty(todoheap) do  
      iterations:=iterations+1;

# Fase IIIa, Take the first element 'spoly' of todo and add it to 'G'
# - Take the first element of the todo list and remove it from todo
# - Add this to the basis

      spoly:=HeapMin(todoheap); 
      ltspoly := spoly[1][1];
      sltspoly:=BlistList(genlist,Set(ltspoly)); # jwk -set
      Info(InfoGBNP,3,"added Spolynomial is:\n", spoly);
      Add(G,spoly); 
      Add(Gset,sltspoly); 	# jwk - Gset/todoset
      Remove(todoheap,1); 	# only remove after it is added to G 
      		# XXX this removing might be expensive for large todo lists,
		# it might be worthwhile to implement todo as a 3-tree
      	
      lG:=lG+1; 

      # update the tree
      GBNP.AddMonToTreePTSLR(ltspoly,-1,OT.GL,true);
      GBNP.AddMonToTreePTSLR(ltspoly,-1,OT.GR,false);
      #GBNP.RemoveMonFromTreePTSLR(ltspoly,1,OT.todoL,true);

# Fase IIIb, update todo

      GBNP.ObsTall(lG,G,todoheap,OT,funcs); # jwk - tree variant of GBNP.Obs, no sorting needed here

# Fase IIIc, reduce the list G with the new polynomial 'spoly'

      if not IsBound(funcs.SkipIIIc) then
      
        i:=1;
        l:=lG;
        while i < l do 
          h := G[i];
	      b:=IsSubsetBlist(Gset[i],sltspoly) and 
	      	  GBNP.Occur(ltspoly,h[1][1]) > 0;
  	  if b=true then # -jwk check for set
              RemoveElmList(G,i);
              RemoveElmList(Gset,i);
	      GBNP.RemoveMonFromTreePTSLR(h[1][1],i,OT.GL,true);
	      GBNP.RemoveMonFromTreePTSLR(h[1][1],i,OT.GR,false);

	      spo:=GBNP.StrongNormalForm2Tall(h,G,todoheap!.list,OT,funcs); 
	      # XXX uses todo XXX
              if spo = [[],[]] then 
                  lG:=lG-1;          
              else
	          Add(G,MkMonicNP(spo));
	          Add(Gset,BlistList(genlist,Set(spo[1][1])));
	          GBNP.AddMonToTreePTSLR(spo[1][1],-1,OT.GL,true);
	          GBNP.AddMonToTreePTSLR(spo[1][1],-1,OT.GR,false);

                  funcs.CentralT(lG,G,todoheap,OT,funcs); # - jwk use tree variant 
                  GBNP.ObsTall(lG,G,todoheap,OT,funcs); # - jwk use tree variant, no sorting needed here
              fi;
              l:=l-1;            
          else  
              i:=i+1; 
          fi;
        od;
      fi;

      Info(InfoGBNP,2,"length of G =",lG);

# Fase IIId, reducing todo with respect to 'spoly'

      l:=Length(todoheap);
      i:=1;
      while i <= l do
          h := todoheap[i];
	  # b is true if h can be reduced 
	  # first check G
	  b:= GBNP.OccurInLstT(h[1][1],OT.GL)[1] +
	  # then check todo
	      GBNP.Find3Dnum(
	          GBNP.LookUpOccurTreeAllLstPTSLR(h[1][1],OT.todoL,true), i
	      )[1] > 0;


        #----------------------
        #added simple check on whether deg > maxdegree allowed
        if Length(h[1][1]) > funcs.maxdegree then
            l := l-1;
            Remove(todoheap, i);
            continue;
        fi;
        #-----------------------


  	  if b=true then # -jwk check for set
              #Remove(todoheap,i); 
	      #GBNP.RemoveMonFromTreePTSLR(h[1][1],i,OT.todoL,true);
	      spo:=GBNP.StrongNormalForm3Dall(h,G,todoheap,OT,funcs,i); 
              if spo<>[[],[]] then 
	          Replace(todoheap,i,MkMonicNP(spo)); 
		  # allowed because: replacing an element in the todo heap with
		  # a smaller element does not effect elements with a higher
		  # index (but may change parent-nodes of the element that was
		  # changed, which have a smaller index)

	          #GBNP.AddMonToTreePTSLR(spo[1][1],i,OT.todoL,true);
                  i:=i+1;
	      else
        	  l:=l-1; 
		  Remove(todoheap,i);
       	      fi;
          else 
              i:=i+1;
          fi; 
      od; 
      Info(InfoGBNP,2,"length of todo is ",l); 
      Info(InfoGBNP,4,"elements are\n",todoheap!.list); 
      Add(count,l); 

      if (GBNP.cleancount > 0) and (Length(count) mod GBNP.cleancount = 0) then
      	GBNP.cleanpolys:=true;
      fi;

      if IsBound(GBNP.cleanpolys) then
      	Unbind(GBNP.cleanpolys);
	GBNP.ReducePolTailsPTS(G,todoheap,OT,funcs);
      fi;

      if IsBound(GBNP.GetOptions().CheckQA) then
      	Info(InfoGBNP,1,"size QA (max ",GBNP.GetOptions().CheckQA,")",
		GBNP.NondivMonsPTSenum(LMonsNP(G),LMonsNP(todoheap),
			GBNP.GetOptions().Alphabetsize,0,
			GBNP.GetOptions().CheckQA
		)
	);
      fi;
      # sort here: possibly cheaper XXX

      if IsBound(funcs.maxiterations) then
        if iterations >= funcs.maxiterations then
	  return rec(G:=G, todo:=todoheap!.list, completed:=false,
	    iterations:=iterations
	  );
	fi;
      fi;
    od; 
    Info(InfoGBNP,2,"List of todo lengths is ",count);
    return rec(G:=G, todo:=[], completed:=true, iterations:=iterations);
end;


GrobnerTrunc := function(arg) local tt,todo,G,GLOT,funcs,KI,loop,withpair;

    # set the default options
    funcs:=ShallowCopy(GBNP.SGrobnerLoopRec);

    if Length(arg)<1 then
      return fail;
    else
      KI:=arg[1];
    fi;

    tt:=Runtime(); 

    if Length(arg)>=2 and IsInt(arg[Length(arg)]) then
        funcs.maxdegree := arg[Length(arg)];
    fi;
    
    if Length(arg)>=2 and IsList(arg[2]) then
        withpair:=true;
    else
        withpair:=false;
    fi;
      
# phase I, start-up, building G
# - Clean the list and make all polynomials monic 
# - Sort each polynomial so that its leading term is in front
# - Order the list of polynomials such that 
#      the one with smallest leading term comes first
# - Compute internal StrongNormalForm 

     Info(InfoGBNP,1,"number of entered polynomials is ",Length(KI));

     if (withpair) then
         # no cleaning should be needed when continuing
         G:= ShallowCopy(KI);
     else
         G:= GBNP.ReducePol(KI);
     fi;

     # only call GBNP.CalculatePG after reduction
     funcs.pg:=GBNP.CalculatePG(G);

     Info(InfoGBNP,1,"number of polynomials after reduction is ",Length(G));
#    Print("The list of starting polynomials is:\n ",G,"\n"); 
     Info(InfoGBNP,1,"End of phase I"); 
 

# phase II, initialization, making todo 
# - Compute all possible obstructions 
# - Compute their S-polynomials 
# - Make a list of the non-trivial StrongNormalForms 

    if withpair then
        todo:=arg[2];
    else
        todo:=GBNP.AllObs(G, funcs); 
    fi;
 
#    Print("Current list of spolynomials is ",todo,"\n"); 
#    Print("Current number of spolynomials is ",Length(todo),"\n"); 
    Info(InfoGBNP,1,"End of phase II"); 
 
 
# phase III, The loop 

    loop := SGrobnerLoopsTrunc(G,todo,funcs); 
    
    if loop.completed <> true then
      Info(InfoGBNP,1,"Calculation interrupted after ",funcs.maxiterations,
        " iterations"
      );
    else
      Info(InfoGBNP,1,"End of phase III");
    fi;
  
# phase IV, Make the result reduced 

    GLOT:=GBNP.ReducePol2(G); 
    GBNP.ReducePolTails(G,[],GLOT); # reduce the tails of the polynomials

    Info(InfoGBNP,1,"End of phase IV"); 

# End of the algorithm
 
     Info(InfoGBNPTime,1,"The computation took ",Runtime()-tt," msecs."); 
     
     if IsBound(funcs.maxiterations) then
       return loop;
     else
       return loop.G; 
     fi;
end; 