function  BuildRFModelWithIterativeSelectRepresentativeSample()
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));
    dir_working = globalsets.dir_working;

    % sample variable in MAT format
    path_Samples = fullfile(dir_working,'layers');
    folder_Samples = globalsets.folder_Samples;
    strName_SampleVariable = globalsets.strName_SampleVariable;
    
    understorySamples = load(fullfile(path_Samples,folder_Samples, strName_SampleVariable)).samples;

    variable = globalsets.variable;
     %% Scenario-5 -- broadbands & textures
%     variable.bands(1:10) = 0;    % inputs indices of S2
%     variable.TXbands(1:10) = 0; % remove narrow bands
%     
    numSamplesTotal = globalsets.numSamplesTotal;
    understoryRFModelName = globalsets.understoryRFModelName;
    
    iterTimesDisagree = 1+globalsets.iterTimesDisagree;
    folder_Classifier =  globalsets.folder_Classifier;
    proportion = globalsets.understoryEqualProportion;
    sampleCodes = globalsets.understorySampleCodes;
    dir_out = fullfile(dir_working, [folder_Classifier]);
    
    if ~isfolder(dir_out)
        mkdir(dir_out);
    end
    
    fprintf('RF model based on Sentinel-2 time series coefficients, rmse and GLCM textures \r\n');
    
    y_input = [understorySamples.Type]';
    typesUniq = unique(y_input);
 
    numSamples = zeros(1,length(typesUniq)) + round(numSamplesTotal*[proportion{:,1}]);
    %% save the information into text
    fileID = fopen(fullfile(pwd,'understoryMappingCT.txt'),'w');
    fprintf(fileID,'classfication of the understory species in CT\r\n');
    fprintf(fileID,'RF model based on Sentinel-2 (broadbands and indices: EVI, NDVI, SAVI, NBR, NBNDVI) time series coefficients, rmse and GLCM textures of synthetic images (doy 100 + 120) \r\n\n');
    fprintf(fileID,'Proportion and number of samples for each category of the understory: \r\n');
    fprintf(fileID,'%d times to iteratively select representative %d samples\r\n\n',iterTimesDisagree,numSamplesTotal);
    
    %% inputs variables
    [~,selectedVariables,labels] = getClassificationInputsSelectVariables(understorySamples(1),variable);
    save(fullfile(dir_out,'selectedVariables.mat'),'selectedVariables');
    fprintf(fileID,'Variable list: \r\n');
    for i = 1:length(selectedVariables)
        fprintf(fileID,'%s ',selectedVariables{i});
        if ~mod(i,10)
            fprintf(fileID,'\r\n\n');
        end
    end
    
    %% Train model by using the whole variables at first
    importanceIdx = [];
    modelRF = createClassifierFromIterativeSelectRepresentativeSample(fileID,y_input,understorySamples,numSamples,sampleCodes,variable,selectedVariables,numSamplesTotal,typesUniq,iterTimesDisagree,dir_out,understoryRFModelName,importanceIdx);
    
    fprintf(fileID,'******************************************************************************************************\r\n');
    fclose(fileID);
end