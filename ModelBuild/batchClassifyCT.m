function batchClassifyCT(task, tasks)
    if ~exist('task', 'var')
        task = 1;
    end
    if ~exist('tasks', 'var')
        tasks = 1;
    end
    addpath(pwd);
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));
    dir_working = globalsets.dir_working;
    
    %% default variable value for prior classifier
    variable = globalsets.variable;
    folder_Classifier =  globalsets.folder_Classifier;
    path_Classified = globalsets.path_Classified;
    folder_Classified = globalsets.folder_Classified;
    folder_Variable = globalsets.folder_Variable;
    tiles = globalsets.tileNames;
%     tiles = {'T18TXL'};
    % number of the top variables (based on importance test, default value = 65)
    NumTopVariable = globalsets.NumTopVariable;
    
    % load the RF model 
    understoryRFModelName = globalsets.understoryRFModelName;
%     modelRF = dir(fullfile(dir_working, folder_Classifier, [understoryRFModelName,'*75*.mat']));
    modelRF = dir(fullfile(dir_working, folder_Classifier, [understoryRFModelName,'*_i10.mat']));
    modelRF = load(fullfile(dir_working, folder_Classifier, modelRF.name));
    modelRF = modelRF.modelRF;
    % load the selected variables and index of top variables
    importanceIdx = []; % Use the whole variables to conduct the classification
    for iTile = 1: length(tiles)
        tileName = tiles{iTile};
        %% Classify based on top varibles
        fprintf('\n Classify by top variables \n');
        
        % Folder of the classified row files
        classifyRowsCT(task,tasks,dir_working,tileName,path_Classified,folder_Classified,folder_Variable,variable,modelRF,importanceIdx);
    end
end