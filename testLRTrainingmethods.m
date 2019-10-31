pAMaxChange2=[]
allError=zeros(30,100)

for i=1:30
error=[]
    A=AsBadPolicy{i}
    
    for j=1:100
        testOut=A'*inputsTRAINDamaged(:,j);
        e=(norm(testOut-outputsTRAINDamaged(:,j),2))
        j
        error=[error e];
    end
    allError(i,:)=error
    errorTotal=mean(error)
    pAMaxChange2=[pAMaxChange2 errorTotal]
end

    