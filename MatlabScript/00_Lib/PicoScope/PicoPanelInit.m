function PicoPanelInit(hApp,varargin)

%% Init dropdown 
hApp.DropDownRange.Items = {'10 mV', '20 mV', '50 mV', '100 mV'...
                           '200 mV', '500 mV', '1 V', '2 V',...
                           '5 V', '10 V', '20 V', '50 V', 'MAX'};
cntItems = length(hApp.DropDownRange.Items);
dataRange = (1:cntItems) - 1;
hApp.DropDownRange.ItemsData = num2cell(dataRange);

hApp.hPicoScope = [];
hApp.hBlockObj = [];

%% Default values for 

if isempty(varargin{1})
    % Stand alone mode
    hApp.EditFieldPost.Value = 500000;    % #Samples after trigger
    hApp.EditFieldPre.Value = 0;        % #Samples before trigger
    hApp.EditFieldFreqStartSC.Value = 730;    % Start freqeuncy for SC (kHz)
    hApp.EditFieldFreqEndSC.Value = 770;      % End frequency for SC (kHz)
    hApp.EditFieldFreqStartIC.Value = 230;    % Start freqeuncy for SC (kHz)
    hApp.EditFieldFreqEndIC.Value = 270;      % End frequency for SC (kHz)
    hApp.EditFieldFs.Value = 20;              % MHz
elseif isfield(varargin{1},'PicoSetting')
    % App called from mother app
    if isempty(varargin{1}.PicoSetting)
        % In the first run of the main app
        hApp.EditFieldPost.Value =        5000;    
        hApp.EditFieldPre.Value =         0;        
        hApp.EditFieldFreqStartSC.Value = 495;    
        hApp.EditFieldFreqEndSC.Value =   505;     
        hApp.EditFieldFreqStartIC.Value = 245;    
        hApp.EditFieldFreqEndIC.Value =   255;     
        hApp.EditFieldFs.Value =          20;     
    else
        % Previous value stored in the main app
        hApp.EditFieldPost.Value =        varargin{1}.PicoSetting.samplePost;
        hApp.EditFieldPre.Value =         varargin{1}.PicoSetting.samplePre; 
        hApp.EditFieldFreqStartSC.Value = varargin{1}.PicoSetting.freqStartSC;
        hApp.EditFieldFreqEndSC.Value =   varargin{1}.PicoSetting.freqEndSC;
        hApp.EditFieldFreqStartIC.Value = varargin{1}.PicoSetting.freqStartIC;
        hApp.EditFieldFreqEndIC.Value =   varargin{1}.PicoSetting.freqEndIC;
        hApp.EditFieldFs.Value =          varargin{1}.PicoSetting.freqSample;
    end
end

end