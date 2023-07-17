function batchComputeGLCMTextureSingleDir(task, ntasks)
    if ~exist('task', 'var')
        task = 1;
    end
    if ~exist('ntasks', 'var')
        ntasks = 1;
    end
    addpath(pwd);
    [dir_codes,~,~]=fileparts(pwd);
    addpath(dir_codes);
    addpath(genpath(fullfile(dir_codes,'Packages')));

    dir_working = globalsets.dir_working;
    folder_S2ExtCT = globalsets.folder_S2ExtCT;
    tiles = globalsets.tileNames;
    % folder of synthetic image
    folder_Synthetic = globalsets.folder_Synthetic;
    % Temporal folder of texture calculation
    folder_Texture = 'UniDirGLCM'; 

    directions = globalsets.directions;
    angles = globalsets.angles;
    textureNames2nd = globalsets.textureNames2nd;
    
    img_rng = [2, 98]; % Image processing
    tasks = [];
    counter =1;
    for i_dir = 1:length(directions)

        for iTile = 1:length(tiles)
            tileName = char(tiles(iTile));
            dir_vari = fullfile(dir_working, folder_Synthetic,folder_Texture, tileName);

            if ~isfolder(dir_vari)
                mkdir(dir_vari);
            end

            imgs = dir(fullfile(dir_working,folder_Synthetic,tileName, '*.tif'));
            num_img = size(imgs,1);

            for i_img = 1:num_img
                imgName = imgs(i_img).name;
                tasks(counter).maskFilePath = fullfile(dir_working, 'layers',folder_S2ExtCT, [tileName, '.tif']);
                tasks(counter).idName = imgName;
                tasks(counter).inPath = fullfile(dir_working,folder_Synthetic,tileName);
                tasks(counter).outPath = dir_vari;
                tasks(counter).tileName = tileName;
                tasks(counter).dir = directions(i_dir,:);
                tasks(counter).angle = char(angles(i_dir));
                counter = counter+1;
            end
        end

    end
    
    totalTasks = length(tasks);
    tasks_per = ceil(totalTasks/ntasks);
    start_i = (task-1)*tasks_per + 1;
    end_i = min(task*tasks_per, totalTasks);
    
    for i_task = start_i: end_i
        task_now = tasks(i_task);
        tic
        imgName = task_now.idName;
        tileName = task_now.tileName;
        fprintf('Begin to compute GLCM textures for %s %s \n', tileName,imgName);
%         if ~strcmp(imgName,'Synthetic_120_B2.tif') % Miss certain file
%             continue;
%         end
%         if ~strcmp(task_now.angle,'0')
%             continue;
%         end
         if isfile(fullfile(dir_working, folder_Synthetic, 'GLCMImg',task_now.tileName, [task_now.tileName,'_GLCM_',task_now.idName(1:end-4),'_8_',char(textureNames2nd(8)),'.tif']))
            fprintf('Texture image have existed: %s \n',fullfile(tileName,imgName));
            continue
        end
        computeGLCMTextureSingleDirection(task_now.maskFilePath, task_now.inPath,task_now.tileName, task_now.outPath, task_now.idName,img_rng,textureNames2nd, 9,task_now.dir, 32, task_now.angle)
        fprintf('Finished computing GLCM textures for %s %s with %0.2f mins\r\n', tileName,imgName, toc/60);
    end
end