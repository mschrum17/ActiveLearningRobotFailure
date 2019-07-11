function []= saveDataInputs(input)
time=input(1)
if time>20
savedInputs=evalin('base','savedInputs');
savedInputs=[savedInputs,input(2:end,1)];
assignin('base','savedInputs',savedInputs);
end
