  % Generate some data  (you can play with changing mean, std, and #points)
  a = 5;                  % true slope
  s = 3;                  % true noise std
  n = 20;                 % # data points
%   x = linspace(-1,1,n)';  % regressor
%   y = a*x + s*randn(n,1); % Simulates fake data
  
  x=100*rand(15,n)-50
  
  
  Anominal=[-0.0220400000000000,0.00142200000000000,0,-32.1700000000000,0,0,0,0,0,0,0;
    -0.0575900000000000,-0.394300000000000,871,0,0,0,0,0,0,0,0;
    -9.50000000000000e-05,-0.00179300000000000,-0.546800000000000,0,0,0,0,0,0,0,0;
    0,0,1,0,0,0,0,0,0,0,0;
    0,0,0,0,-0.0639900000000000,0,-1,0.0369100000000000,0,0,0;
    0,0,0,0,-2.11100000000000,-0.504800000000000,0.193000000000000,0,0,0,0;
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
y=Anominal*x(5:15,:)+Bnominal*x(1:4,:)+s*randn(11,n)
x=x'
y=y'

  % plot likelihood
  va=zeros(15,15,1000)
  va=repmat(linspace(-30,30,1000),15,15,1000)
  %va=linspace(-30,30,1000);N=length(va);
  li = exp(-.5*sum((repmat(y,1,N)-x*va).^2,1)/s^2);
  li = li/sum(li);

  figure,
  hold on
  hli = plot(va,li,'r','linewidth',2);

  % prior
  a0  = 0;
  s0  = 3;
  pr  = exp(-.5*(va-a0).^2./s0^2);
  pr  = pr/sum(pr);
  hpr = plot(va,pr,'b','linewidth',2);

  % posterior
  beta  = 1/s^2;
  beta0 = 1/s0^2;

  sp    = 1/(beta0+beta*(x'*x));
  ap    = ( beta0*a0 + beta*x'*y  ) / (beta0 + beta*(x'*x));
  
  po  = normpdf(va,ap,sp);
  po  = po/sum(po);
  hpo = plot(va,po,'k','linewidth',2);
  
  legend([hli hpr hpo],{'likelihood','prior','posterior'},'orientation','horizontal');
  
  axis([-10 10 0 max(po)])
  
  
    figure
  axis([-1 1 -5 5])
  plot(x,y,'k.','markersize',20); % draw data points
  for i=1:20
  samp  = normrnd(a0,s0);   % from prior
  l1=line([-1 1],samp*[-1 1],'color','b','linestyle','--');
  samp  = normrnd(ap,sp);   % from posterior
  l2=line([-1 1],samp*[-1 1],'color','k');
  end
  legend([l1 l2],{'from prior','from posterior'},'orientation','horizontal');  