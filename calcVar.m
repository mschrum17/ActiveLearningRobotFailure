function var=calcVar(x,y,posX)

p = 15;
PriorMdl = bayeslm(p,'ModelType','conjugate','Intercept',false)

%%%%%%%goooooood
%x = randn(15,15)
%Anominal=[-0.0220400000000000,0.00142200000000000,0,-32.1700000000000,0,0,0,0,0,0,0, 0,1.91000000000000e-05,0,0]

%y = x*Anominal' 
%PosteriorMdl = estimate(PriorMdl,inputsTRAINNominal',outputsTRAINDamaged(1,:)');
%a=simulate(PosteriorMdl)'
posts=cell(11,1)
for i=1:11
    posts{i}=dynamicsEst(x',y(i,:)')'
end

num=50
yVar=zeros(size(posX,2),1)
for i=1:size(posX,2)
    yEst=zeros(11,num)
    for j=1:num 
        dynamics=simDynamics(posts)
        yEst(:,j)=dynamics*posX(:,i)
    end
    yMean=mean(yEst,2)
    assignin('base','yOut',yMean)
    yVar(i)=sum(sum(abs(yEst-yMean)))/(11*num);
end
var=yVar;




