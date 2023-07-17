function batchComputeGLCMTexture(task, ntasks)
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
%      tiles = {'T18TYL'};
    % folder of synthetic image
    folder_Synthetic = globalsets.folder_Synthetic;
    
    % Temporal folder of texture calculation
    folder_Texture = 'UniDirGLCM'; 
    folder_GLCMImage = globalsets.folder_GLCMImage;
    directions = globalsets.directions;
    angles = globalsets.angles;
    textureNames2nd = globalsets.textureNames2nd;
    
    img_rng = [2, 98]; % Image processing
    tasks = [];
    counter =1;
  
    for iTile = 1:length(tiles)
        tileName = char(tiles(iTile));
        dir_vari = fullfile(dir_working, folder_Synthetic,folder_Texture, tileName);
        % folder to save the single directional GLCM - temporal
        if ~isfolder(dir_vari)
            mkdir(dir_vari);
        end
        
        ImgPath = fullfile(dir_working,folder_Synthetic,folder_GLCMImage,tileName);
        % folder to save the GLCM results
        if ~isfolder(ImgPath)
            mkdir(ImgPath);
        end
        
        imgs = dir(fullfile(dir_working,folder_Synthetic,tileName, '*.tif'));
        num_img = size(imgs,1);

        for i_img = 1:num_img
            imgName = imgs(i_img).name;
            tasks(counter).maskFilePath = fullfile(dir_working, 'layers',folder_S2ExtCT, [tileName, '.tif']);
            tasks(counter).idName = imgName;
            tasks(counter).inPath = fullfile(dir_working,folder_Synthetic,tileName); % synthetic images
            tasks(counter).uniDirPath = dir_vari; %single directional image
            tasks(counter).GLCMPath = ImgPath; % GLCM image
            tasks(counter).tileName = tileName;
            counter = counter+1;
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
        GLCMName = [tileName,'_GLCM_',task_now.idName(1:end-4)];
        
%         if ~strcmp(imgName,'Synthetic_120_B2.tif') % Miss certain file
%             continue;
%         end
        % judge whether the texture file exists
        if isfile(fullfile( task_now.GLCMPath,[GLCMName,'_8_',char(textureNames2nd(8)),'.tif']))
            fprintf('Texture image have existed: %s \n',fullfile(ImgPath,imgName));
            for i_angle = 1:length(angles)
                angle = char(angles{i_angle});
                if isfile(fullfile(task_now.uniDirPath,[GLCMName,'_dir',angle]))
                    delete (fullfile(task_now.uniDirPath,[GLCMName,'_dir',angle]));
                    fprintf('Having removed %s\n',fullfile(task_now.uniDirPath,[GLCMName,'_dir',angle]));
                else
                    fprintf('No need to remove the unidirectional file\n');
                end
            end
            continue
        end
        fprintf('Begin to compute GLCM textures for %s %s \n', tileName,imgName);
        for i = 1:4
            fprintf('      Compute single directional GLCM textures %s with %0.0f mins\n',char(angles(i)),toc/60);
            directions(i,:)
            computeGLCMTextureSingleDirection(task_now.maskFilePath, task_now.inPath,task_now.tileName, task_now.uniDirPath, task_now.idName,img_rng,textureNames2nd, 9,directions(i,:), 32, char(angles(i)));
        end
        fprintf('      Merge the four directional results ... with %0.0f mins\n',toc/60);
        
        mergeGLCMTextureFourDirection(task_now.maskFilePath, task_now.uniDirPath, GLCMName, task_now.GLCMPath, textureNames2nd);
        fprintf('Finished computing GLCM textures for %s %s with %0.0f mins\r\n', tileName,imgName, toc/60);
    end
end