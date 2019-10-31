    function [a,uncertainty]=selectBayesianA(currentState,uncertainty,action,ABestGuess,xIn,yIn)
    coder.extrinsic('assignin')    
    num=200
        maxE=action(1)+5
        minE=action(1)-5
        
        maxT=action(2)+50
        minT=action(2)-50
        
        maxA=action(3)+5
        minA=action(3)-5
        
        maxR=action(4)+5
        minR=action(4)-5
        
        if maxE>30
            maxE=30
        end
        
        if maxE<-30
            maxE=-30
        end
        
        if maxA>30
            maxA=30
        end
        
        if maxA<-30
            maxA=-30
        end
        
        if maxR>30
            maxR=30
        end
        
        if maxR<-30
            maxR=-30
        end
        
        
        elevator=(maxE-minE).*rand(1,num)+minE;
        thrust=(maxT-minT).*rand(1,num)+minT;
        aileron=(maxA-minA).*rand(1,num)+minA;
        rudder=(maxR-minR).*rand(1,num)+minR;
        actionsTest=[elevator;thrust;aileron;rudder]
        goodInputs=[];
        ys=zeros(11,num)
        yPos=zeros(11,num)
        coder.extrinsic('assignin')
        assignin('base','actionsTest',actionsTest)
        counter=0
       goal=[60,10,-100]
       %if uncertainty<10
           %goal=goal*(uncertainty/100)^.5
           deltaSEst=simulateNominal(repmat(currentState,1,num),actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+repmat(currentState,1,num)
           assignin('base','yonesteps',y)
           deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
           assignin('base','ytwosteps',y)
            deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
           assignin('base','ythreesteps',y)
           deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
           assignin('base','yfoursteps',y)
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
          y=deltaS*.05+y
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
           assignin('base','ytensteps',y)
           index=abs(y(4,:))<goal(2) & abs(y(8,:))<goal(2) & y(11,:)>goal(3)
           assignin('base','index',index)
           goodInputs=actionsTest(:, abs(y(4,:))<goal(2) & abs(y(8,:))<goal(2) & y(11,:)>goal(3))
            assignin('base','goodInputs',goodInputs)

        nmax=0;
        index=1;
        if isempty(goodInputs)
            goodInputs=actionsTest
        end
        tic
        %for pos=1:size(goodInputs,2);    
            deltaSEst2=simulateNominal(repmat(currentState,1,size(goodInputs,2)),goodInputs);
            %ASum=(NET{1}+NET{2}+NET{3}+NET{4})./4
            deltaS=ABestGuess'*[goodInputs;deltaSEst2];

           variance=calcVar(xIn,yIn,[goodInputs;deltaS])
        
            
                [nmax,index]=max(variance)


            
        %end
        assignin('base','toc3',toc)
        uncertainty=nmax
        finalInputs=reshape(goodInputs,4,[])
        a=finalInputs(:,index)
        a=reshape(a,4,1)
        
    end