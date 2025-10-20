%% Scanning paprameters
lenSample = 5000;

 boundX = [-3,3];
 boundY = [-1,1];
 boundZ = [1,1];
% 
% resX = 0.2;
% resY = 0.1;
% resZ = 0.1;

%boundX = [0,0];
%boundY = [-25,25];
%boundZ = [-25,25];

resX = .1;
resY = 0.05;
resZ = 0.05;

posStart =[0, 0, 0];

iCntX = round(abs(boundX(1)-boundX(2)) / resX) + 1;
iCntY = round(abs(boundY(1)-boundY(2)) / resY) + 1;
iCntZ = round(abs(boundZ(1)-boundZ(2)) / resZ) + 1;

axisX = linspace(boundX(1), boundX(2), iCntX);
axisY = linspace(boundY(1), boundY(2), iCntY);
axisZ = linspace(boundZ(1), boundZ(2), iCntZ);

%% Open serial port for VXM
addpath('..\00_Lib\VXM\');

hMotor = serialport("COM4",9600, 'Timeout', 60);
configureTerminator(hMotor,"CR")
write(hMotor,'F',"char");
write(hMotor,'N',"char");
seqIdx = GetCubicTraj([iCntX,iCntY,iCntZ],[3,2,1]);

%% PicoScope initialize
addpath('..\00_Lib\PicoScope\');

[~, ~, infoEnum, ~] = ps5000aMFile_win64(); 

hPicoScope = icdevice('picotech_ps5000a_generic', '');
connect(hPicoScope);

[status.chA] = invoke(hPicoScope, 'ps5000aSetChannel', ...
                      infoEnum.enPS5000AChannel.PS5000A_CHANNEL_A, ...
                      PicoConstants.ENABLE, ...
                      infoEnum.enPS5000ACoupling.PS5000A_AC, ...
                      infoEnum.enPS5000ARange.PS5000A_100MV, ...
                      0.0);

[status.chB] = invoke(hPicoScope, 'ps5000aSetChannel', ...
                      infoEnum.enPS5000AChannel.PS5000A_CHANNEL_B, ...
                      PicoConstants.DISABLE, ...
                      infoEnum.enPS5000ACoupling.PS5000A_AC, ...
                      1, ...
                      0.0);

% Set device resolution
% Only using one channel the maximum depth is 16 bit
invoke(hPicoScope, ...
      'ps5000aSetDeviceResolution',...
       16);

timebase = round(1/20 * 62.5 + 3);

[~, tNs, ~] = invoke(hPicoScope, ...
                     'ps5000aGetTimebase2',...
                     timebase, ...
                     0);
fprintf(['Sample freqeuncy of PicoScope is ',num2str(1e3/double(tNs)),' MHz\n']);
set(hPicoScope, 'timebase', timebase);

fsPico = 1/tNs * 1e9;

% Setup trigger
triggerGroupObj = get(hPicoScope, 'Trigger');
triggerGroupObj = triggerGroupObj(1);
% Disable auto trigger
set(triggerGroupObj, 'autoTriggerMs', 0);

invoke(triggerGroupObj, 'setSimpleTrigger',...
       infoEnum.enPS5000AChannel.PS5000A_EXTERNAL, ...
       1000,... % 1000 mv threshold
       infoEnum.enPS5000AThresholdDirection.PS5000A_RISING);

set(hPicoScope, 'numPreTriggerSamples', 0);
set(hPicoScope, 'numPostTriggerSamples', lenSample);


hBlockObj = get(hPicoScope, 'Block');
hBlockObj = hBlockObj(1);

hRapidBlockObj = get(hPicoScope, 'Rapidblock');
hRapidBlockObj = hRapidBlockObj(1);


%% Ready bin file to write
clockTime = char(datetime("now", 'Format', 'yyyyMMddHHmmss'));
% Open Binary file for raw data
nameRaw = ['D:\Raw',clockTime,'.bin'];
hFile = fopen(nameRaw,"w");

iCntTotalPoint = length(axisX) * length(axisY) *length(axisZ);
posCurrent = posStart;

fwrite(hFile, iCntTotalPoint, "double");
fwrite(hFile,tNs,"double");
fwrite(hFile,lenSample,"double");

for idxPoint = 1:size(seqIdx,1)
    posNext = [axisX(seqIdx(idxPoint,1)),axisY(seqIdx(idxPoint,2)),axisZ(seqIdx(idxPoint,3))];

    invoke(hBlockObj, 'ps5000aRunBlock', 0);    % Start the sampling of PicoScope
    MoveTo(hMotor,posCurrent,posNext);          % Motor move to destination
    % Wait picoscope for tWait seconds
    ready = 0; 
    tWait = 20;
    tic;
    while ~ready 
        [~,ready] = invoke(hBlockObj, 'ps5000aIsReady');
        if toc > tWait && ~ready
            invoke(hPicoScope, 'ps5000aStop');
            break;
        end
        bValidData = true;
    end
    
    if bValidData
        [~, ~, sig, ~,~,~] = invoke(hBlockObj, 'getBlockData',...
        0,... % startIndex
        0,... % segmentIndex
        1,... % downsamplingRatio
        infoEnum.enPS5000ARatioMode.PS5000A_RATIO_MODE_NONE);
        fwrite(hFile,posNext,"double");
        fwrite(hFile,sig(1:lenSample),"double");
    end     

    posCurrent = posNext;
end

ReturnStart(hMotor);
fclose(hFile);

%% Open saved file and process

hFile = fopen(nameRaw,'r');
iCntMeasure = fread(hFile,1,"double");
tNs = fread(hFile,1,"double");
lenSig = fread(hFile,1,"double");

resCube = zeros(iCntX,iCntY,iCntZ);


for idxTrans = 1:iCntMeasure

    lenLine = fprintf(['Current: ',num2str(idxTrans), ', ',...
        num2str(iCntMeasure-idxTrans),' left.\n']);
    pos = fread(hFile,3,"double");
    sig = fread(hFile,lenSig,"double");

    idxX = seqIdx(idxTrans,1);
    idxY = seqIdx(idxTrans,2);
    idxZ = seqIdx(idxTrans,3);

    resCube(idxX,idxY,idxZ) = abs(max(sig(40:end)) - min(sig(200:end)));

    fprintf(repmat('\b',1,lenLine))
end

fclose(hFile);

lineSample = reshape(resCube,1,iCntX*iCntY*iCntZ);
valMax = max(lineSample);
valMin = min(lineSample);


%% Moving motor to maximum
[~, linearIndex] = max(resCube(:));
[idxMaxX, idxMaxY, idxMaxZ] = ind2sub(size(resCube), linearIndex);
MoveTo(hMotor,[0,0,0],[axisX(idxMaxX),axisY(idxMaxY),axisZ(idxMaxZ)]);  



%% Generate vedio 
videoName = [nameRaw(1:end-3),'avi'];
hVideo = VideoWriter(videoName);
hVideo.FrameRate = 1;
open(hVideo);

for idxFrame = 1:iCntX
    hFig = figure;
    hAxes = axes('Parent',hFig);
    hold(hAxes,'on');

    bufImage = squeeze(resCube(idxFrame,:,:));
    imagesc('XData',axisY,'YData',axisZ,'CData',bufImage);

    ylabel('Y (mm)');
    xlabel('Z (mm)');

    title([ 'X : ', num2str(axisX(idxFrame)),' mm']);
    xlim(hAxes,[boundY(1) boundY(2)]);
    ylim(hAxes,[boundZ(1) boundZ(2)]);

    colorbar(hAxes);
    caxis([valMin valMax]);

    frame = getframe(hFig);
    writeVideo(hVideo,frame);
    close(hFig);
end

close(hVideo);





%% Clean up after calibration
invoke(hPicoScope, 'ps5000aStop');
disconnect(hPicoScope);
delete(hPicoScope);
delete(hMotor);





function bSuc = MoveTo(hMotor,locCurrrent,locNext)
    STEP_SIZE_MM = 6.35e-3;
    locChange = locNext-locCurrrent;
    locChange = round(locChange/STEP_SIZE_MM);
    cmd = 'C,';
    if locChange(1) ~= 0
        cmd = [cmd,'I1M',num2str(locChange(1)),','];
    end
    if locChange(2) ~= 0
        cmd = [cmd,'I2M',num2str(locChange(2)),','];
    end        
    if locChange(3) ~= 0
        cmd = [cmd,'I3M',num2str(locChange(3)),','];
    end
    cmd = [cmd,'R'];
    write(hMotor,cmd,"char");
    cMotor = read(hMotor,1,"char");
    bSuc = (cMotor == '^');
end

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
    bSuc = (cMotor == '^');
end



