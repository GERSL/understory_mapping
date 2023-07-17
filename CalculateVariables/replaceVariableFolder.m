function replaceVariableFolder()
    
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));
    dir_working = globalsets.dir_working;

    folder_Variable = globalsets.folder_Variable;
    folder_VariableTSTX = globalsets.folder_VariableTSTX;
    tileNames = globalsets.tileNames;
    
    %check whether all the rows have been processed
    for iTile = 1: length(tileNames)
        tileName = tileNames{iTile};       
        rowfiles_TX = dir(fullfile(dir_working, folder_VariableTSTX, tileName, 'varibles_R*.mat'));
        rows_TX = length(rowfiles_TX);
        rowfiles_TS = dir(fullfile(dir_working, folder_Variable, tileName, 'varibles_R*.mat'));
        rows_TS = length(rowfiles_TS);
        if rows_TX~=rows_TS
            fprintf('The variable files are not totally updated for %s\n',tileName);
            return
        end
    end
    % Rename the old version and rename the updated variable file
    movefile(fullfile(dir_working,folder_Variable),fullfile(dir_working,'InputVariableToDelete'));
    movefile(fullfile(dir_working,folder_VariableTSTX),fullfile(dir_working,folder_Variable));
    rmdir (fullfile(dir_working,'InputVariableToDelete'));
end