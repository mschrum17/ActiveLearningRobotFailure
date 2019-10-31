allErrorDifferent2=zeros(49,100)
for i=1:size(allErrorChange,1)
    allErrorDifferent2(i,:)=sum(allErrorDifferent(1:i,:),1)
end