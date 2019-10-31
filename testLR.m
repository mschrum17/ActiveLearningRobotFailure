X=inputsTRAINDamaged(:,1:50)'
Y=outputsTRAINDamaged(:,1:50)'
A=X\Y
y=A'*inputsTRAINDamaged(:,51)
y2=ABestGuess'*inputsTRAINDamaged(:,51)