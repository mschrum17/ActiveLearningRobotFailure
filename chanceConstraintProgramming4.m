function [u]= chanceConstraintProgramming4(currentState,uncertainty,ABestGuess,NET,action,samples) 
%     coder.extrinsic('strcat')


    Anominal=[-0.0220400000000000,0.00142200000000000,0,-32.1700000000000,0,0,0,0,0,0,0;
        -0.0575900000000000,-0.394300000000000,871,0,0,0,0,0,0,0,0;
        -9.50000000000000e-05,-0.00179300000000000,-0.546800000000000,0,0,0,0,0,0,0,0;
        0,0,1,0,0,0,0,0,0,0,0;
        0,0,0,0,-0.0639900000000000,0,-1,0.0369100000000000,0,0,0;0,0,0,0,-2.11100000000000,-0.504800000000000,0.193000000000000,0,0,0,0;
        0,0,0,0,0.773200000000000,0.0108700000000000,-0.179400000000000,0,0,0,0;
        0,0,0,0,0,1,0,0,0,0,0;
        0,0,0,0,0,0,1,0,0,0,0;
        1,0,0,0,0,0,0,0,0,0,0;
        0,1,0,0,0,0,0,0,0,0,0];

    Bnominal=[0,1.91000000000000e-05,0,0;
        -18.5800000000000,0,0,0;
        -1.20000000000000,0,0,0;
        0,0,0,0;
        0,0,0,0.00839000000000000;
        0,0,0.184800000000000,0.105600000000000;
        0,0,-0.00869900000000000,-0.459100000000000;
        0,0,0,0;
        0,0,0,0;
        0,0,0,0;
        0,0,0,0];

    DynTotal1=NET{1};
    A1=DynTotal1(5:end,:)*Anominal;
    B1=DynTotal1(1:4,:)'+DynTotal1(5:end,:)'*Bnominal;
    
    DynTotal2=NET{2};
    A2=DynTotal2(5:end,:)*Anominal;
    B2=DynTotal2(1:4,:)'+DynTotal2(5:end,:)'*Bnominal;
    
    DynTotal3=NET{3};
    A3=DynTotal3(5:end,:)*Anominal;
    B3=DynTotal3(1:4,:)'+DynTotal3(5:end,:)'*Bnominal;
    
    t1=.2;
    t2=1;
    
    As=cat(3,A1,A2,A3);
    AAverage=mean(As,3);
    Astd=std(As,[],3);
    
    Bs=cat(3,B1,B2,B3);
    BAverage=mean(Bs,3);
    Bstd=std(Bs,[],3);
    
    ABS=cat(3,[t1*t2*A1^2+(t1+t2)*A1+eye(11) A1*t1*B1*t1+B1*t1 B1*t1],[t1*t2*A2^2+(t1+t2)*A2+eye(11) A2*t1*B2*t1+B2*t1 B2*t1],[t1*t2*A3^2+(t1+t2)*A3+eye(11) A3*t1*B3*t1+B3*t1 B3*t1]);
    STDs=std(ABS,[],3);
    
    STDXk=STDs(:,1:11);
    STDU=STDs(:,12:end);
    
    C=[1 0 0 0 0 0 0 0 0 0 0;
       0 1 0 0 0 0 0 0 0 0 0;
       0 0 1 0 0 0 0 0 0 0 0;
       0 0 0 1 0 0 0 0 0 0 0;
       0 0 0 0 1 0 0 0 0 0 0;
       0 0 0 0 0 1 0 0 0 0 0;
       0 0 0 0 0 0 1 0 0 0 0;
       0 0 0 0 0 0 0 1 0 0 0;
       0 0 0 0 0 0 0 0 1 0 0;
       0 0 0 0 0 0 0 0 0 0 1];
   
    xref=[.5;0;0;0;0;0;0;0;0;0];
    r=[35;5;1.0;10;5;1;5;10;35;300];
    
    %u0=[0;16666;.001;0]
    ur=[10;1000;10;10];
    
    stateSize=10;
    
    SigmaU=C*STDU;
    SigmaXk=C*STDXk;
    
    %xk=[4.84;.002;.0001;.001;0;0;0;.01;-.01;100;1001];
    

    numSamples=1;
    batchSamples=samples(1:4,(end-numSamples+1):end);
    %%%limit this to only certain states

    time=[];
    %for l=1:10
    

    epsilons=[9,10,11,12,13,14];
    p=[norminv(.505),norminv(.6),norminv(.7),norminv(.8),norminv(.9),norminv(.95)]
    numEpsilons=size(epsilons,2);




    variables = {'uk1','uk2','uk3','uk4','uuk1','uuk2','uuk3','uuk4',...
        'delta505','delta6','delta7','delta8','delta9','delta95'};
    N = length(variables); 

    Zs=cell(numSamples,1);
    allZ=[];
    for s=1:numSamples
        zArray=[];
        for ac=1:8
            varName=strcat('z',sprintf('%d',ac),sprintf('%d',s));
            N=length(variables);
            variables(N+1)={varName};
            zArray=[zArray,N+1];
            allZ=[allZ,N+1];
        end
        Zs{s}=zArray;
    end

    Ys=cell(numSamples,1);
    allY=[];
    for s=1:numSamples
        yArray=[];
        for ac=1:8
            varName=strcat('y',num2str(ac),num2str(s));
            N=length(variables);
            variables(N+1)={varName};
            yArray=[yArray,N+1];
            allY=[allY,N+1];
        end
        Ys{s}=yArray;
    end


    % create variables for indexing 
    for v = 1:N 
       eval([variables{v},' = ', num2str(v),';']); 
    end

    uk=[uk1,uk2,uk3,uk4];
    uuk=[uuk1,uuk2,uuk3,uuk4];

    %%bounds on variables
    lb = -Inf(size(variables));
    lb([uk,uuk]) = ...
        [-35,0,-35,-35,-35,0,-35,-35];
    lb(allY)=0;
    lb(epsilons)=0;


    ub = Inf(size(variables));
    ub([uk,uuk]) = ...
        [35,8000000,35,35,35,8000000,35,35];
    ub(allY)=1;
    ub(epsilons)=1;

flag=1
while flag ~=0
    %%Inequality Constraints
    numIneqConstraints=4*stateSize*numEpsilons+numSamples*8*2+16;
    A = zeros(numIneqConstraints,length(variables));
    b=zeros(numIneqConstraints,1);


    A(1:4,uk)=eye(4);b(1:4)=ur+action;
    A(5:8,uk)=-eye(4);b(5:8)=ur-action;

    A(9:12,uk)=-eye(4);A(9:12,uuk)=eye(4);b(9:12)=ur;
    A(13:16,uk)=eye(4);A(13:16,uuk)=-eye(4);b(13:16)=ur;

        MMat=300*eye(8);
        MMat(2,2)=600000;
        MMat(6,6)=600000;
        MVecU=300*ones(8,1);
        MVecU(2)=600000;
        MVecU(6)=600000;
        MVecX=100*ones(stateSize,1);
        MVecX(10)=10000

 
    startChance=16;
    %Chance Consntraints
    for s=0:numEpsilons-1
        index=s*stateSize*4+startChance;
        A(index+1:index+stateSize,epsilons(s+1))=-MVecX; A(index+1:index+stateSize,[uk,uuk])=[C*(AAverage*t1*BAverage*t1+BAverage*t1) C*BAverage*t2]+p(s+1)*SigmaU; b(index+1:index+stateSize)=r+xref-C*(t1*t2*AAverage^2+(t1+t2)*AAverage+eye(11))*currentState-p(s+1)*SigmaXk*abs(currentState);
        A(index+stateSize+1:index+stateSize*2, epsilons(s+1))=-MVecX; A(index+stateSize+1:index+stateSize*2,[uk,uuk])=-[C*(AAverage*t1*BAverage*t1+BAverage*t1) C*BAverage*t2]-p(s+1)*SigmaU; b(index+stateSize+1:index+stateSize*2)=r-xref+C*(t1*t2*AAverage^2+(t1+t2)*AAverage+eye(11))*currentState+p(s+1)*SigmaXk*abs(currentState);
    %  
        A(index+stateSize*2+1:index+stateSize*3,epsilons(s+1))=-MVecX; A(index+stateSize*2+1:index+stateSize*3,[uk,uuk])=[C*(AAverage*t1*BAverage*t1+BAverage*t1) C*BAverage*t2]-p(s+1)*SigmaU; b(index+stateSize*2+1:index+stateSize*3)=r+xref-C*(t1*t2*AAverage^2+(t1+t2)*AAverage+eye(11))*currentState -p(s+1)*SigmaXk*abs(currentState);
        A(index+stateSize*3+1:index+stateSize*4,epsilons(s+1))=-MVecX; A(index+stateSize*3+1:index+stateSize*4,[uk,uuk])=-[C*(AAverage*t1*BAverage*t1+BAverage*t1) C*BAverage*t2]+p(s+1)*SigmaU; b(index+stateSize*3+1:index+stateSize*4)=r-xref+C*(t1*t2*AAverage^2+(t1+t2)*AAverage+eye(11))*currentState+p(s+1)*SigmaXk*abs(currentState);
    end

    startIObjective=numEpsilons*stateSize*4+16+ 1;

    %%Constraints to transform objective function
    for i=0:numSamples-1
        index=startIObjective+16*i;
        A(index:index+7,[uk,uuk])=-1*eye(8); A(index:index+7,Ys{i+1})=MMat; A(index:index+7,Zs{i+1})=eye(8);  b(index:index+7)=-[batchSamples(:,i+1);batchSamples(:,i+1)]+MVecU;
        A(index+8:index+15,[uk,uuk])=eye(8);A(index+8:index+15,Ys{i+1})=-1*MMat;A(index+8:index+15,Zs{i+1})=eye(8); b(index+8:index+15)=[batchSamples(:,i+1);batchSamples(:,i+1)];
    end
    %A(startIObjective:startIObjective+8*numSamples-1,Zs)=eye(8*numSamples);
    %A(startIObjective+8*numSamples:startIObjective+8*numSamples*2-1,Zs)=eye(8*numSamples);


    %%Equality Constraints

    Aeq=zeros(1,length(variables));
    beq=zeros(1,1);

    Aeq(1,delta505:delta505+numEpsilons-1)=1;
    beq=numEpsilons-1;

    %%integer variables
     intcon=[epsilons,allY];

     f=zeros(1,length(variables));
     f(allZ)=-1;
     f(epsilons)=28009*p;

    
     [x fval] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);

     if isempty(x) && flag ~= 2
         flag=2;
         AAverage=Anominal;
         BAverage=Bnominal;
         SigmaU=zeros(10,8);
         SigmaXk=zeros(10,11);
         ur=[1;1000;1;1];
     elseif isempty(x) && flag == 2
         flag=0;
         add=[2*rand()-1;(2*rand()-1)*100;2*rand()-1;2*rand()-1]
         u=[action+add;action-add]
     else
        u=x(1:8);
        flag=0;
     end
     

end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%Uncertainty
     
     elevator=(60).*rand(1,50)-30;
        thrust=(70000).*rand(1,50);
        aileron=(60).*rand(1,50)-30;
        rudder=(60).*rand(1,50)-30;
        goodInputs=[elevator;thrust;aileron;rudder]
      deltaSEst2=simulateNominal(repmat(currentState,1,size(goodInputs,2)),goodInputs);
       %ASum=(NET{1}+NET{2}+NET{3}+NET{4})./4
       deltaS=ABestGuess'*[goodInputs;deltaSEst2];
       y=deltaS*.05+repmat(currentState,1,size(goodInputs,2))
       n=zeros(1,size(goodInputs,2));
       yZ=zeros(11,size(goodInputs,2),4)
      for j=1:size(NET,1)       
           deltaSZ=NET{j}'*[goodInputs;deltaSEst2];
           yZ(:,:,j)=deltaSZ*.05+repmat(currentState,1,size(goodInputs,2))

      end
      yMean=sum(yZ,3)/4
      nFinal=sum(sum(abs((repmat(yMean,1,1,4)-yZ)),3),1);
       [nmax,index]=max(nFinal)
%        uncertainty=nmax
end
