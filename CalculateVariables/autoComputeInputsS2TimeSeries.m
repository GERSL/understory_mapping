function autoComputeInputsS2TimeSeries(iCore, totalCores)
% This is to compute the time series model for Sentinel-2 optical data
% The time series information includes the whole S2 bands and five indices
% https://www.l3harrisgeospatial.com/docs/broadbandgreenness.html#Soil
% https://www.l3harrisgeospatial.com/docs/narrowbandgreenness.html

% Five vegetation-related indices: EVI, NDVI, SAVI, NBR, NBNDVI

% iCores and totalCores are parameters for HPC calculation; If Run the
% functin in local, these parameters are not needed.

% AUTHOR(s): Xiucheng Yang & Shi Qiu
% DATE: June. 6, 2021
% COPYRIGHT @ GERSLab

if ~exist('iCore', 'var')
    iCore = 1;
end
if ~exist('totalCores', 'var')
    totalCores = 1;
end

% addpath(pwd);
[dir_codes,~,~]=fileparts(pwd);
addpath(dir_codes);
addpath(genpath(fullfile(dir_codes,'Packages')));
dir_working = globalsets.dir_working;

folder_S2 = globalsets.folder_S2;
folder_Variable = globalsets.folder_Variable;
folder_S2ExtCT = globalsets.folder_S2ExtCT;

dimImg = [10980,10980]; % 10980 pixels by 10980 pixels for each Sentinel-2
numBandOptical = 10; % A total of ten bands for Sentinel-2
termNum = 8;
years = globalsets.years;
tileNames = globalsets.tileNames;
spectralIndices = {'EVI','NDVI','SAVI','NBR','RENDVI'};
num_c = termNum * 2 + 2;
numMinObser = num_c + 2; % Minimum number of observations to fit time series model
% follow the tile of Sentinel-2 to produce the understory map

for iTile = 1: length(tileNames)
    tileName = tileNames{iTile};
    
    dir_vari = fullfile(dir_working, folder_Variable, tileName);
    fprintf('The time series variables are exported to %s\n',dir_vari);
    % The folder to reserve the extracted time series variables
    if ~isfolder(dir_vari)
        mkdir(dir_vari);
        fprintf('Having created folder to export the time series parameters \n');
    end
    fprintf('Begin to process the Sentinel-2 tile of %s\n',tileName);
    
    %% Load all data
    % only calculate the pixels located in Connecticut OR Provide a mask
    % layer which only calculate the variables for these pixels
    maskRng = imread(fullfile(dir_working, 'layers',folder_S2ExtCT, [tileName, '.tif']));
    
%     % If only read the samples
%     maskSample = imread(fullfile(dir_working, 'layers',globalsets.folder_Samples, [tileName, '_sampleCT.tif']));
%     maskRng(maskSample==65535)=0;
    
    [maskRow, maskCol] = find(maskRng > 0); % All data

    % unique row ID
    maskRowUniq = unique(maskRow);
    nrows = length(maskRng);
    irows = zeros(1,1);
    i = 0;
    % HPC process
    while iCore + totalCores*i <= nrows
        irows(i+1) = iCore + totalCores*i;
        i = i + 1;
    end
    
    line_start = min(maskRowUniq);
    line_end = max(maskRowUniq);
    irows(irows < line_start) = [];
    irows(irows > line_end) = [];
    fprintf('%d rows to be propossed in this core \n', length(irows));
    for i = 1:length(irows)
        irow = irows(i);

        if isfile(fullfile(dir_vari, ['varibles_R', num2str(irow), '.mat']))
            try 
                load(fullfile(dir_vari, ['varibles_R', num2str(irow), '.mat']));
                fprintf('Having %d th row\n', irow);
                continue;
            catch
                fprintf('Broken file %d th row and need to process\n', irow);
            end
        end

        idsInRow = find(maskRow == irow);
        if isempty(idsInRow)
            fprintf('Skipping %d th row\n', irow);
            continue;
        end
        fprintf('Processing %d th row\n', irow);
        %% Loading time series data per row.
        pixLoc = [irow, 1]; % Row Column (sample to Line/ Sample in ENVI)
        numColumns= dimImg(2); % pixels
        %% Load Optical data from the Sentinel-2 stacks (stack is necessary to enhance the efficiency)
        [x_dateS2, y_refS2, y_IdsS2, y_YearS2, y_FmaskS2, y_orbit] = loadS2Data10mStack(dir_working,folder_S2, tileName, pixLoc, numColumns, 'stack', years,spectralIndices); % ARD_BRDF
%         [x_dateS2, y_refS2, y_IdsS2, y_YearS2, y_FmaskS2, y_orbit] = loadS2Data10mStack('/shared/cn451/Yang/CTUnderstoryMap/',folder_S2, tileName, pixLoc, numColumns, 'stack', years,spectralIndices); % ARD_BRDF
        
        record_row = []; % empty record_row first
        % only for the pixel in the range mask.
        columns = maskCol(idsInRow);
        
        fprintf(' In total %d cols\n', length(columns));
        for icolIter = 1: length(columns)
            if ~mod(icolIter,1000)
                fprintf('    Processed %d col\n', icolIter);
            end
            icol = columns(icolIter);
            
            record_pixel = [];
            
            idsClear = (y_FmaskS2(:,icol)<2)&(y_orbit==11)&(y_YearS2>2018);
            
            record_pixel.Column = icol;
            record_pixel.OptiNumClearObser= sum(idsClear);
            record_pixel.DOY = squeeze(x_dateS2(:));
            record_pixel.Year = squeeze(y_YearS2(:));
            record_pixel.SR = reshape(y_refS2(:,icol,:),length(idsClear),numBandOptical);
            record_pixel.Ids = reshape(y_IdsS2(:,icol,:),length(idsClear),length(spectralIndices));
            record_pixel.Fmask = y_FmaskS2(:,icol);
            record_pixel.Orbit = y_orbit;
            
            if sum(idsClear) >= numMinObser
                fit_cft_all = [];
                rmse_all = [];

                for iband = 1: numBandOptical
                    [fit_cft, rmse] = fitTimeSeriesModel(x_dateS2(idsClear), y_refS2(idsClear,icol,iband),num_c);
                    fit_cft_all = [fit_cft_all, fit_cft];
                    rmse_all = [rmse_all, rmse];
                end
                if ~isempty(spectralIndices)
                    fit_cft_all_ids = [];
                    rmse_ids_all = [];
                    for iIds = 1: length(spectralIndices)
                        [fit_cft_ids, rmse_ids] = fitTimeSeriesModel(x_dateS2(idsClear), y_IdsS2(idsClear,icol,iIds),num_c);
                        fit_cft_all_ids = [fit_cft_all_ids, fit_cft_ids];
                        rmse_ids_all = [rmse_ids_all, rmse_ids];
                    end
                end
                record_pixel.OptiCoeff = fit_cft_all;
                record_pixel.OptiRMSE = rmse_all;
                record_pixel.IdsCoeff = fit_cft_all_ids;
                record_pixel.IdsRMSE = rmse_ids_all;
            else
                record_pixel.OptiCoeff = zeros(num_c-1,10);
                record_pixel.OptiRMSE = zeros(1,10);
                record_pixel.IdsCoeff = zeros(num_c-1,5);
                record_pixel.IdsRMSE = zeros(1,5);
            end
            record_row = [record_row, record_pixel];
        end
        filepath_var = fullfile(dir_vari, ['varibles_R', num2str(irow), '.mat']);
        save([filepath_var,'.part'],'record_row'); % save as .part
        clear record_row;
        movefile([filepath_var,'.part'],filepath_var) % and then rename it as normal format
    end
end
end
