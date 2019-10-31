function PosteriorMd1=dynamicsEst(x,y,u)
p = 15;
PriorMdl = bayeslm(p,'ModelType','conjugate','Intercept',false)    

PosteriorMd1 = estimate(PriorMdl,x,y);
    

    end
