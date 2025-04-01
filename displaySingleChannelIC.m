% Displays data from a single electrode

% In case the stimulus takes properties from both gabors (such as plaids or
% color stimuli), use sideChoice to specify which of the two side to use
% for each parameter.

function displaySingleChannelIC(subjectName,expDate,protocolName,folderSourceString,gridType,gridLayout,sideChoice,badTrialNameStr,useCommonBadTrialsFlag)

if ~exist('folderSourceString','var');  folderSourceString='F:';        end
if ~exist('gridType','var');            gridType='Microelectrode';      end
if ~exist('gridLayout','var');          gridLayout=2;                   end
if ~exist('sideChoice','var');          sideChoice=[];                  end
if ~exist('badTrialNameStr','var');     badTrialNameStr = 'V1';        end
if ~exist('useCommonBadTrialsFlag','var'); useCommonBadTrialsFlag = 1;  end

folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);

% Get folders
folderImage = fullfile(folderSourceString, 'data/images/New_sets/T');
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');

% load LFP Information
[analogChannelsStored,timeVals,~,analogInputNums] = loadlfpInfo(folderLFP);
[neuralChannelsStored,SourceUnitIDs] = loadspikeInfo(folderSpikes);

% Get Combinations
[~,aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract,sideChoice);

% Get properties of the Stimulus
% stimResults = loadStimResults(folderExtract);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display main options
% fonts
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UI
aspectRatio = 16/9;
UI.lr_margin = 2.5e-2;
UI.ud_margin = 2.5e-2;
UI.spacing = 1.25e-2;

% Electrode Grid
panel.grid.x = UI.lr_margin; 
panel.grid.height = 0.34*(7/13); % Rescaling the V4/V1 grid height for V1|V4 rearrangement
panel.grid.y = (1 - 2*UI.ud_margin) - panel.grid.height; 
panel.grid.width = panel.grid.height*(17/6)*(1/aspectRatio); % Rescaling the grid width for V1|V4 rearrangement, while keeping approx. square spacing according to the monitor's aspect ratio

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Static Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%staticTitle = [subjectName '_' expDate '_' protocolName];
% if 0 % don't plot the static panel
%     hStaticPanel = uipanel('Title','Information','fontSize', fontSizeLarge, ...
%         'Unit','Normalized','Position',[staticStartPos panelStartHeight staticPanelWidth panelHeight]);
% 
%     staticText = [{ '   '};
%         {['Monkey Name: ' subjectName]}; ...
%         {['Date: ' expDate]}; ...
%         {['Protocol Name: ' protocolName]}; ...
%         {'   '}
%         {['Orientation  (Deg): ' num2str(stimResults.orientation)]}; ...
%         {['Spatial Freq (CPD): ' num2str(stimResults.spatialFrequency)]}; ...
%         {['Eccentricity (Deg): ' num2str(stimResults.eccentricity)]}; ...
%         {['Polar angle  (Deg): ' num2str(stimResults.polarAngle)]}; ...
%         {['Sigma        (Deg): ' num2str(stimResults.sigma)]}; ...
%         {['Radius       (Deg): ' num2str(stimResults.radius)]}; ...
%         ];
% 
%     tStaticText = uicontrol('Parent',hStaticPanel,'Unit','Normalized', ...
%         'Position',[0 0 1 1], 'Style','text','String',staticText,'FontSize',fontSizeSmall);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Parameters & Options Panel %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynamicHeight = 0.24; dynamicGap=3e-2; dynamicTextWidth = 0.2; titleGap = 0.1;

panel.param.x = panel.grid.x + panel.grid.width + UI.spacing;
panel.param.y = panel.grid.y + panel.grid.height/2;
panel.param.width = (1 - (panel.param.x + UI.spacing + UI.lr_margin))/2;
panel.param.height = panel.grid.height/2;
paramPanelPos = [panel.param.x, panel.param.y, panel.param.width, panel.param.height];

hDynamicPanel = uipanel('Title','Parameters','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',paramPanelPos);

% Analog channel
[analogChannelStringList,analogChannelStringArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-(dynamicHeight+dynamicGap)-titleGap dynamicTextWidth dynamicHeight],...
    'Style','text','String','Analog Channel','HorizontalAlignment','left','FontSize',fontSizeSmall);
hAnalogChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-(dynamicHeight+dynamicGap)-titleGap 0.5-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analogChannelStringList,'FontSize',fontSizeSmall);

% Neural channel
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0.5 1-(dynamicHeight+dynamicGap)-titleGap dynamicTextWidth dynamicHeight],...
    'Style','text','String','Neural Channel','FontSize',fontSizeSmall);
    
if ~isempty(neuralChannelsStored)
    neuralChannelString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs);
    hNeuralChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0.5+dynamicTextWidth 1-(dynamicHeight+dynamicGap)-titleGap 0.5-dynamicTextWidth dynamicHeight],...
        'Style','popup','String',neuralChannelString,'FontSize',fontSizeSmall);
else
    hNeuralChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0.5+dynamicTextWidth 1-(dynamicHeight+dynamicGap)-titleGap 0.5-dynamicTextWidth dynamicHeight],...
        'Style','text','String','Not found','FontSize',fontSizeSmall);
end
%{
% Sigma
sigmaString = getStringFromValues(sValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Sigma (Deg)','FontSize',fontSizeSmall);
hSigma = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',sigmaString,'FontSize',fontSizeSmall);

% Spatial Frequency
spatialFreqString = getStringFromValues(fValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Spatial Freq (CPD)','FontSize',fontSizeSmall);
hSpatialFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-4*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',spatialFreqString,'FontSize',fontSizeSmall);

% Orientation
orientationString = getStringFromValues(oValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Orientation (Deg)','FontSize',fontSizeSmall);
hOrientation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',orientationString,'FontSize',fontSizeSmall);

% Contrast
contrastString = getStringFromValues(cValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-6*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Contrast (%)','FontSize',fontSizeSmall);
hContrast = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-6*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',contrastString,'FontSize',fontSizeSmall);

% Temporal Frequency
temporalFreqString = getStringFromValues(tValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-7*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Temporal Freq (Hz)','FontSize',fontSizeSmall);
hTemporalFreq = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-7*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',temporalFreqString,'FontSize',fontSizeSmall);
%}
% Stim Type
stimTypeString = 'Color|Grayscale';
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-2*(dynamicHeight+dynamicGap)-titleGap dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Stim Type','HorizontalAlignment','left','FontSize',fontSizeSmall);
hStimType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-2*(dynamicHeight+dynamicGap)-titleGap 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',stimTypeString,'FontSize',fontSizeSmall);

% Analysis Type
analysisTypeString = 'ERP|FFT|deltaFFT|TF|deltaTF|Raster|FR|FFT(ERP)|deltaFFT(ERP)|STA';
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap)-titleGap dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Analysis Type','HorizontalAlignment','left','FontSize',fontSizeSmall);
hAnalysisType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-3*(dynamicHeight+dynamicGap)-titleGap 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analysisTypeString,'FontSize',fontSizeSmall);
%{
% For orientation and SF
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-9.5*(dynamicHeight+dynamicGap) 1 dynamicHeight],...
    'Style','text','String','For sigma,ori,SF,C & TF plots','FontSize',fontSizeSmall);
% Azimuth
azimuthString = getStringFromValues(aValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-10.5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight],...
    'Style','text','String','Azimuth (Deg)','FontSize',fontSizeSmall);
hAzimuth = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-10.5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',azimuthString,'FontSize',fontSizeSmall);

% Elevation
elevationString = getStringFromValues(eValsUnique,1);
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-11.5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Elevation (Deg)','FontSize',fontSizeSmall);
hElevation = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-11.5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',elevationString,'FontSize',fontSizeSmall);

% Reference scheme
referenceChannelStringList = ['None|AvgRef|' analogChannelStringList];
referenceChannelStringArray = [{'None'} {'AvgRef'} analogChannelStringArray];

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-12.5*(dynamicHeight+dynamicGap) dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Reference','FontSize',fontSizeSmall);
hReferenceChannel = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-12.5*(dynamicHeight+dynamicGap) 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',referenceChannelStringList,'FontSize',fontSizeSmall);
%}
% Options Panel (w/o title)
panel.opt.x = panel.param.x;
panel.opt.y = panel.grid.y;
panel.opt.width = panel.param.width;
panel.opt.height = panel.param.height;
optPanelPos = [panel.opt.x, panel.opt.y, panel.opt.width, panel.opt.height];

hOptionsPanel = uipanel('Unit','Normalized','Position',optPanelPos);

% Plot Color
[colorString, colorNames] = getColorString;
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 1-dynamicHeight dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Color','HorizontalAlignment','left','FontSize',fontSizeSmall);
hChooseColor = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-dynamicHeight 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',colorString,'FontSize',fontSizeSmall);

% Clear All
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 2*dynamicHeight 0.5 dynamicHeight+dynamicGap], ...
    'Style','pushbutton','String','Clear','FontSize',fontSizeMedium, ...
    'Callback',{@cla_Callback});

% Hold On
hHoldOn = uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 dynamicHeight 0.5 dynamicHeight+dynamicGap], ...
    'Style','togglebutton','String','Hold','FontSize',fontSizeMedium, ...
    'Callback',{@holdOn_Callback});

% Plot
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0 0 0.5 dynamicHeight+dynamicGap], ...
    'Style','pushbutton','String','Plot','FontSize',fontSizeMedium, ...
    'Callback',{@plotData_Callback});

% Rescale XYZ
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 2*dynamicHeight 0.5 dynamicHeight+dynamicGap], ...
    'Style','pushbutton','String','Rescale X','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleData_Callback});
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 dynamicHeight 0.5 dynamicHeight+dynamicGap], ...
    'Style','pushbutton','String','Rescale Y','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleY_Callback});
uicontrol('Parent',hOptionsPanel,'Unit','Normalized', ...
    'Position',[0.5 0 0.5 dynamicHeight+dynamicGap], ...
    'Style','pushbutton','String','Rescale Z','FontSize',fontSizeMedium, ...
    'Callback',{@rescaleZ_Callback});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Timing Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
panel.tim.x = panel.param.x + panel.param.width + UI.spacing;
panel.tim.y = panel.opt.y;
panel.tim.width = panel.param.width;
panel.tim.height = panel.grid.height;
timingPanelPos = [panel.tim.x, panel.tim.y, panel.tim.width, panel.tim.height];

hTimingPanel = uipanel('Title','Timing                                         Min                     Max',...
    'fontSize', fontSizeLarge,'Unit','Normalized','Position',timingPanelPos);

% Signal Range
signalRange = [-0.2 1];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-(dynamicHeight+dynamicGap)/2-titleGap/2 0.5 dynamicHeight/2], ...
    'Style','text','String','Signal Range (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hStimMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(signalRange(1)),'FontSize',fontSizeSmall);
hStimMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(signalRange(2)),'FontSize',fontSizeSmall);

% Baseline
baseline = [-0.5 0];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-2*(dynamicHeight+dynamicGap)/2-titleGap/2 0.5 dynamicHeight/2], ...
    'Style','text','String','Baseline Duration (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hBaselineMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-2*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(baseline(1)),'FontSize',fontSizeSmall);
hBaselineMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-2*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(baseline(2)),'FontSize',fontSizeSmall);

% Stim Period
stimPeriod = [0.25 0.75];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap)/2-titleGap/2 0.5 dynamicHeight/2], ...
    'Style','text','String','Stimulus Duration (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hStimPeriodMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-3*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(stimPeriod(1)),'FontSize',fontSizeSmall);
hStimPeriodMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-3*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(stimPeriod(2)),'FontSize',fontSizeSmall);

% FFT Range
fftRange = [0 100];
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-4*(dynamicHeight+dynamicGap)/2-titleGap/2 0.5 dynamicHeight/2], ...
    'Style','text','String','FFT Range (Hz)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hFFTMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-4*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(fftRange(1)),'FontSize',fontSizeSmall);
hFFTMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-4*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(fftRange(2)),'FontSize',fontSizeSmall);

% Y Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-5*(dynamicHeight+dynamicGap)/2-titleGap/2 0.5 dynamicHeight/2], ...
    'Style','text','String','Y Range','HorizontalAlignment','left','FontSize',fontSizeSmall);
hYMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-5*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hYMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-5*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);

% Z Range
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-6*(dynamicHeight+dynamicGap)/2-titleGap/2 0.5 dynamicHeight/2], ...
    'Style','text','String','Z Range','HorizontalAlignment','left','FontSize',fontSizeSmall);
hZMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-6*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String','0','FontSize',fontSizeSmall);
hZMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-6*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String','1','FontSize',fontSizeSmall);

% STA length
staLen = [-0.05 0.05]; 
uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0 1-7*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','text','String','STA Length (s)','HorizontalAlignment','left','FontSize',fontSizeSmall);
hSTAMin = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.5 1-7*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(staLen(1)),'FontSize',fontSizeSmall);
hSTAMax = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.75 1-7*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','edit','String',num2str(staLen(2)),'FontSize',fontSizeSmall);
hRemoveMeanSTA = uicontrol('Parent',hTimingPanel,'Unit','Normalized', ...
    'Position',[0.25 1-7*(dynamicHeight+dynamicGap)/2-titleGap/2 0.25 dynamicHeight/2], ...
    'Style','togglebutton','String','Remove Mean STA','FontSize',fontSizeSmall);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get plots and message handles

% Get electrode array information
electrodeGridPos = [panel.grid.x, panel.grid.y, panel.grid.width, panel.grid.height];
hElectrodes = showElectrodeLocations(electrodeGridPos,analogChannelsStored(get(hAnalogChannel,'val')), ...
    colorNames(get(hChooseColor,'val')),[],1,0,gridType,subjectName,gridLayout);

% Make plot for RFMap, centerRFMap and main Map

% if length(aValsUnique)>=5
%     mapRatio = 2/3; % this sets the relative ratio of the mapping plots versus orientation plots
% else
%     mapRatio = 1/2;
% end

gap = 2e-3;
tile.x = UI.lr_margin; 
tile.y = UI.ud_margin;
tile.width = 1-2*UI.lr_margin;
tile.height = 0.55 + UI.ud_margin;
tilePos = [tile.x, tile.y, tile.width, tile.height];
%otherPlotsWidth = (1-mapRatio)*(endXPos-startXPos-centerGap);

% RF and centerRF
% RFMapPos = [endXPos-mainRFWidth startYPos+(3/4)*mainRFHeight mainRFWidth/2 (1/4)*mainRFHeight];
% hRFMapPlot = subplot('Position',RFMapPos,'XTickLabel',[],'YTickLabel',[],'box','on');
% centerRFMapPos = [endXPos-mainRFWidth+mainRFWidth/2 startYPos+(3/4)*mainRFHeight mainRFWidth/2 (1/4)*mainRFHeight];
% hcenterRFMapPlot = subplot('Position',centerRFMapPos,'XTickLabel',[],'YTickLabel',[],'box','on');

% Main plot handles
numTypes = 6;
numImages = (length(oValsUnique)/numTypes)/length(string(strsplit(stimTypeString, '|')));
numRows = numTypes; numCols = numImages;
plotHandles = getPlotHandles(numRows,numCols,tilePos,gap);

uicontrol('Unit','Normalized','Position',[0 1-UI.ud_margin 1 UI.ud_margin],...
    'Style','text','String',[subjectName expDate protocolName],'FontSize',fontSizeLarge);

% Other functions

% % Remaining Grid size
% remainingWidth = otherPlotsWidth;
% remainingHeight= mainRFHeight;
% 
% otherGapSize = 0.04;
% otherHeight = (remainingHeight-4*otherGapSize)/5;
% 
% temporalFreqGrid = [startXPos startYPos                               remainingWidth otherHeight];
% contrastGrid     = [startXPos startYPos+ (otherHeight+otherGapSize)   remainingWidth otherHeight];
% spatialFreqGrid  = [startXPos startYPos+ 2*(otherHeight+otherGapSize) remainingWidth otherHeight];
% orientationGrid  = [startXPos startYPos+ 3*(otherHeight+otherGapSize) remainingWidth otherHeight];
% sigmaGrid        = [startXPos startYPos+ 4*(otherHeight+otherGapSize) remainingWidth otherHeight];
% 
% % Plot handles
% hTemporalFreqPlot = getPlotHandles(1,length(tValsUnique),temporalFreqGrid,0.002);
% hContrastPlot     = getPlotHandles(1,length(cValsUnique),contrastGrid,0.002);
% hOrientationPlot  = getPlotHandles(1,length(oValsUnique),orientationGrid,0.002);
% hSpatialFreqPlot  = getPlotHandles(1,length(fValsUnique),spatialFreqGrid,0);
% hSigmaPlot        = getPlotHandles(1,length(sValsUnique),sigmaGrid,0.002);

if isfile("cmap.mat"), colormap(load("cmap.mat").("icefire")), else colormap turbo, end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)
        a=1;
        e=1;
        s=1;
        f=1;
        o=length(oValsUnique)+1;
        c=1;
        t=1;
        analysisType = string(strsplit(analysisTypeString, '|'));
        analysisType = analysisType(get(hAnalysisType,'val'));
        plotColor = colorNames(get(hChooseColor,'val'));
        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
        staRange = [str2double(get(hSTAMin,'String')) str2double(get(hSTAMax,'String'))];
        holdOnState = get(hHoldOn,'val');
        removeMeanSTA = get(hRemoveMeanSTA,'val');
        referenceChannelString = 'None';

        if analysisType=="STA" % Spike triggered average
            analogChannelPos = get(hAnalogChannel,'val');
            analogChannelString = analogChannelStringArray{analogChannelPos};
            spikeChannelPos = get(hNeuralChannel,'val');
            spikeChannelNumber = neuralChannelsStored(spikeChannelPos);
            unitID = SourceUnitIDs(spikeChannelPos);
            
            plotColors{1} = 'g';
            plotColors{2} = 'k';
            plotSTA1Channel(plotHandles,analogChannelString,spikeChannelNumber,unitID,folderLFP,folderSpikes,...
                s,f,o,c,t,timeVals,plotColors,blRange,stRange,folderName,staRange,removeMeanSTA,sideChoice);
            
            % Write code for this
            %plotSTA1Parameter1Channel(hOrientationPlot,analogChannelString,spikeChannelNumber,unitID,folderLFP,folderSpikes,...
            %    a,e,s,f,[],timeVals,plotColors,BLMin,BLMax,STMin,STMax,folderName);
            %plotSTA1Parameter1Channel(hSpatialFreqPlot,analogChannelString,spikeChannelNumber,unitID,folderLFP,folderSpikes,...
            %    a,e,s,[],o,timeVals,plotColors,BLMin,BLMax,STMin,STMax,folderName);
            
            if analogChannelPos<=length(analogChannelsStored)
                analogChannelNumber = analogChannelsStored(analogChannelPos);
            else
                analogChannelNumber = 0;
            end
            channelNumber = [analogChannelNumber spikeChannelNumber];
            
        elseif analysisType == "Raster" || analysisType == "FR"
            channelPos = get(hNeuralChannel,'val');
            channelNumber = neuralChannelsStored(channelPos);
            unitID = SourceUnitIDs(channelPos);
            plotSpikeData1Channel(plotHandles,channelNumber,s,f,o,c,t,folderSpikes,...
                analysisType,timeVals,plotColor,unitID,folderName,sideChoice);
            % plotSpikeData1Parameter1Channel(hTemporalFreqPlot,channelNumber,a,e,s,f,o,c,[],folderSpikes,...
            %     analysisType,timeVals,plotColor,unitID,folderName,sideChoice);
            % plotSpikeData1Parameter1Channel(hContrastPlot,channelNumber,a,e,s,f,o,[],t,folderSpikes,...
            %     analysisType,timeVals,plotColor,unitID,folderName,sideChoice);
            % plotSpikeData1Parameter1Channel(hOrientationPlot,channelNumber,a,e,s,f,[],c,t,folderSpikes,...
            %     analysisType,timeVals,plotColor,unitID,folderName,sideChoice);
            % plotSpikeData1Parameter1Channel(hSpatialFreqPlot,channelNumber,a,e,s,[],o,c,t,folderSpikes,...
            %     analysisType,timeVals,plotColor,unitID,folderName,sideChoice);
            % plotSpikeData1Parameter1Channel(hSigmaPlot,channelNumber,a,e,[],f,o,c,t,folderSpikes,...
            %     analysisType,timeVals,plotColor,unitID,folderName,sideChoice);
        else
            analogChannelPos = get(hAnalogChannel,'val');
            analogChannelString = analogChannelStringArray{analogChannelPos};
            plotLFPData1Channel(plotHandles,analogChannelString,s,f,o,c,t,folderLFP,...
                analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
            % plotLFPData1Parameter1Channel(hTemporalFreqPlot,analogChannelString,a,e,s,f,o,c,[],folderLFP,...
            %     analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
            % plotLFPData1Parameter1Channel(hContrastPlot,analogChannelString,a,e,s,f,o,[],t,folderLFP,...
            %     analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
            % plotLFPData1Parameter1Channel(hOrientationPlot,analogChannelString,a,e,s,f,[],c,t,folderLFP,...
            %     analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
            % plotLFPData1Parameter1Channel(hSpatialFreqPlot,analogChannelString,a,e,s,[],o,c,t,folderLFP,...
            %     analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
            % plotLFPData1Parameter1Channel(hSigmaPlot,analogChannelString,a,e,[],f,o,c,t,folderLFP,...
            %     analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);

            if analogChannelPos<=length(analogChannelsStored)
                channelNumber = analogChannelsStored(analogChannelPos);
            else
                channelNumber = 0;
            end
            
            % if ~isempty(rfMapVals)
            %     if (length(aValsUnique)==1) || (length(eValsUnique)==1)
            %         disp('Not enough data to plot RF center...')
            %     else
            %         plotRFMaps(hRFMapPlot,hcenterRFMapPlot,rfMapVals,aValsUnique,eValsUnique,plotColor,holdOnState);
            %     end
            % end
        end

        if ismember(analysisType,  ["ERP", "Raster", "FR", "TF", "deltaTF"]) % ERP or spikes, or TF
            xMin = str2double(get(hStimMin,'String'));
            xMax = str2double(get(hStimMax,'String'));
        elseif analysisType=="STA"
            xMin = str2double(get(hSTAMin,'String'));
            xMax = str2double(get(hSTAMax,'String'));
        else
            xMin = str2double(get(hFFTMin,'String'));
            xMax = str2double(get(hFFTMax,'String'));
        end

        if analysisType~="deltaTF"
            rescaleData(plotHandles,xMin,xMax,getYLims(plotHandles));
            % rescaleData(hTemporalFreqPlot,xMin,xMax,getYLims(hTemporalFreqPlot));
            % rescaleData(hContrastPlot,xMin,xMax,getYLims(hContrastPlot));
            % rescaleData(hOrientationPlot,xMin,xMax,getYLims(hOrientationPlot));
            % rescaleData(hSpatialFreqPlot,xMin,xMax,getYLims(hSpatialFreqPlot));
            % rescaleData(hSigmaPlot,xMin,xMax,getYLims(hSigmaPlot));
        else
            yMin = str2double(get(hFFTMin,'String'));
            yMax = str2double(get(hFFTMax,'String'));
            yRange = [yMin yMax];
            rescaleData(plotHandles,xMin,xMax,yRange);
            % rescaleData(hTemporalFreqPlot,xMin,xMax,yRange);
            % rescaleData(hContrastPlot,xMin,xMax,yRange);
            % rescaleData(hOrientationPlot,xMin,xMax,yRange);
            % rescaleData(hSpatialFreqPlot,xMin,xMax,yRange);
            % rescaleData(hSigmaPlot,xMin,xMax,yRange);
            
            zRange = getZLims(plotHandles);
            set(hZMin,'String',num2str(zRange(1))); set(hZMax,'String',num2str(zRange(2)));
            
            rescaleZPlots(plotHandles,zRange);
            % rescaleZPlots(hTemporalFreqPlot,zRange);
            % rescaleZPlots(hContrastPlot,zRange);
            % rescaleZPlots(hOrientationPlot,zRange);
            % rescaleZPlots(hSpatialFreqPlot,zRange);
            % rescaleZPlots(hSigmaPlot,zRange);
        end
        showElectrodeLocations(electrodeGridPos,channelNumber,plotColor,hElectrodes,holdOnState,0,gridType,subjectName,gridLayout);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleZ_Callback(~,~)

        analysisType = string(strsplit(analysisTypeString, '|'));
        analysisType = analysisType(get(hAnalysisType,'val'));
        
        if ismember(analysisType,  ["TF", "deltaTF"])
            zRange = [str2double(get(hZMin,'String')) str2double(get(hZMax,'String'))];
            rescaleZPlots(plotHandles,zRange);
            % rescaleZPlots(hTemporalFreqPlot,zRange);
            % rescaleZPlots(hContrastPlot,zRange);
            % rescaleZPlots(hOrientationPlot,zRange);
            % rescaleZPlots(hSpatialFreqPlot,zRange);
            % rescaleZPlots(hSigmaPlot,zRange);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleY_Callback(~,~)

        analysisType = string(strsplit(analysisTypeString, '|'));
        analysisType = analysisType(get(hAnalysisType,'val'));
        
        if ismember(analysisType,  ["ERP", "Raster", "FR", "TF", "deltaTF"]) % ERP or spikes, or TF
            xMin = str2double(get(hStimMin,'String'));
            xMax = str2double(get(hStimMax,'String'));
        elseif analysisType=="STA"
            xMin = str2double(get(hSTAMin,'String'));
            xMax = str2double(get(hSTAMax,'String'));
        else
            xMin = str2double(get(hFFTMin,'String'));
            xMax = str2double(get(hFFTMax,'String'));
        end

        yLims = [str2double(get(hYMin,'String')) str2double(get(hYMax,'String'))];
        rescaleData(plotHandles,xMin,xMax,yLims);
        % rescaleData(hTemporalFreqPlot,xMin,xMax,yLims);
        % rescaleData(hContrastPlot,xMin,xMax,yLims);
        % rescaleData(hOrientationPlot,xMin,xMax,yLims);
        % rescaleData(hSpatialFreqPlot,xMin,xMax,yLims);
        % rescaleData(hSigmaPlot,xMin,xMax,yLims);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rescaleData_Callback(~,~)

        analysisType = string(strsplit(analysisTypeString, '|'));
        analysisType = analysisType(get(hAnalysisType,'val'));

        if ismember(analysisType,  ["ERP", "Raster", "FR", "TF", "deltaTF"]) % ERP or spikes or TFs
            xMin = str2double(get(hStimMin,'String'));
            xMax = str2double(get(hStimMax,'String'));
        elseif analysisType=="STA"
            xMin = str2double(get(hSTAMin,'String'));
            xMax = str2double(get(hSTAMax,'String'));
        else    
            xMin = str2double(get(hFFTMin,'String'));
            xMax = str2double(get(hFFTMax,'String'));
        end

        if analysisType~="deltaTF"
            rescaleData(plotHandles,xMin,xMax,getYLims(plotHandles));
            % rescaleData(hTemporalFreqPlot,xMin,xMax,getYLims(hTemporalFreqPlot));
            % rescaleData(hContrastPlot,xMin,xMax,getYLims(hContrastPlot));
            % rescaleData(hOrientationPlot,xMin,xMax,getYLims(hOrientationPlot));
            % rescaleData(hSpatialFreqPlot,xMin,xMax,getYLims(hSpatialFreqPlot));
            % rescaleData(hSigmaPlot,xMin,xMax,getYLims(hSigmaPlot));
        else
            yMin = str2double(get(hFFTMin,'String'));
            yMax = str2double(get(hFFTMax,'String'));
            yRange = [yMin yMax];
            rescaleData(plotHandles,xMin,xMax,yRange);
            % rescaleData(hTemporalFreqPlot,xMin,xMax,yRange);
            % rescaleData(hContrastPlot,xMin,xMax,yRange);
            % rescaleData(hOrientationPlot,xMin,xMax,yRange);
            % rescaleData(hSpatialFreqPlot,xMin,xMax,yRange);
            % rescaleData(hSigmaPlot,xMin,xMax,yRange);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function holdOn_Callback(source,~)
        holdOnState = get(source,'Value');
        
        holdOnGivenPlotHandle(plotHandles,holdOnState);
        % holdOnGivenPlotHandle(hTemporalFreqPlot,holdOnState);
        % holdOnGivenPlotHandle(hContrastPlot,holdOnState);
        % holdOnGivenPlotHandle(hOrientationPlot,holdOnState);
        % holdOnGivenPlotHandle(hSpatialFreqPlot,holdOnState);
        % holdOnGivenPlotHandle(hSigmaPlot,holdOnState);
        
        if holdOnState
            set(hElectrodes,'Nextplot','add');
        else
            set(hElectrodes,'Nextplot','replace');
        end

        function holdOnGivenPlotHandle(plotHandles,holdOnState)
            
            [numRows,numCols] = size(plotHandles);
            if holdOnState
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','add');

                    end
                end
            else
                for i=1:numRows
                    for j=1:numCols
                        set(plotHandles(i,j),'Nextplot','replace');
                    end
                end
            end
        end 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cla_Callback(~,~)
        
        claGivenPlotHandle(plotHandles);
        % claGivenPlotHandle(hTemporalFreqPlot);
        % claGivenPlotHandle(hContrastPlot);
        % claGivenPlotHandle(hOrientationPlot);
        % claGivenPlotHandle(hSpatialFreqPlot);
        % claGivenPlotHandle(hSigmaPlot);
        % 
        % cla(hRFMapPlot);cla(hcenterRFMapPlot);
        
        function claGivenPlotHandle(plotHandles)
            [numRows,numCols] = size(plotHandles);
            for i=1:numRows
                for j=1:numCols
                    cla(plotHandles(i,j));
                end
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main function that plots the data
function rfMapVals = plotLFPData1Channel(plotHandles,channelString,s,f,~,c,t,folderLFP,...
analysisType,timeVals,plotColor,blRange,stRange,~,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag)

parameterCombinations = loadParameterCombinations(folderExtract,sideChoice);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear analogData
x=load(fullfile(folderLFP,channelString));
analogData=x.analogData;

%%%%%%%%%%%%%%%%%%%%%%%%%% Change Reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(referenceChannelString,'None')
    % Do nothing
elseif strcmp(referenceChannelString,'AvgRef')
    disp('Changing to average reference');
    x = load(fullfile(folderLFP,'AvgRef.mat'));
    analogData = analogData - x.analogData;
else
    disp('Changing to bipolar reference');
    x = load(fullfile(folderLFP,referenceChannelString));
    analogData = analogData - x.analogData;
end

% Get bad trials
badTrialFile = fullfile(folderSegment,['badTrials' badTrialNameStr '.mat']);
if ~exist(badTrialFile,'file')
    disp('Bad trial file does not exist...');
    badTrials=[]; allBadTrials=[];
else
    [badTrials,allBadTrials] = loadBadTrials(badTrialFile);    
end

if ~useCommonBadTrialsFlag
    badTrials = allBadTrials{str2double(channelString(5:end))};
end

disp([num2str(length(badTrials)) ' bad trials']);

%%%%%%%%%%%%%%%%%%%%%%% Take a common baseline for TF plots %%%%%%%%%%%%%%%
Fs = round(1/(timeVals(2)-timeVals(1)));
movingwin = [0.25 0.025];
params.tapers   = [1 1];
params.pad      = -1;
params.Fs       = Fs;
params.trialave = 1; %averaging across trials

useCommonBLFlag=1;
if analysisType == "deltaTF"
    clear goodPos
    goodPos = parameterCombinations{size(parameterCombinations,1),size(parameterCombinations,2),s,f,size(parameterCombinations,5),c,t};
    goodPos = setdiff(goodPos,badTrials);
    
    [S,timeTF] = mtspecgramc(analogData(goodPos,:)',movingwin,params);
    xValToPlot = timeTF+timeVals(1)-1/Fs;
    
    blPos = intersect(find(xValToPlot>=blRange(1)),find(xValToPlot<blRange(2)));
    logS = log10(S);
    blPower = mean(logS(blPos,:),1);
    logSBLAllConditions = repmat(blPower,length(xValToPlot),1);
end

stimType = string(strsplit(stimTypeString, '|'));
rfMapVals = zeros(numRows,numCols);
for i=1:numRows
    e = numRows-i+1;
    for j=1:numCols
        a = j;
        clear goodPos
        o = numRows*(j-1) + i + (numRows*numCols)*(stimType(get(hStimType,'val')) == "Grayscale");
        goodPos = parameterCombinations{1,1,s,f,o,c,t};
        goodPos = setdiff(goodPos,badTrials);
      
        if isempty(goodPos)
            disp('No entries for this combination..');
        else
            disp(['pos=(' num2str(i) ',' num2str(j) ') ,n=' num2str(length(goodPos))]);

            if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
                disp('baseline and stimulus ranges are not the same');
            else
                range = blRange;
                rangePos = round(diff(range)*Fs);
                blPos = find(timeVals>=blRange(1),1)+ (1:rangePos);
                stPos = find(timeVals>=stRange(1),1)+ (1:rangePos);
                xs = 0:1/diff(range):Fs-1/diff(range);
            end

            if analysisType == "ERP"        % compute ERP
                clear erp
                erp = mean(analogData(goodPos,:),1); %#ok<*NODEF>
                plot(plotHandles(i,j),timeVals,erp,'color',plotColor);
                
                rfMapVals(e,a) = rms(erp(stPos));

            elseif analysisType == "Raster"  ||   analysisType == "FR" % compute Firing rates
                disp('Use plotSpikeData instead of plotLFPData...');
                
            elseif analysisType == "FFT"  ||   analysisType == "deltaFFT"
                fftBL = abs(fft(analogData(goodPos,blPos),[],2));
                fftST = abs(fft(analogData(goodPos,stPos),[],2));

                if analysisType == "FFT"
                    plot(plotHandles(i,j),xs,log10(mean(fftBL)),'g');
                    set(plotHandles(i,j),'Nextplot','add');
                    plot(plotHandles(i,j),xs,log10(mean(fftST)),'k');
                    set(plotHandles(i,j),'Nextplot','replace');
                end

                if analysisType == "deltaFFT"
                    plot(plotHandles(i,j),xs,log10(mean(fftST))-log10(mean(fftBL)),'color',plotColor);
                end
                
            elseif analysisType == "FFT(ERP)" || analysisType == "deltaFFT(ERP)"
                fftERPBL = abs(fft(mean(analogData(goodPos,blPos),1)));
                fftERPST = abs(fft(mean(analogData(goodPos,stPos),1)));
                
                if analysisType == "FFT(ERP)"
                    plot(plotHandles(i,j),xs,log10(fftERPBL),'g');
                    set(plotHandles(i,j),'Nextplot','add');
                    plot(plotHandles(i,j),xs,log10(fftERPST),'k');
                    set(plotHandles(i,j),'Nextplot','replace');
                end
                
                if analysisType == "deltaFFT(ERP)"
                    plot(plotHandles(i,j),xs,log10(fftERPST)-log10(fftERPBL),'color',plotColor);
                end
            
            elseif analysisType == "TF" || analysisType == "deltaTF"  % TF analysis

                [S,timeTF,freqTF] = mtspecgramc(analogData(goodPos,:)',movingwin,params);
                xValToPlot = timeTF+timeVals(1)-1/Fs;
                if (analysisType=="TF")
                    pcolor(plotHandles(i,j),xValToPlot,freqTF,log10(S'));
                    shading(plotHandles(i,j),'interp');
                else
                    blPos = intersect(find(xValToPlot>=blRange(1)),find(xValToPlot<blRange(2)));
                    logS = log10(S);
                    blPower = mean(logS(blPos,:),1);
                    logSBL = repmat(blPower,length(xValToPlot),1); %#ok<NASGU>
                    if useCommonBLFlag
                        pcolor(plotHandles(i,j),xValToPlot,freqTF,10*(logS-logSBLAllConditions)');
                    else
                        pcolor(plotHandles(i,j),xValToPlot,freqTF,10*(logS-logSBL)');
                    end
                    shading(plotHandles(i,j),'interp');
                end
            end
            
            % % Display title
            % if (i==1)
            %     if (j==1)
            %         title(plotHandles(i,j),['Azi: ' num2str(aValsUnique(a))],'FontSize',titleFontSize);
            %     else
            %         title(plotHandles(i,j),num2str(aValsUnique(a)),'FontSize',titleFontSize);
            %     end
            % end
            % 
            % if (j==numCols)
            %     if (i==1)
            %      title(plotHandles(i,j),[{'Ele'} {num2str(eValsUnique(e))}],'FontSize',titleFontSize,...
            %          'Units','Normalized','Position',[1.25 0.5]);
            %     else
            %         title(plotHandles(i,j),num2str(eValsUnique(e)),'FontSize',titleFontSize,...
            %          'Units','Normalized','Position',[1.25 0.5]);
            %     end
            % end
        end
    end
end

if analysisType~="ERP"
    rfMapVals=[];
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSpikeData1Channel(plotHandles,channelNumber,s,f,~,c,t,folderSpikes,...
analysisType,timeVals,plotColor,unitID,~,sideChoice)

parameterCombinations = loadParameterCombinations(folderExtract,sideChoice);

% Get the data
clear spikeData
x=load(fullfile(folderSpikes,['elec' num2str(channelNumber) '_SID' num2str(unitID) '.mat']));
spikeData=x.spikeData;

% Get bad trials
badTrialFile = fullfile(folderSegment,'badTrials.mat');
if ~exist(badTrialFile,'file')
    disp('Bad trial file does not exist...');
    badTrials=[];
else
    badTrials = loadBadTrials(badTrialFile);
    disp([num2str(length(badTrials)) ' bad trials']);
end

stimType = string(strsplit(stimTypeString, '|'));
for i=1:numRows
    e = numRows-i+1;
    for j=1:numCols
        a = j;
        clear goodPos
        o = numRows*(j-1) + i + (numRows*numCols)*(stimType(get(hStimType,'val')) == "Grayscale");
        goodPos = parameterCombinations{1,1,s,f,o,c,t};
        goodPos = setdiff(goodPos,badTrials);

        if isempty(goodPos)
            disp('No entries for this combination..')
        else
            disp(['pos=(' num2str(i) ',' num2str(j) ') ,n=' num2str(length(goodPos))]);
            
            if analysisType == "FR"
                [psthVals,xs] = getPSTH(spikeData(goodPos),10,[timeVals(1) timeVals(end)]);
                plot(plotHandles(i,j),xs,psthVals,'color',plotColor);
            else
                X = spikeData(goodPos);
                axes(plotHandles(i,j)); %#ok<LAXES>
                rasterplot(X,1:length(X),plotColor);
            end
        end
        
        % Display title
        % if (i==1)
        %     if (j==1)
        %         title(plotHandles(i,j),['Azi: ' num2str(aValsUnique(a))],'FontSize',titleFontSize);
        %     else
        %         title(plotHandles(i,j),num2str(aValsUnique(a)),'FontSize',titleFontSize);
        %     end
        % end
        % 
        % if (j==numCols)
        %     if (i==1)
        %         title(plotHandles(i,j),[{'Ele'} {num2str(eValsUnique(e))}],'FontSize',titleFontSize,...
        %             'Units','Normalized','Position',[1.25 0.5]);
        %     else
        %         title(plotHandles(i,j),num2str(eValsUnique(e)),'FontSize',titleFontSize,...
        %             'Units','Normalized','Position',[1.25 0.5]);
        %     end
        % end
    end
end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotLFPData1Parameter1Channel(plotHandles,channelString,a,e,s,f,o,c,t,folderLFP,...
analysisType,timeVals,plotColor,blRange,stRange,folderName,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag)

folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');

titleFontSize = 10;

% For orientation selectivity analysis
timeForComputation = [40 100]/1000; % s
freqForComputation = [40 60]; % Hz

[parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract,sideChoice);
[~,numCols] = size(plotHandles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear signal analogData
x=load(fullfile(folderLFP,channelString));
analogData=x.analogData;

%%%%%%%%%%%%%%%%%%%%%%%%%%% Change Reference %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(referenceChannelString,'None')
    % Do nothing
elseif strcmp(referenceChannelString,'AvgRef')
    disp('Changing to average reference');
    x = load(fullfile(folderLFP,'AvgRef.mat'));
    analogData = analogData - x.analogData;
else
    disp('Changing to bipolar reference');
    x = load(fullfile(folderLFP,referenceChannelString));
    analogData = analogData - x.analogData;
end

% Get bad trials
badTrialFile = fullfile(folderSegment,['badTrials' badTrialNameStr '.mat']);
if ~exist(badTrialFile,'file')
    disp('Bad trial file does not exist...');
    badTrials=[]; allBadTrials=[];
else
    [badTrials,allBadTrials] = loadBadTrials(badTrialFile);    
end

if ~useCommonBadTrialsFlag
    badTrials = allBadTrials{str2double(channelString(5:end))};
end

disp([num2str(length(badTrials)) ' bad trials']);

% Out of a,e,s,f,o,c and t only one parameter is empty
if isempty(a)
    aList = 1:length(aValsUnique); 
    eList = e+zeros(1,numCols); 
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols);
    tList = t+zeros(1,numCols);
    titleParam = 'Azi: ';
    titleList = aValsUnique;
end

if isempty(e) 
    aList = a+zeros(1,numCols);
    eList = 1:length(eValsUnique);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols);
    tList = t+zeros(1,numCols);
    titleParam = 'Ele: ';
    titleList = eValsUnique;
end

if isempty(s) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = 1:length(sValsUnique);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols);
    tList = t+zeros(1,numCols);
    titleParam = 'Sigma: ';
    titleList = sValsUnique;
end

if isempty(f)
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = 1:length(fValsUnique); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols);
    tList = t+zeros(1,numCols);
    titleParam = 'SF: ';
    titleList = fValsUnique;
end

if isempty(o) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = 1:length(oValsUnique);
    cList = c+zeros(1,numCols);
    tList = t+zeros(1,numCols);
    titleParam = 'Ori: ';
    titleList = oValsUnique;
end

if isempty(c) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = 1:length(cValsUnique);
    tList = t+zeros(1,numCols);
    titleParam = 'Con: ';
    titleList = cValsUnique;
end

if isempty(t) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols);
    tList = 1:length(tValsUnique);
    titleParam = 'TF: ';
    titleList = tValsUnique;
end

% Main loop
computationVals=zeros(1,numCols);
for j=1:numCols
    clear goodPos
    goodPos = parameterCombinations{aList(j),eList(j),sList(j),fList(j),oList(j),cList(j),tList(j)};
    goodPos = setdiff(goodPos,badTrials);

    if isempty(goodPos)
        disp('No entries for this combination..')
    else
        disp(['pos=' num2str(j) ',n=' num2str(length(goodPos))]);

        Fs = round(1/(timeVals(2)-timeVals(1)));
        if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
            disp('baseline and stimulus ranges are not the same');
        else
            range = blRange;
            rangePos = round(diff(range)*Fs);
            blPos = find(timeVals>=blRange(1),1)+ (1:rangePos);
            stPos = find(timeVals>=stRange(1),1)+ (1:rangePos);
            xs = 0:1/diff(range):Fs-1/diff(range);
        end
        
        xsComputation = intersect(find(timeVals>=timeForComputation(1)),find(timeVals<timeForComputation(2)));
        freqComputation = intersect(find(xs>=freqForComputation(1)),find(xs<=freqForComputation(2)));

        if analysisType == "ERP"        % compute ERP
            clear erp
            erp = mean(analogData(goodPos,:),1);
            erp = erp - mean(erp(blPos));
            
            plot(plotHandles(j),timeVals,erp,'color',plotColor);
            
            if isempty(o) % Orientation tuning
                computationVals(j) = abs(min(erp(xsComputation)));
            end

        elseif analysisType == "Raster" || analysisType == "FR"   % compute Firing rates
            disp('Use plotSpikeData instead of plotLFPData...');
            
        elseif analysisType == "FFT" || analysisType == "deltaFFT"
            fftBL = abs(fft(analogData(goodPos,blPos),[],2));
            fftST = abs(fft(analogData(goodPos,stPos),[],2));

            if analysisType == "FFT"
                plot(plotHandles(j),xs,log10(mean(fftBL)),'g');
                set(plotHandles(j),'Nextplot','add');
                plot(plotHandles(j),xs,log10(mean(fftST)),'k');
                set(plotHandles(j),'Nextplot','replace');
            end

            if analysisType == "deltaFFT"
                plot(plotHandles(j),xs,log10(mean(fftST))-log10(mean(fftBL)),'color',plotColor);
            end
            
            if isempty(o) % Orientation tuning
                computationVals(j) = max(mean(fftST(:,freqComputation),1));
            end
            
        elseif analysisType == "FFT(ERP)" || analysisType == "deltaFFT(ERP)"
            fftERPBL = abs(fft(mean(analogData(goodPos,blPos),1)));
            fftERPST = abs(fft(mean(analogData(goodPos,stPos),1)));

            if analysisType == "FFT(ERP)"
                plot(plotHandles(j),xs,log10(fftERPBL),'g');
                set(plotHandles(j),'Nextplot','add');
                plot(plotHandles(j),xs,log10(fftERPST),'k');
                set(plotHandles(j),'Nextplot','replace');
            end

            if analysisType == "deltaFFT(ERP)"
                plot(plotHandles(j),xs,log10(fftERPST)-log10(fftERPBL),'color',plotColor);
            end
            
            if isempty(o) % Orientation tuning
                computationVals(j) = max(mean(fftERPST(freqComputation)),1);
            end
       
        elseif analysisType == "TF" || analysisType == "deltaTF"
            
            % Set up multitaper for TF analysis
            movingwin = [0.25 0.025];
            params.tapers   = [1 1];
            params.pad      = -1;
            params.Fs       = Fs;
            params.trialave = 1; %averaging across trials
            
            [S,timeTF,freqTF] = mtspecgramc(analogData(goodPos,:)',movingwin,params);
            xValToPlot = timeTF+timeVals(1)-1/Fs;
            if (analysisType=="TF")
                pcolor(plotHandles(j),xValToPlot,freqTF,log10(S'));
                shading(plotHandles(j),'interp');
            else
                blPos = intersect(find(xValToPlot>=blRange(1)),find(xValToPlot<blRange(2)));
                logS = log10(S);
                blPower = mean(logS(blPos,:),1);
                logSBL = repmat(blPower,length(xValToPlot),1);
                pcolor(plotHandles(j),xValToPlot,freqTF,10*(logS-logSBL)');
                shading(plotHandles(j),'interp');
            end
        end

        % Display title
        if (j==1)
            title(plotHandles(j),[titleParam num2str(titleList(j))],'FontSize',titleFontSize);
        else
            title(plotHandles(j),num2str(titleList(j)),'FontSize',titleFontSize);
        end
    end
end

% Orientation tuning
if isempty(o)
    if analysisType == "ERP"
        disp(['Orientation selectivity values calculated between ' num2str(timeForComputation(1)) '-' num2str(timeForComputation(2))  ' s']);
    else
        disp(['Orientation selectivity values calculated between ' num2str(freqForComputation(1)) '-' num2str(freqForComputation(2))  ' Hz']);
    end
    disp(['orientation values: ' num2str(computationVals)]);
    [prefOrientation,orientationSelectivity] = getOrientationTuning(computationVals,oValsUnique);
    disp(['prefOri: ' num2str(round(prefOrientation)) ', sel: ' num2str(orientationSelectivity)]);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSpikeData1Parameter1Channel(plotHandles,channelNumber,a,e,s,f,o,c,t,folderSpikes,...
analysisType,timeVals,plotColor,unitID,folderName,sideChoice)
titleFontSize = 12;

folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');

[parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract,sideChoice);
[~,numCols] = size(plotHandles);

% Get the data
clear spikeData
x=load(fullfile(folderSpikes,['elec' num2str(channelNumber) '_SID' num2str(unitID) '.mat']));
spikeData=x.spikeData;

% Get bad trials
badTrialFile = fullfile(folderSegment,'badTrials.mat');
if ~exist(badTrialFile,'file')
    disp('Bad trial file does not exist...');
    badTrials=[];
else
    badTrials = loadBadTrials(badTrialFile);
    disp([num2str(length(badTrials)) ' bad trials']);
end

% Out of a,e,s,f,o,c ant t, only one parameter is empty
if isempty(a)
    aList = 1:length(aValsUnique); 
    eList = e+zeros(1,numCols); 
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols); 
    tList = t+zeros(1,numCols);
    titleParam = 'Azi: ';
    titleList = aValsUnique;
end

if isempty(e) 
    aList = a+zeros(1,numCols);
    eList = 1:length(eValsUnique);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols); 
    tList = t+zeros(1,numCols);
    titleParam = 'Ele: ';
    titleList = eValsUnique;
end

if isempty(s) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = 1:length(sValsUnique);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols); 
    tList = t+zeros(1,numCols);
    titleParam = 'Sigma: ';
    titleList = sValsUnique;
end

if isempty(f)
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = 1:length(fValsUnique); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols); 
    tList = t+zeros(1,numCols);
    titleParam = 'SF: ';
    titleList = fValsUnique;
end

if isempty(o) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = 1:length(oValsUnique);
    cList = c+zeros(1,numCols); 
    tList = t+zeros(1,numCols);
    titleParam = 'Ori: ';
    titleList = oValsUnique;
end

if isempty(c) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = 1:length(cValsUnique);
    tList = t+zeros(1,numCols);
    titleParam = 'Con: ';
    titleList = cValsUnique;
end

if isempty(t) 
    aList = a+zeros(1,numCols); 
    eList = e+zeros(1,numCols);
    sList = s+zeros(1,numCols);
    fList = f+zeros(1,numCols); 
    oList = o+zeros(1,numCols);
    cList = c+zeros(1,numCols);
    tList = 1:length(tValsUnique);
    titleParam = 'TF: ';
    titleList = tValsUnique;
end

% Plot

for j=1:numCols
    %a = j;
    clear goodPos
    goodPos = parameterCombinations{aList(j),eList(j),sList(j),fList(j),oList(j),cList(j),tList(j)};
    goodPos = setdiff(goodPos,badTrials);

    if isempty(goodPos)
        disp('No entries for this combination..')
    else
        disp(['pos=' num2str(j) ',n=' num2str(length(goodPos))]);
        if analysisType == "FR"
            [psthVals,xs] = getPSTH(spikeData(goodPos),10,[timeVals(1) timeVals(end)]);
            plot(plotHandles(j),xs,psthVals,'color',plotColor);
        else
            X = spikeData(goodPos);
            axes(plotHandles(j)); %#ok<LAXES>
            rasterplot(X,1:length(X),plotColor);
        end
    end

    % Display title
    if (j==1)
        title(plotHandles(j),[titleParam num2str(titleList(j))],'FontSize',titleFontSize);
    else
        title(plotHandles(j),num2str(titleList(j)),'FontSize',titleFontSize);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSTA1Channel(plotHandles,analogChannelString,spikeChannelNumber,unitID,folderLFP,folderSpikes,...
                s,f,o,c,t,timeVals,plotColors,blRange,stRange,folderName,staLen,removeMeanSTA,sideChoice)

titleFontSize = 12;

folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');

[parameterCombinations,aValsUnique,eValsUnique] = loadParameterCombinations(folderExtract,sideChoice);
[numRows,numCols] = size(plotHandles);

% Get the analog data
clear analogData
x=load(fullfile(folderLFP,analogChannelString));
analogData=x.analogData;

% Get the spike data
clear spikeData
x=load(fullfile(folderSpikes,['elec' num2str(spikeChannelNumber) '_SID' num2str(unitID) '.mat']));
spikeData=x.spikeData;

% Get bad trials
badTrialFile = fullfile(folderSegment,'badTrials.mat');
if ~exist(badTrialFile,'file')
    disp('Bad trial file does not exist...');
    badTrials=[];
else
    badTrials = loadBadTrials(badTrialFile);
    disp([num2str(length(badTrials)) ' bad trials']);
end

staTimeLims{1} = blRange;
staTimeLims{2} = stRange;

for i=1:numRows
    e = numRows-i+1;
    for j=1:numCols
        a = j;
        clear goodPos
        goodPos = parameterCombinations{a,e,s,f,o,c,t};
        goodPos = setdiff(goodPos,badTrials);

        if isempty(goodPos)
            disp('No entries for this combination..')
        else
            goodSpikeData = spikeData(goodPos);
            goodAnalogSignal = analogData(goodPos,:);
            [staVals,numberOfSpikes,xsSTA] = getSTA(goodSpikeData,goodAnalogSignal,staTimeLims,timeVals,staLen,removeMeanSTA);
            
            disp([num2str(i) ' ' num2str(j) ', numStim: ' num2str(length(goodPos)) ', numSpikes: ' num2str(numberOfSpikes)]);
            if ~isempty(staVals{1})
                plot(plotHandles(i,j),xsSTA,staVals{1},'color',plotColors{1});
            end
            set(plotHandles(i,j),'Nextplot','add');
            if ~isempty(staVals{2})
                plot(plotHandles(i,j),xsSTA,staVals{2},'color',plotColors{2});
            end
            set(plotHandles(i,j),'Nextplot','replace');
        end
        
        % Display title
        if (i==1)
            if (j==1)
                title(plotHandles(i,j),['Azi: ' num2str(aValsUnique(a))],'FontSize',titleFontSize);
            else
                title(plotHandles(i,j),num2str(aValsUnique(a)),'FontSize',titleFontSize);
            end
        end

        if (j==numCols)
            if (i==1)
                title(plotHandles(i,j),[{'Ele'} {num2str(eValsUnique(e))}],'FontSize',titleFontSize,...
                    'Units','Normalized','Position',[1.25 0.5]);
            else
                title(plotHandles(i,j),num2str(eValsUnique(e)),'FontSize',titleFontSize,...
                    'Units','Normalized','Position',[1.25 0.5]);
            end
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function plotSTA1Parameter1Channel(hOrientationPlot,analogChannelNumber,spikeChannelNumber,unitID,folderLFP,folderSpikes,...
%                 a,e,s,f,o,timeVals,plotColor,BLMin,BLMax,STMin,STMax,folderName)
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotRFMaps(hRFMapPlot,hcenterRFMapPlot,rfMapVals,aValsUnique,eValsUnique,plotColor,holdOnState)

plotSimple = 0;% Just compute the mean and Variance

if plotSimple
    [aziCenter,eleCenter] = getRFcenterSimple(aValsUnique,eValsUnique,rfMapVals); %#ok<*UNRCH>
else
    outParams = getRFcenter(aValsUnique,eValsUnique,rfMapVals);
    aziCenter = outParams(1); eleCenter = outParams(2);
    RFSize = sqrt((outParams(3)^2+outParams(4)^2)/2);
end

if plotSimple
    set(hRFMapPlot,'visible','off')
else
    % Plot the gaussian
    dX = (aValsUnique(end)-aValsUnique(1))/100;
    dY = (eValsUnique(end)-eValsUnique(1))/100;
    [~,outVals,boundaryX,boundaryY] = gauss2D(outParams,aValsUnique(1):dX:aValsUnique(end),eValsUnique(1):dY:eValsUnique(end));
    pcolor(hRFMapPlot,aValsUnique(1):dX:aValsUnique(end),eValsUnique(1):dY:eValsUnique(end),outVals);
    shading(hRFMapPlot,'interp'); 
    set(hRFMapPlot,'Nextplot','add');
    plot(hRFMapPlot,boundaryX,boundaryY,'k');
    set(hRFMapPlot,'Nextplot','replace');
end

% Plot the center only
if holdOnState
    set(hcenterRFMapPlot,'Nextplot','add');
else
    set(hcenterRFMapPlot,'Nextplot','replace');
end
plot(hcenterRFMapPlot,aziCenter,eleCenter,[plotColor '+']);
title(hcenterRFMapPlot,['Loc: (' num2str(aziCenter) ',' num2str(eleCenter) '), Size: ' num2str(RFSize)]);
disp(['Loc: (' num2str(aziCenter) ',' num2str(eleCenter) '), Size: ' num2str(RFSize)]);
axis(hcenterRFMapPlot,[aValsUnique(1) aValsUnique(end) eValsUnique(1) eValsUnique(end)]);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end
function zLims = getZLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
zMin = inf;
zMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        tmpAxisVals = caxis(plotHandles(row,column));
        if tmpAxisVals(1) < zMin
            zMin = tmpAxisVals(1);
        end
        if tmpAxisVals(2) > zMax
            zMax = tmpAxisVals(2);
        end
    end
end

zLims=[zMin zMax];
end
function rescaleData(plotHandles,xMin,xMax,yLims)

[numRows,numCols] = size(plotHandles);
labelSize=12;
for i=1:numRows
    for j=1:numCols
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && rem(j,2)==1)
            if j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        else
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        end
    end
end

% Remove Labels on the four corners
%set(plotHandles(1,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(1,numCols),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,numCols),'XTickLabel',[],'YTickLabel',[]);
end
function rescaleZPlots(plotHandles,zLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        caxis(plotHandles(i,j),zLims);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outString = getStringFromValues(valsUnique,decimationFactor)

if length(valsUnique)==1
    outString = convertNumToStr(valsUnique(1),decimationFactor);
else
    outString='';
    for i=1:length(valsUnique)
        outString = cat(2,outString,[convertNumToStr(valsUnique(i),decimationFactor) '|']);
    end
    outString = [outString 'all'];
end

    function str = convertNumToStr(num,f)
        if num > 16384
            num=num-32768;
        end
        str = num2str(num/f);
    end
end
function [outString,outArray] = getAnalogStringFromValues(analogChannelsStored,analogInputNums)
outString='';
count=1;
for i=1:length(analogChannelsStored)
    outArray{count} = ['elec' num2str(analogChannelsStored(i))]; %#ok<AGROW>
    outString = cat(2,outString,[outArray{count} '|']);
    count=count+1;
end
if ~isempty(analogInputNums)
    for i=1:length(analogInputNums)
        outArray{count} = ['ainp' num2str(analogInputNums(i))];
        outString = cat(2,outString,[outArray{count} '|']);
        count=count+1;
    end
end
end
function outString = getNeuralStringFromValues(neuralChannelsStored,SourceUnitIDs)
outString='';
for i=1:length(neuralChannelsStored)
    outString = cat(2,outString,[num2str(neuralChannelsStored(i)) ', SID ' num2str(SourceUnitIDs(i)) '|']);
end 
end
function [colorString, colorNames] = getColorString

colorNames = 'brkgcmy';
colorString = 'blue|red|black|green|cyan|magenta|yellow';

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
%%%%%%%%%%%%c%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load Data
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
x=load(fullfile(folderLFP,'lfpInfo.mat'));
analogChannelsStored=x.analogChannelsStored;
goodStimPos=x.goodStimPos;
timeVals=x.timeVals;

if isfield(x,'analogInputNums')
    analogInputNums=x.analogInputNums;
else
    analogInputNums=[];
end
end
function [neuralChannelsStored,SourceUnitID] = loadspikeInfo(folderSpikes)
fileName = fullfile(folderSpikes,'spikeInfo.mat');
if exist(fileName,'file')
    x=load(fileName);
    neuralChannelsStored=x.neuralChannelsStored;
    SourceUnitID=x.SourceUnitID;
else
    neuralChannelsStored=[];
    SourceUnitID=[];
end
end
function [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract,sideChoice)

p = load(fullfile(folderExtract,'parameterCombinations.mat'));

if ~isfield(p,'parameterCombinations2') % Not a plaid stimulus
    parameterCombinations=p.parameterCombinations;
    aValsUnique=p.aValsUnique;
    eValsUnique=p.eValsUnique;
    
    if ~isfield(p,'sValsUnique')
        sValsUnique = p.rValsUnique/3;
    else
        sValsUnique=p.sValsUnique;
    end
    
    fValsUnique=p.fValsUnique;
    oValsUnique=p.oValsUnique;
    
    if ~isfield(p,'cValsUnique')
        cValsUnique=100;
    else
        cValsUnique=p.cValsUnique;
    end
    
    if ~isfield(p,'tValsUnique')
        tValsUnique=0;
    else
        tValsUnique=p.tValsUnique;
    end 
else
    [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
        fValsUnique,oValsUnique,cValsUnique,tValsUnique] = makeCombinedParameterCombinations(folderExtract,sideChoice);
end

end
function [badTrials,allBadTrials] = loadBadTrials(badTrialFile)
x=load(badTrialFile);
badTrials=x.badTrials;
allBadTrials=x.allBadTrials;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [aziCenter,eleCenter] = getRFcenterSimple(aValsUnique,eValsUnique,rfMapValues)
% 
% rfMapValues = rfMapValues-mean(mean(rfMapValues));
% % Compute the mean and variance
% [maxEnonUnique,maxAnonUnique] = (find(rfMapValues==max(max(rfMapValues))));
% maxE = maxEnonUnique(ceil(length(maxEnonUnique)/2));
% maxA = maxAnonUnique(ceil(length(maxAnonUnique)/2));
% 
% %[maxE maxA]
% aziCenter = sum(rfMapValues(maxE,:).*aValsUnique)/sum(rfMapValues(maxE,:));
% eleCenter = sum(rfMapValues(:,maxA)'.*eValsUnique)/sum(rfMapValues(:,maxA));
% end
function [prefOrientation,orientationSelectivity] = getOrientationTuning(computationVals,oValsUnique)
num=0;
den=0;

for j=1:length(oValsUnique)
    num = num+computationVals(j)*sind(2*oValsUnique(j));
    den = den+computationVals(j)*cosd(2*oValsUnique(j));
end

prefOrientation = 90*atan2(num,den)/pi;
orientationSelectivity = abs(den+1i*num)/sum(computationVals);

if prefOrientation<0
    prefOrientation = prefOrientation+180;
end
end