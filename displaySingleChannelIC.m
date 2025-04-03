% Displays data from a single electrode

% In case the stimulus takes properties from both gabors (such as plaids or
% color stimuli), use sideChoice to specify which of the two side to use
% for each parameter.

function displaySingleChannelIC(subjectName,expDate,protocolName,folderSourceString,gridType,gridLayout,sideChoice,badTrialNameStr,useCommonBadTrialsFlag)

if ~exist('folderSourceString','var');  folderSourceString='F:';        end
if ~exist('gridType','var');            gridType='Microelectrode';      end
if ~exist('gridLayout','var');          gridLayout=2;                   end
if ~exist('sideChoice','var');          sideChoice=[];                  end
if ~exist('badTrialNameStr','var');     badTrialNameStr = 'V1';         end
if ~exist('useCommonBadTrialsFlag','var'); useCommonBadTrialsFlag = 1;  end

folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);

% Get folders
% folderImage = fullfile(folderSourceString, 'data/images/New_sets/T'); -
% For image protocols, it is better to keep all images in the rawData as
% well as data folders. I think we have dnoe it for other image protocols.

folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');
folderSpikes = fullfile(folderSegment,'Spikes');

% load LFP Information
[analogChannelsStored,timeVals,~,analogInputNums] = loadlfpInfo(folderLFP);
[neuralChannelsStored,SourceUnitIDs] = loadspikeInfo(folderSpikes);

% Get Combinations
[~,~,~,~,~,oValsUnique,~,~] = loadParameterCombinations(folderExtract,sideChoice);

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
panel.grid.height = 0.4*(7/13); % Rescaling the V4/V1 grid height for V1|V4 rearrangement
panel.grid.y = (1 - 2*UI.ud_margin) - panel.grid.height; 
panel.grid.width = panel.grid.height*(17/6)*(1/aspectRatio); % Rescaling the grid width for V1|V4 rearrangement, while keeping approx. square spacing according to the monitor's aspect ratio

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

% Stim Type
stimTypeString = 'Color|Grayscale';
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-2*(dynamicHeight+dynamicGap)-titleGap dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Stim Type','HorizontalAlignment','left','FontSize',fontSizeSmall);
hStimType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-2*(dynamicHeight+dynamicGap)-titleGap 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',stimTypeString,'FontSize',fontSizeSmall);

% Analysis Type
analysisTypeString = 'ERP|FFT|deltaFFT|TF|deltaTF|Raster|FR|FFT(ERP)|deltaFFT(ERP)';
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-3*(dynamicHeight+dynamicGap)-titleGap dynamicTextWidth dynamicHeight], ...
    'Style','text','String','Analysis Type','HorizontalAlignment','left','FontSize',fontSizeSmall);
hAnalysisType = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[dynamicTextWidth 1-3*(dynamicHeight+dynamicGap)-titleGap 1-dynamicTextWidth dynamicHeight], ...
    'Style','popup','String',analysisTypeString,'FontSize',fontSizeSmall);

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

hTimingPanel = uipanel('Title','Timing (Min,Max)',...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get plots and message handles

% Get electrode array information
electrodeGridPos = [panel.grid.x, panel.grid.y, panel.grid.width, panel.grid.height];
hElectrodes = showElectrodeLocations(electrodeGridPos,analogChannelsStored(get(hAnalogChannel,'val')), ...
    colorNames(get(hChooseColor,'val')),[],1,0,gridType,subjectName,gridLayout);

gap = 2e-3;
tile.x = UI.lr_margin; 
tile.y = UI.ud_margin;
tile.width = 1-2*UI.lr_margin;
tile.height = 0.55 + UI.ud_margin;
tilePos = [tile.x, tile.y, tile.width, tile.height];

% Main plot handles
numTypes = 6;
numImages = (length(oValsUnique)/numTypes)/length(string(strsplit(stimTypeString, '|')));
numRows = numTypes; numCols = numImages;
plotHandles = getPlotHandles(numRows,numCols,tilePos,gap);

uicontrol('Unit','Normalized','Position',[0 1-UI.ud_margin 1 UI.ud_margin],...
    'Style','text','String',[subjectName expDate protocolName],'FontSize',fontSizeMedium);

if isfile("cmap.mat"), colormap(load("cmap.mat").("icefire")), else colormap turbo, end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions
    function plotData_Callback(~,~)

        analysisType = string(strsplit(analysisTypeString, '|'));
        analysisType = analysisType(get(hAnalysisType,'val'));
        plotColor = colorNames(get(hChooseColor,'val'));
        blRange = [str2double(get(hBaselineMin,'String')) str2double(get(hBaselineMax,'String'))];
        stRange = [str2double(get(hStimPeriodMin,'String')) str2double(get(hStimPeriodMax,'String'))];
        holdOnState = get(hHoldOn,'val');
        referenceChannelString = 'None';

        if analysisType == "Raster" || analysisType == "FR"
            channelPos = get(hNeuralChannel,'val');
            channelNumber = neuralChannelsStored(channelPos);
            unitID = SourceUnitIDs(channelPos);
            plotSpikeData1Channel(plotHandles,channelNumber,folderSpikes,...
                analysisType,timeVals,plotColor,unitID,sideChoice);
        else
            analogChannelPos = get(hAnalogChannel,'val');
            analogChannelString = analogChannelStringArray{analogChannelPos};
            plotLFPData1Channel(plotHandles,analogChannelString,folderLFP,...
                analysisType,timeVals,plotColor,blRange,stRange,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag);
            
            if analogChannelPos<=length(analogChannelsStored)
                channelNumber = analogChannelsStored(analogChannelPos);
            else
                channelNumber = 0;
            end
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
        else
            yMin = str2double(get(hFFTMin,'String'));
            yMax = str2double(get(hFFTMax,'String'));
            yRange = [yMin yMax];
            rescaleData(plotHandles,xMin,xMax,yRange);

            zRange = getZLims(plotHandles);
            set(hZMin,'String',num2str(zRange(1))); set(hZMax,'String',num2str(zRange(2)));
            
            rescaleZPlots(plotHandles,zRange);
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
        else
            yMin = str2double(get(hFFTMin,'String'));
            yMax = str2double(get(hFFTMax,'String'));
            yRange = [yMin yMax];
            rescaleData(plotHandles,xMin,xMax,yRange);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function holdOn_Callback(source,~)
        holdOnState = get(source,'Value');
        
        holdOnGivenPlotHandle(plotHandles,holdOnState);
        
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
% Main function that plots the data
function plotLFPData1Channel(plotHandles,channelString,folderLFP,...
analysisType,timeVals,plotColor,blRange,stRange,sideChoice,referenceChannelString,badTrialNameStr,useCommonBadTrialsFlag)

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
    goodPos = parameterCombinations{1,1,1,1,1,1,1};
    goodPos = setdiff(goodPos,badTrials);
    
    [S,timeTF] = mtspecgramc(analogData(goodPos,:)',movingwin,params);
    xValToPlot = timeTF+timeVals(1)-1/Fs;
    
    blPos = intersect(find(xValToPlot>=blRange(1)),find(xValToPlot<blRange(2)));
    logS = log10(S);
    blPower = mean(logS(blPos,:),1);
    logSBLAllConditions = repmat(blPower,length(xValToPlot),1);
end

stimType = string(strsplit(stimTypeString, '|'));

for i=1:numRows
    for j=1:numCols
        clear goodPos
        o = numRows*(j-1) + i + (numRows*numCols)*(stimType(get(hStimType,'val')) == "Grayscale");
        goodPos = parameterCombinations{1,1,1,1,o,1,1};
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
                        pcolor(plotHandles(i,j),xValToPlot,freqTF,10*(logS-logSBL)'); %#ok<UNRCH>
                    end
                    shading(plotHandles(i,j),'interp');
                end
            end
        end
    end
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSpikeData1Channel(plotHandles,channelNumber,folderSpikes,...
analysisType,timeVals,plotColor,unitID,sideChoice)

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
    for j=1:numCols
        clear goodPos
        o = numRows*(j-1) + i + (numRows*numCols)*(stimType(get(hStimType,'val')) == "Grayscale");
        goodPos = parameterCombinations{1,1,1,1,o,1,1};
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
    end
end
end
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
        tmpAxisVals = clim(plotHandles(row,column));
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
end
function rescaleZPlots(plotHandles,zLims)
[numRow,numCol] = size(plotHandles);

for i=1:numRow
    for j=1:numCol
        clim(plotHandles(i,j),zLims);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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