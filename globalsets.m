classdef globalsets
    %% Sets for understory mapping
    properties (Constant)
        %% path in HPC UCONN
        dir_working = '/shared/zhulab/Yang/CTUnderstoryMap/'; % Working direction with origninal Sentinel-2 data and the output coefficients and maps

        %% folders of Sentinel-2 data; Revise the Sentinel-2 data info when applying to other regions out of Connecticut
        folder_S2 = 'Sentinel2'; % Folder of Setninel-2 images under dir_working
        tileNames = {'T18TXL', 'T18TXM','T18TYL','T18TYM'};
        orbit = 11; % Sentinel-2 Single orbit process

        %% folders of input layers (all located as a subfolder in "layers")
        folder_S2ExtCT = 'Sentinel2TileExtentCT'; % Sentinel-2 Tile Extent
        
        %% folders of samples as a subfolder in "layers"
        folder_Samples = 'understoryTrainingSamples'; % Infield sample
        
        %% file name
        strName_SampleVariable = 'understorySampleVariables';
        strName_SampleImage = 'sampleCT'; % file suffix of the samples
    
        %% folders of texture variable calculation and variable reservation
        folder_Synthetic = 'CTSynthetic'; %Synthetic images generated based on time series
        folder_GLCMImage ='GLCMImg';
        
        %% folders to keep the results
        folder_Variable = 'InputVariableConsistent'; % Folder of harmonic time series model
        folder_VariableTSTX = 'InputVariableTSTX'; % Folder of both phenology and texture variables (Temporal)
        path_Map = 'mapCT';
        
        %% folders and fileName for understory species classification
        folder_Classifier =  'classifiers';
        understoryRFModelName = 'modelRF_understorySpecies';
        path_Classified = 'Classified'; % export classified rows
        folder_Classified = globalsets.understoryRFModelName;
           
        %% Calibrated optimal parameters and can be re-calibrated if possible
        NumTopVariable = 75; % Top 75 from 105 default varibles 
        numSamplesTotal = 8000; % understory reprentative samples 
        iterTimesDisagree = 10; % 10 times iteration 
               
        pathAcc = 'accuracyTest'; % Folder to reserve the tested accuracy curves
        pathTSPlot = 'TSPlot'; % Folder to reserve the time series plots

        %% Some default setting for the calculation
        years = [2018 2019 2020]; % Start and end of the years to incorporate and calculate the time series
        leafOffDay = [80 100 120 140]; % interested DOYs to generate the synthethic image and to calculate the textures
                        
        %% GLCM Texture setting
        textureNames2nd = {'Mean', 'Variance', 'Homogeneity', 'Constract', 'Dissimilarity', 'Entropy', 'SecondMoment', 'Correlation'};
        %  only three used:  'Mean','Contract','secondMoment'
        angles = {'0','45','90','135'};
        directions = [0 1; -1 1; -1 0; -1 -1];
     
        %% default input variables include broadbands, indices and their texture information (mean, contrast, second moment) in doy 100 
        variable = createVariable;

        understorySampleCodes = [1, {'barberry'};...
        2,{'greenbriar'};...
        3,{'mixed_invasive'};...
        4,{'mountain_laurel'};...
        5, {'non_target_shrub'};...
        6,{'sparse_coniferous'};...
        7,{'herbaceous'};...
        8,{'tree sapling'};...
        9,{'no understory'};...
        12,{'others'}...  % merge of 5-9 without target understory as "others"
        ]; 

        understoryEqualProportion = [0.2, {'barberry'};... %% Proportions of the training sample to build RF model
            0.2,{'greenbriar'};...
            0.2,{'mixed_invasive'};...
            0.2,{'mountain_laurel'};...
            0.04,{'non_target_shrub'};...
            0.04,{'sparse_coniferous'};...
            0.04,{'herbaceous'};...
            0.04,{'tree_sampling'};...
            0.04,{'no_understory'}]; 
        %% End of sets  ###################
    end
end

function variable = createVariable
    %% Only use indices and texture for understory mapping; Try to filter and remain the useful ones
    variable.bands = ones(1,10); % inputs bands of S2 - NO
    variable.ids = ones(1,5);    % inputs indices of S2
    variable.TXDoy = [100 120];  % doy of the texture: 80 100 120 140
    variable.TXmetric = [1 0 0 1 0 0 1 0]; % List: 'Mean';'Variance'; 'Homogeneity'; 'Constract';'Dissimilarity'; 'Entropy';'SecondMoment';'Correlation'
    variable.TXbands = ones(1,15); % bands sto calculate the texture
    variable.TXbands(7:10)=0; % remove narrow bands
    variable.bands(7:10) = 0; % inputs bands of S2 Narrowbands- NO
end