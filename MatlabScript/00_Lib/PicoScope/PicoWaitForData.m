function [sig, bValid] = PicoWaitForData(hApp)
    ready = 0; 
    bValid = false;
    while ~ready 
        [~,ready] = invoke(hApp.hBlockObj, 'ps5000aIsReady');
        if hApp.ButtonStop.Value
            sig = [];
            return
        end
        drawnow
    end

    [~, ~, sig, ~,~,~] = invoke(hApp.hBlockObj, 'getBlockData',...
    0,... % startIndex
    0,... % segmentIndex
    1,... % downsamplingRatio
    hApp.infoEnum.enPS5000ARatioMode.PS5000A_RATIO_MODE_NONE);
    bValid = true;
end