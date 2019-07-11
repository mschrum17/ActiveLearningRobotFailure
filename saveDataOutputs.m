function []= saveDataOutputs(outputs)
    time=outputs(1);
    if time>20
        savedOuputs=evalin('base','savedOutputs');
        savedOuputs=[savedOuputs,outputs(2:end,1)];
        assignin('base','savedOutputs',savedOuputs);
    end
