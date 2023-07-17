% combine two pilots together to train a classifier

function classifyRowsCT(task, tasks,dir_working,tileNameHLS,path_Classified,folder_Classified,folder_Variable,variable,modelRF,selectedIds)
    dir_classified = fullfile(dir_working, path_Classified, folder_Classified,tileNameHLS);
    if ~isfolder(dir_classified)
        mkdir(dir_classified);
    end
    
    % prepare the irows for idn_cpu for ALL rows according to S2 variables
    irows = zeros(1,1);
    i = 0;
    rowfiles = dir(fullfile(dir_working, folder_Variable, tileNameHLS, 'varibles_R*.mat'));
    nrows = length(rowfiles);
    while task + tasks*i <= nrows % process all lines
       irows(i+1) = task + tasks*i;
       i = i+1;
    end
    fprintf('%d rows to be processed\n', length(irows));
    for i = 1:length(irows)
        rowfile = rowfiles(irows(i));
        rowfileName = rowfile.name;
        row = str2double(rowfileName(11:end-4)); % classified_R2083.mat
%         if row<9186
%             continue
%         end
        fprintf('Classifying %d th row\n', row);
        
        if isfile(fullfile(dir_classified, ['classified_R', num2str(row), '.mat']))
            fprintf('Having %d th row\n', row);
            continue;
        end
        
        rowfileTS = fullfile(dir_working, folder_Variable, tileNameHLS, rowfileName);
        % load the data for each row
        record_rowTS = load(rowfileTS); % named by record_row
        recordSamplesTS = record_rowTS.record_row;
        
        x_inputs = getClassificationInputsSelectVariables(recordSamplesTS,variable);
        if ~isempty(selectedIds)
            x_inputs = x_inputs(:,selectedIds);
        end
        [typeClassified, probClassify] = classRF_predict(x_inputs,modelRF); % class
%         typeClassified = mergeCategories(typeClassified,{[5 6 7 8 9]},[9],[]);
        
        typeClassified = num2cell(typeClassified);
        probClassify = num2cell(probClassify);
        [recordSamplesTS(:).Type] = deal(typeClassified{:});
        [recordSamplesTS(:).Prob] = deal(probClassify{:});
        
        record_row = keepfield(recordSamplesTS,{'Column','Type','Prob'});
 
%         rmfield(record_row,{'OptiCoeff','OptiRMSE','IdsCoeff','IdsRMSE','SyntheticTX',});
        
        filepath_var = fullfile(dir_classified, replace(rowfileName, 'varibles', 'classified'));
        save([filepath_var,'.part'],'record_row'); % save as .part
        clear record_row recordSamplesTS;
        movefile([filepath_var,'.part'],filepath_var); % and then rename it as normal format
    end
end

function outstruct = keepfield(instruct,fields)
    % OUTSTRUCT = KEEPFIELD(INSTRUCT,FIELDNAMES)
    % Removes all fields from a structure other than those specified in 
    % input variable FIELDS. 
    %
    % FIELDS may be a single field, or a cell array of field names
    %
    % ex:
    % a = dir('*.m');
    % b = keepfield(a,{'name','bytes'});
    %
    % See also: rmfield
    %
    % Written by Brett Shoelson, PhD
    % 3/1/05
    % shoelson@helix.nih.gov
    if nargin ~= 2
        error('Requires 2 input arguments.');
    end
    if ~isa(instruct,'struct')
        error('The first input argument must be a structure.');
    end
    if (~isa(fields,'char') & ~isa(fields,'cell')) | (isa(fields,'cell') & ~all(cellfun('isclass',fields,'char')))
        error('The second input argument must be a string representing the name of a field to keep or a cell array of field names to keep.');
    end
    outstruct = rmfield(instruct,setdiff(fieldnames(instruct),fields));
end