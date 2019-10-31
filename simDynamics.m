function dynamics=simDynamics(posteriors)
    dynamics=zeros(11,15)
    for i=1:11
        dynamics(i,:)=simulate(posteriors{i})
    end
end
