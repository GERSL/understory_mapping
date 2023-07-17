function batchExportMapCT(task, tasks)
    if ~exist('task', 'var')
        task = 1;
    end
    if ~exist('tasks', 'var')
        tasks = 1;
    end
 
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));
    dir_working = globalsets.dir_working;
   
    path_Classified = globalsets.path_Classified;
    folder_Classified = globalsets.folder_Classified;
    path_Map = globalsets.path_Map;
    folder_Map = folder_Classified;
    folder_S2ExtCT = globalsets.folder_S2ExtCT;
    
    % number of the top variables (based on importance test, default value = 65)
    NumTopVariable = globalsets.NumTopVariable;
%     folder_DeciduousForestLayer = 'mapForest/Field';
    tiles = globalsets.tileNames;

    allTasks = [];
    itask = 1;
    for iTile = 1: length(tiles)
        allTasks(itask).tileName = tiles{iTile};
        itask = itask + 1;
    end
    totalTasks = length(allTasks);
    tasks_per = ceil(totalTasks/tasks);
    start_i = (task-1)*tasks_per + 1;
    end_i = min(task*tasks_per, totalTasks);
    for i_task = start_i: end_i
        tileName = allTasks(i_task).tileName     
        %% export map from the default variables
%         fprintf('Export map by using the default variables\n')
%         nameStr = '_default';
%         autoExportMapCT(dir_working,path_Classified,folder_Classified,path_Map,folder_Map,folder_S2ExtCT,tileNameHLS,nameStr);  

         %% export map from the top variables
        fprintf('Export map for tile %s \n',tileName);
        folder_Map_temp = folder_Classified(9:end);
        autoExportMapCT(dir_working,path_Classified,folder_Classified,path_Map,folder_Map_temp,folder_S2ExtCT,tileName);  

    end

end
