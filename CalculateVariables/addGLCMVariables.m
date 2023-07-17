function addGLCMVariables(task, tasks)
% This function attach the texture information into the phenology
% coefficients
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


folder_Variable = globalsets.folder_Variable;
folder_VariableTSTX = globalsets.folder_VariableTSTX;

folder_GLCMImage = globalsets.folder_GLCMImage;
folder_Synthetic = globalsets.folder_Synthetic;

textureNames2nd = globalsets.textureNames2nd;
tileNames = globalsets.tileNames;


SytheticDoys = globalsets.leafOffDay;

numColumns= 10980; % pixels

for iTile = 1: length(tileNames)
    tileName = tileNames{iTile};

    dir_vari = fullfile(dir_working, folder_VariableTSTX, tileName);
    if ~isfolder(dir_vari)
        mkdir(dir_vari);
    end
   
    rowfiles = dir(fullfile(dir_working, folder_Variable, tileName, 'varibles_R*.mat'));
    rows = length(rowfiles);
    
     % prepare the irows for idn_cpu for ALL rows according to S2 variables
    irows = zeros(1,1);
    i = 0;
    while task + tasks*i <= rows % process all lines
       irows(i+1) = task + tasks*i;
       i = i+1;
    end
    
     fprintf('%d rows to be propossed in this core and tile of %s \n', length(irows),tileName);
     tic
     for i = 1:length(irows)
%         try
        rowfile = rowfiles(irows(i));
        rowfileName = rowfile.name;
        row = str2double(rowfileName(11:end-4)); % classified_R2083.mat

        fprintf('   Begin to add texture info %d th row\n', row);    
        if isfile(fullfile(dir_vari, ['varibles_R', num2str(row), '.mat']))
            fprintf('Having %d th row\n', row);
            continue;
        end

        rowfileTS = fullfile(dir_working, folder_Variable, tileName, rowfileName);
        % load the data for each row
        record_rowTS = load(rowfileTS); % named by record_row
        record_rowTS = record_rowTS.record_row;
        columns = [record_rowTS.Column]'; 

        pixLoc = [row, 1]; % Row Column (sample to Line/ Sample in ENVI)
        for iDoy = 1:length(SytheticDoys)
            doy = ['Synthetic_',num2str(SytheticDoys(iDoy))];
            textureSynthetic(iDoy).TX2nd = load2ndTextureData (dir_working,folder_Synthetic,folder_GLCMImage, tileName, ...
                                        textureNames2nd,doy, pixLoc, numColumns);
            textureSynthetic(iDoy).DOY = SytheticDoys(iDoy);                    
        end
        fprintf(' Succeed to load Texture info \n');
       
        fprintf(' In total %d cols\n', length(columns));
        record_row = [];
        for icolIter = 1: length(columns)
            if ~mod(icolIter,2500)
               fprintf('    Processed %d col\n', icolIter);
            end
            icol = columns(icolIter);
            
            for iDoy = 1:length(SytheticDoys)
                synTX(:,:,iDoy) = textureSynthetic(iDoy).TX2nd(:,:,icol);                 
            end
            
            record_pixel.Column = icol;
            record_pixel.OptiCoeff = record_rowTS(icolIter).OptiCoeff;
            record_pixel.OptiRMSE = record_rowTS(icolIter).OptiRMSE;
            record_pixel.IdsCoeff = record_rowTS(icolIter).IdsCoeff;
            record_pixel.IdsRMSE = record_rowTS(icolIter).IdsRMSE;
            
            record_pixel.SyntheticTX = synTX;
            record_pixel.SyntheticDOY = SytheticDoys;
            
            record_pixel.DOY = record_rowTS(icolIter).DOY;
            record_pixel.Year = record_rowTS(icolIter).Year;
            record_pixel.SR = record_rowTS(icolIter).SR;
            record_pixel.Orbit = record_rowTS(icolIter).Orbit;
            record_pixel.Fmask = record_rowTS(icolIter).Fmask;
%            record_pixel.Ids = record_rowTS(icolIter).Ids;
            
            record_row = [record_row, record_pixel];
        end
        filepath_var = fullfile(dir_vari, ['varibles_R', num2str(row), '.mat']);
        save([filepath_var,'.part'],'record_row'); % save as .part
        clear record_row;
        movefile([filepath_var,'.part'],filepath_var); % and then rename it as normal format
        fprintf('Having saved row %d (%d/%d) with %d mins\n',row,i,length(irows),round(toc/60));
     end
end
end
