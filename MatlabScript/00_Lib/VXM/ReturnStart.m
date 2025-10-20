function bSuc = ReturnStart(hMotor)
    write(hMotor,'X',"char")
    stepX = str2num(readline(hMotor));
    write(hMotor,'Y',"char")
    stepY = str2num(readline(hMotor));
    write(hMotor,'Z',"char")
    stepZ = str2num(readline(hMotor));

    cmd = 'C,';
    if stepX ~= 0
        cmd = [cmd,'I1M',num2str(-stepX),','];
    end
    if stepY ~= 0
        cmd = [cmd,'I2M',num2str(-stepY),','];
    end        
    if stepZ ~= 0
        cmd = [cmd,'I3M',num2str(-stepZ),','];
    end
    cmd = [cmd,'R'];
    write(hMotor,cmd,"char");
    cMotor = read(hMotor,1,"char");
    bSuc = (cMotor ~= '^');
end