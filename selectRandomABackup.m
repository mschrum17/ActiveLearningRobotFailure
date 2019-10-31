    function [a,uncertainty]=selectRandomA(currentState,uncertainty,ABestGuess,NET,action)
        num=200
        elevator=(30+30).*rand(1,num)-30;
        thrust=(20000).*rand(1,num)+40000;
        aileron=(30+30).*rand(1,num)-30;
        rudder=(30+30).*rand(1,num)-30;
        actionsTest=[elevator;thrust;aileron;rudder]
        goodInputs=[];
        ys=zeros(11,num)
        yPos=zeros(11,num)
        coder.extrinsic('assignin')
        
        counter=0
       goal=[60,20,-30]
       if uncertainty<10
           %goal=goal*(uncertainty/100)^.5
           deltaSEst=simulateNominal(repmat(currentState,1,200),actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.5+repmat(currentState,1,200)
           goodInputs=actionsTest(:,(y(1,:)<160+goal(1) & y(1,:)>160-goal(1) & abs(y(4,:))<goal(2) & abs(y(8,:))<goal(2) & abs(y(9,:))<goal(2) & y(11,:)>goal(3)))
%            for k=1:num
%                 deltaSEst=simulateNominal(currentState,actionsTest(:,k));
%                 deltaS=ABestGuess'*([actionsTest(:,k);deltaSEst])
%                 
%                 y=deltaS*.5+currentState
%                 ys(:,k)=y
%                 if y(1,1)<160+goal(1) && y(1,1)>160-goal(1) && abs(y(4,1))<goal(2) && abs(y(8,1))<goal(2) && abs(y(9,1))<goal(2) && y(11,1)>goal(3)
%                     posInput=[posInput actionsTest(:,k)];
%                     yPos(:,k)=y
%                     
%              
%                 end
%             end
       end
        nmax=0;
        index=1;
        if isempty(goodInputs)
            goodInputs=actionsTest
        end
        tic
        for pos=1:size(goodInputs,2);    
            deltaSEst2=simulateNominal(currentState,goodInputs(:,pos));
            %ASum=(NET{1}+NET{2}+NET{3}+NET{4})./4
            deltaS=ABestGuess'*[goodInputs(:,pos);deltaSEst2];
            y=deltaS*.05+currentState
            n=0;
            for j=1:size(NET,1)       
                deltaSZ=NET{j}'*[goodInputs(:,pos);deltaSEst2];
                yZ=deltaSZ*.05+currentState
                %n=n+norm(defaultderiv('dperf_dwb',netFail2,[input(1:4);stateEst2],yZ));
               %n=n+norm(sum(abs((y-yZ)*[goodInputs(:,pos);deltaSEst2]'),1)); 
                n=sum(abs(y-yZ)); 
            end
            nFinal=n/4.0;
            if nFinal>nmax
                nmax=nFinal;
                index=pos

            end
            
        end
        assignin('base','toc3',toc)
        uncertainty=nmax
        finalInputs=reshape(goodInputs,4,[])
        a=finalInputs(:,index)
        
    end