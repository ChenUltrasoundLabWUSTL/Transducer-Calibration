function sigChB = PicoConvert(hApp)
    invoke(hApp.hBlockObj, 'runBlock', 0);
    [~, ~, ~, sigChB,~,~] = invoke(hApp.hBlockObj, 'getBlockData',...
        0,... % startIndex
        0,... % segmentIndex
        1,... % downsamplingRatio
        hApp.infoEnum.enPS5000ARatioMode.PS5000A_RATIO_MODE_NONE);
end