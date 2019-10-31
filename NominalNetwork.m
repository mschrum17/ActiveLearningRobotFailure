% clear all
% %amount of training data
% num=100
% rng(92345)
% 
% %nominal system matrix
% Anominal=[-.02204 .001422 0 -32.17 0 0 0 0;
%           -.05759 -.3943 871 0 0 0 0 0;
%           -.000095 -.001793 -.5468 0 0 0 0 0;
%           0 0 1 0 0 0 0 0;
%           0 0 0 0 -.06399 0 -1 .03691;
%           0 0 0 0 -2.111 -.5048 .193 0;
%           0 0 0 0 .7732 .01087 -.1794 0
%           0 0 0 0 0 1 0 0]
% %nominal control matrix
% Bnominal=[0 .0000191 0 0;
%           -18.58 0 0 0;
%           -1.2 0 0 0;
%           0 0 0 0;
%           0 0 0 .00839;
%           0 0 .1848 .1056;
%           0 0 -.008699 -.4591;
%           0 0 0 0]
% elevator=(20+20).*rand(num,1)-20;
% thrust=(63000).*rand(num,1);
% aileron=(30+30).*rand(num,1)-30;
% rudder=(25+25).*rand(num,1)-25;
% fVel=(200).*rand(num,1);
% vVel=(20).*rand(num,1);
% pRate=(60).*rand(num,1);
% pAngle=(30+30).*rand(num,1)-30;
% sAng=(25).*rand(num,1);
% rRate=(15).*rand(num,1);
% yRate=(30).*rand(num,1);
% rAng=(30+30).*rand(num,1)-30;
% one=(30+30).*rand(num,1)-30;
% two=(30+30).*rand(num,1)-30;
% three=(30+30).*rand(num,1)-30;
% 
% % elevator=rand(num,1);
% % thrust=rand(num,1);
% % aileron=rand(num,1);
% % rudder=rand(num,1);
% % fVel=(180-140)*rand(num,1)+140;
% % vVel=rand(num,1);
% % pRate=rand(num,1);
% % pAngle=rand(num,1);
% % sAng=rand(num,1);
% % rRate=rand(num,1);
% % yRate=rand(num,1);
% % rAng=rand(num,1);
% %randomly sampled actions
% action=[elevator,thrust,aileron,rudder]';
% %randomly sampled states
% state=[fVel,vVel,pRate,pAngle,sAng,rRate,yRate,rAng,one,two,three]';
% 
% %train network with action and state inputs
% trainingInputs=[action;state];
% %train network with state update as targets
% trainingOutputs=zeros(4,num);
% 
% for i=1:num
%     trainingOutputs(:,i)=simulateNominal(state(:,i),action(:,i));
% end

%trainingOutputs=mapstd(trainingOutputs);
% Create a Fitting Network
trainingInputs=inputsTRAINDamaged
trainingOutputs=outputsTRAINDamaged
 
% Create a Fitting Network
%one l3ayer, 10  units
hiddenLayerSize = [10];
net = fitnet(hiddenLayerSize);
net.layers{1}.transferFcn = 'purelin';
% Set up Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,trainingInputs,trainingOutputs);
 
% Test the Network
%estimate the targets
stateNominal = net(trainingInputs);
errors = gsubtract(stateNominal,trainingOutputs);
performance = perform(net,trainingOutputs,stateNominal)
 
% View the Network
view(net)
plot(tr.tperf,'LineWidth',5)
% Plots
% Uncomment these lines to enable various plots.
% figure, plotperform(tr)
% figure, plottrainstate(tr)
% figure, plotfit(targets,outputs)
% figure, plotregression(targets,outputs)
% figure, ploterrhist(errors)




