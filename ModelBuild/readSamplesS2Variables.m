function readSamplesS2Variables()
% This function is to load the variables for the samples into a MAT file to
% help the further processing
    restoredefaultpath();
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));
    dir_working = globalsets.dir_working;

    folder_Variable = globalsets.folder_Variable;
    tiles = globalsets.tileNames;
    
    path_Samples = fullfile(dir_working,'layers');
    folder_Samples = globalsets.folder_Samples;
    folder_CTMask = globalsets.folder_S2ExtCT;
    
    strName_SampleVariable = globalsets.strName_SampleVariable;
    strName_SampleImage = globalsets.strName_SampleImage;

    understorySampleVariables = [];
    if exist(fullfile(path_Samples,folder_Samples, [strName_SampleVariable,'.mat']),'file')       
        fprintf('Having existing the variables document for samples');
        return 
    end
    tic
    for iTile = 1 : length(tiles)
        tileName = tiles{iTile};
        
        ctMask = imread(fullfile(path_Samples,folder_CTMask,[tileName,'.tif'])); % Mask layer of the CT to avoid overlap of the tiles
        [samples, ~] = loadSamplesCT(path_Samples,folder_Samples, tileName,strName_SampleImage,ctMask);
        rows = unique(samples(:,1));
        
        for irow = 1: length(rows)
            fprintf('Processing %.2f percent\n',100*(irow/length(rows)));
            row = rows(irow);

            % load variables of S2
            rowfileS2 = fullfile(dir_working, folder_Variable, tileName, ['varibles_R',num2str(row),'.mat']);        
            record_rowS2 = load(rowfileS2); % named by record_row
            record_rowS2 = record_rowS2.record_row;
            recordColsS2 = [record_rowS2.Column]';

            idsSampleCols = find(samples(:,1)==row); % first col is row
            sampleCols = samples(idsSampleCols, 2); % secend is col
            sampleCode = samples(idsSampleCols, 3); % third is type with code
            sampleID = samples(idsSampleCols, 4); % forth is object ID for the sample
    %         find out the points corresponding record obj
            [ismeS2, idsmeS2] = ismember(sampleCols, recordColsS2);
            idsmeS2 = idsmeS2(ismeS2);
            recordSamplesS2 = record_rowS2(idsmeS2);
            [recordSamplesS2(:).Row] = deal(row);
            sampleCodeS2 = num2cell(sampleCode(ismeS2));
            sampleIDS2 = num2cell(sampleID(ismeS2));
            
            [recordSamplesS2(:).Type] = deal(sampleCodeS2{:});
            [recordSamplesS2(:).ID] = deal(sampleIDS2{:});
    %         append records to the end of list
            understorySampleVariables = [understorySampleVariables, recordSamplesS2];
        end
        fprintf('Complete loading %s with %d mins\n',tileName,round(toc/60));
    end
    samples = understorySampleVariables;
    save(fullfile(path_Samples,folder_Samples, strName_SampleVariable),'samples'); 
end
