function dyn=calcDynamics(x,y)
APrior=evalin('base','APrior')
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


dyn=simDynamics(posts)





