    function [a,uncertainty]=selectRandomA(currentState,uncertainty,ABestGuess,NET,action,xIns,yIns)
    
    num=200
%         maxE=action(1)+5
%         minE=action(1)-5
%         
%         maxT=action(2)+75
%         minT=action(2)-10
%         
%         maxA=action(3)+30
%         minA=action(3)-30
%         
%         maxR=action(4)+40
%         minR=action(4)-40
%         
%         if maxE>10
%             maxE=10
%         end
%         
%         if minE<-25
%             minE=-25
%         end
%         
%         if maxT>9e5
%             maxT=7e5
%         end
%         
%         if minT<50
%             minT=50
%         end
%         
%         
%         if maxA>30
%             maxA=30
%         end
%         
%         if minA<-30
%             minA=-30
%         end
%         
%         if maxR>50
%             maxR=50
%         end
%         
%         if minR<-50
%             minR=-50
%         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        maxE=action(1)+2
        minE=action(1)-2
        
        maxT=action(2)+50
        minT=action(2)-10
        
        maxA=action(3)+10
        minA=action(3)-10
        
        maxR=action(4)+20
        minR=action(4)-20
        
        if maxE>5
            maxE=5
        end
        
        if minE<-5
            minE=-5
        end
        
        if maxT>600
            maxT=600
        end
        
        if minT<50
            minT=50
        end
        
        
        if maxA>15
            maxA=15
        end
        
        if minA<-15
            minA=-15
        end
        
        if maxR>20
            maxR=20
        end
        
        if minR<-20
            minR=-20
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        
        
        elevator=(maxE-minE).*rand(1,num)+minE;
        thrust=(maxT-minT).*rand(1,num)+minT;
        aileron=(maxA-minA).*rand(1,num)+minA;
        rudder=(maxR-minR).*rand(1,num)+minR;
        actionsTest=[elevator;thrust;aileron;rudder]
        goodInputs=[];
        ys=zeros(11,num)
        yPos=zeros(11,num)


        counter=0
       goal=[60,10,-200]
       %if uncertainty<10
           %goal=goal*(uncertainty/100)^.5
           deltaSEst=simulateNominal(repmat(currentState,1,num),actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+repmat(currentState,1,num)

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
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
          y=deltaS*.05+y
                       deltaSEst=simulateNominal(y,actionsTest);
           deltaS=ABestGuess'*([actionsTest;deltaSEst])
           y=deltaS*.05+y

           index=abs(y(4,:))<goal(2) & abs(y(8,:))<goal(2) & y(11,:)>goal(3)

           goodInputs=actionsTest(:, abs(y(4,:))<goal(2) & abs(y(8,:))<goal(2) & y(11,:)>goal(3))

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
       %end
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
            y=deltaS*.05+repmat(currentState,1,size(goodInputs,2))
            n=zeros(1,size(goodInputs,2));
                      yZ=zeros(11,size(goodInputs,2),4)
            for j=1:size(NET,1)       
                deltaSZ=NET{j}'*[goodInputs;deltaSEst2];
                yZ(:,:,j)=deltaSZ*.05+repmat(currentState,1,size(goodInputs,2))
                %n=n+norm(defaultderiv('dperf_dwb',netFail2,[input(1:4);stateEst2],yZ));
               %n=n+norm(sum(abs((y-yZ)*[goodInputs(:,pos);deltaSEst2]'),1)); 
                %n=n+sum(abs(y-yZ)); 
            end

            yMean=sum(yZ,3)/4

  
            nFinal=sum(sum(abs((repmat(yMean,1,1,4)-yZ)),3),1);

            %nFinal=n./4.0;
            
                [nmax,index]=max(nFinal)


            
        %end

        uncertainty=nmax
        finalInputs=reshape(goodInputs,4,[])
        a=finalInputs(:,index)
        a=reshape(a,4,1)
        
    end