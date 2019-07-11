function bestA= updateDamage(in)
    bestA=zeros(1,4);
    time=in(1);
    numStates=11;
    numOutputs=11;
    if time>=20.2
        inputsT=evalin('base','savedInputs');
        outputsT=evalin('base','savedOutputs');
        stateEst=zeros(numOutputs,size(inputsT,2));
        if time==20.2
            actions=inputsT(1:4,:);
            states=inputsT(5:end,:);
        else
            a=in(2:5);
            s=in(6:5+numStates);
            sO=in(17:end);
            inputsT=[[a;s],inputsT];
            outputsT=[sO,outputsT];
            actions=inputsT(1:4,:);
            states=inputsT(5:end,:);
            stateEst=zeros(numOutputs,size(inputsT,2));
            %assignin('base','savedInputs',inputsT);
            %assignin('base','savedOutputs',outputsT);
        end

        for i =1:size(inputsT,2)
            stateEst(:,i)=simulateNominal(states(:,i),actions(:,i));
        end

        trainingInputs=[actions;stateEst];
tic
        hiddenLayerSize = [10];
        netFail2Simulink = fitnet(hiddenLayerSize);
        netFail2Simulink.trainParam.epochs = 10;
        netFail2Simulink.layers{1}.transferFcn = 'purelin';
        netFail2Simulink.divideFcn = 'divideind';
        netFail2Simulink.divideParam.trainInd = 1:size(trainingInputs,2);
        netFail2Simulink.divideParam.valInd = [];
        netFail2Simulink.divideParam.testInd = [];
        %netFail2Simulink.trainParam.showWindow = false;
        % Train the Network
        [netFail2Simulink,trFail2] = train(netFail2Simulink,trainingInputs,outputsT);
        assignin('base','netFail2Simulink',netFail2Simulink);
        assignin('base','trFail2',trFail2)
        genFunction(netFail2Simulink,'simDamage','MatrixOnly','yes');


        %%create bootstrapped models
        Z=4;
         NET = cell(Z,1);
        for i=1:size(NET,1)
            %indices of samples used for bootstrapping. Randomly sampled with replacement
            bootSamples= randi(size(trainingInputs,2),size(trainingInputs,2),1);
            xBoot=zeros(numOutputs+4,size(trainingInputs,2));
            yBoot=zeros(numOutputs,size(trainingInputs,2));
            %Pick out samples from training inputs and outputs
            for b=1:size(trainingInputs,2)
                xBoot(:,b)=trainingInputs(:,bootSamples(b));
                yBoot(:,b)=outputsT(:,bootSamples(b));
            end
            %All samples used for trainging and testing
            bootInput=xBoot;
            bootOutput=yBoot;

            hiddenLayerSize = [10];
            netBoot = fitnet(hiddenLayerSize);
            netBoot.trainParam.epochs = 10;
            netBoot.layers{1}.transferFcn = 'purelin';

            % Set up Division of Data for Training, Validation, Testing
            netBoot.divideFcn = 'divideind';
            netBoot.divideParam.trainInd = 1:size(trainingInputs,2);
            netBoot.divideParam.valInd = [];
            netBoot.divideParam.testInd = [];
            netBoot.trainParam.showWindow = false;
            % Train Z bootstrap networks
            [netBoot,trFail1] = train(netBoot,bootInput,bootOutput);
             NET{i}=netBoot;
            out = netBoot(bootInput);
            errors = gsubtract(outputsT,bootOutput);
            performance = perform(netBoot,bootOutput,out);  
        end
        %%find best action subject to constraints
        A = [];
        b = [];
        Aeq = [];
        beq = [];
        lb = [-30,35000,-30,-30];
        ub = [30,70000000,30,30];
        nonlcon=[];
        IntCon=[];
        %options = optimoptions('ga','FitnessLimit', 17);
        %options = optimoptions('ga','Generations', 10);
        options = optimoptions('ga','TimeLimit', 20);

        bestA=fmincon(@findBestA,[0 5.5e5 0 0],A,b,Aeq,beq,lb,ub,@setUpConstraints);
        %bestA=patternsearch(@findBestA,[0 5.5e5 0 0],A,b,Aeq,beq,lb,ub,@setUpConstraints);
%         uncertainty2=evalin('base','uncertainty')
%         if uncertainty2>100
%             bestA=ga(@findBestA,4,A,b,Aeq,beq,lb,ub,[],options)
%         else
%             bestA=ga(@findBestA,4,A,b,Aeq,beq,lb,ub,@setUpConstraints,options);
%         end
         bestA=bestA';
       
        %bestA=selectRandomA()
        
        
    end
    
    function a=selectRandomA(currentState)
        num=200
        currentState=evalin('base','currentState')
        elevator=(30+30).*rand(1,num)-30;
        thrust=(20000).*rand(1,num)+40000;
        aileron=(30+30).*rand(1,num)-30;
        rudder=(30+30).*rand(1,num)-30;
        actionsTest=[elevator;thrust;aileron;rudder]
        posInput=[];
       counter=0
       uncertainty=evalin('base','uncertainty')
       goal=[100,30,-50]
       if uncertainty<100
           goal=goal*(uncertainty/100)^.5
           assignin('base','goal',goal)
            for k=1:num
                stateEst3=simulateNominal(currentState,actionsTest(:,k));
                y=sim(netFail2Simulink,[actionsTest(:,k);stateEst3])
                if y(1,1)<160+goal(1) && y(1,1)>160-goal(1) && abs(y(4,1))<goal(2) && abs(y(8,1))<goal(2) && abs(y(9,1))<goal(2) && y(11,1)>goal(3)
                    posInput=[posInput actionsTest(:,k)];
                    counter=counter+1
                    assignin('base','y',y)
                end
            end
       end
        assignin('base','counter',counter)
        nmax=0;
        index=1;
        if isempty(posInput)
            posInput=actionsTest
        end
        assignin('base','posInput',posInput)
        for pos=1:size(posInput,2)
            currentState=evalin('base','currentState');    
            stateEst2=simulateNominal(currentState,posInput(:,pos));
            y=sim(netFail2Simulink,[posInput(:,pos);stateEst2]);
            n=0;
            for j=1:size(NET,1)       
                yZ=sim(NET{j},[posInput(:,pos);stateEst2]);
                n=n+norm(defaultderiv('dperf_dwb',netFail2Simulink,[posInput(:,pos);stateEst2],yZ));
                %n=n+norm(sum(y-yZ)*input,1); 
                %n=sum(abs(y-yZ)); 
            end
            nFinal=n/4.0;
            if nFinal>nmax
                nmax=nFinal;
                index=pos

            end
            
        end
        max2=evalin('base','max2')
        assignin('base','max2',[max2 nmax])
        assignin('base','uncertainty',nmax)
        a=posInput(:,index)
        
    end
        


    
    
    function nFinal=findBestA(safeAction)
        safeAction=safeAction';
        currentState=evalin('base','currentState');    
        stateEst2=simulateNominal(currentState,safeAction);
        y=sim(netFail2Simulink,[safeAction;stateEst2]);
        n=0;
        for j=1:size(NET,1)       
            yZ=sim(NET{j},[safeAction;stateEst2]);
            %n=n+norm(abs(defaultderiv('dperf_dwb',netFail2Simulink,[safeAction;stateEst2],yZ)));
            %n=n+norm(sum(y-yZ)*input,1); 
            n=sum(abs(y-yZ)); 
        end
        nFinal=-n/4.0;
        assignin('base','uncertainty',nFinal*(-1))
        assignin('base','y1',y)
    end

end




% time=input(1)
% if time>2.8
% savedInputs=evalin('base','savedInputs')
% savedOutputs=evalin('base','savedOutputs')
% action=input(2:5);
% state=input(6:16);
% output=input(17:27);
% 
% stateEst=simulateNominal(state,action);
% trainingIn=[[action;stateEst],savedInputs];
% size(trainingIn)
% trainingOut=[output,savedOutputs];
% assignin('base','savedInputs',trainingIn)
% assignin('base','savedOutputs',trainingOut)
% 
% hiddenLayerSize = [10];
% netFail2SimulinkUpdate = fitnet(hiddenLayerSize)
% netFail2SimulinkUpdate.trainParam.epochs = 10
% netFail2SimulinkUpdate.layers{1}.transferFcn = 'purelin';
% netFail2SimulinkUpdate.divideFcn = 'divideind';
% netFail2SimulinkUpdate.divideParam.trainInd = 1:16;
% netFail2SimulinkUpdate.divideParam.valInd = [];
% netFail2SimulinkUpdate.divideParam.testInd = [];
%  %Train the Network
% [netFail2SimulinkUpdate,trFail2] = train(netFail2SimulinkUpdate,trainingIn,trainingOut);
%end