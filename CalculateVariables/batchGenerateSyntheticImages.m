function batchGenerateSyntheticImages(task, ntasks)
    if ~exist('task', 'var')
        task = 1;
    end
    if ~exist('ntasks', 'var')
        ntasks = 4;
    end
%     addpath(pwd);
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));
    dir_working = globalsets.dir_working;

    folder_Variable = globalsets.folder_Variable;
    folder_S2ExtCT = globalsets.folder_S2ExtCT;
    tiles = globalsets.tileNames;
    SytheticDoys = globalsets.leafOffDay;
    SytheticDoys = 196;
    folder_Synthetic = globalsets.folder_Synthetic;
%     tiles =  {'T18TXM'};
    tasks = [];
    itask = 1;
    for iTile = 1: length(tiles)     
        for iDoy = 1:length(SytheticDoys)
            tasks(itask).tileName = tiles{iTile};
            tasks(itask).doy = SytheticDoys(iDoy);
            itask = itask + 1;
        end
    end

    totalTasks = length(tasks);
    tasks_per = ceil(totalTasks/ntasks);
    start_i = (task-1)*tasks_per + 1;
    end_i = min(task*tasks_per, totalTasks);
    
    for i_task = start_i: end_i
        task_now = tasks(i_task);
        tileName = task_now.tileName
        SytheticDoy = task_now.doy
        generateSyntheticImage(dir_working,folder_S2ExtCT,folder_Variable,folder_Synthetic,tileName,SytheticDoy);
    end
end