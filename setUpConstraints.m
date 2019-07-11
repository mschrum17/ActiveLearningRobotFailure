function [c ceq]=setUpConstraints(action)
    currentState=evalin('base','currentState');
    uncertainty=evalin('base','uncertainty')
    desired=[160;0;0;0];
    safetyBuffer=[40,10,-50];
%     if uncertainty<100
%         safetyBuffer=safetyBuffer*(uncertainty/100)^.5
%     end
    assignin('base','safetyBuffer',safetyBuffer)
    stateEst=simulateNominal(currentState,action')
    y1=simDamage([action';stateEst])
%     c=[y1(1)-desired-safetyBuffer(1);desired-safetyBuffer(1)-y1(1);
%         abs(y1(4)-safetyBuffer(2));abs(y1(8)-safetyBuffer(2));abs(y1(9)-safetyBuffer(2));
%         safetyBuffer(3)-y1(11)];
c=[]
    ceq=[abs(y1(4)-safetyBuffer(2));abs(y1(8)-safetyBuffer(2));abs(y1(9)-safetyBuffer(2))];
    assignin('base','y1',y1)
    
end
