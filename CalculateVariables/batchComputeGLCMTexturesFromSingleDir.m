function batchComputeGLCMTexturesFromSingleDir(task, ntasks)
% This function is to calculate the direction averaged texture values
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
    folder_Texture = 'UniDirGLCM'; 
   
    folder_GLCMImage = globalsets.folder_GLCMImage;
    folder_Synthetic = globalsets.folder_Synthetic;

    textureNames2nd = globalsets.textureNames2nd;
    
    tasks = [];
    counter =1;
    for iTile = 1:length(tiles)
        tileName = char(tiles(iTile));         

        ImgPath = fullfile(dir_working,folder_Synthetic,folder_GLCMImage,tileName);
        if ~isfolder(ImgPath)
            mkdir(ImgPath);
        end
        imgs = dir(fullfile(dir_working,folder_Synthetic,folder_Texture,tileName, '*_dir0'));
        num_img = size(imgs,1);
        for i_img = 1:num_img
            imgName = imgs(i_img).name;
            tasks(counter).maskFilePath = fullfile(dir_working,'layers', folder_S2ExtCT, [tileName, '.tif']);
            tasks(counter).idName = imgName(1:end-5);
            tasks(counter).ImgPath = ImgPath;
            tasks(counter).texturePath = fullfile(dir_working, folder_Synthetic,folder_Texture, tileName);
            tasks(counter).tileName = tileName;
            counter = counter+1;
        end
    end
    
    totalTasks = length(tasks);
    tasks_per = ceil(totalTasks/ntasks);
    start_i = (task-1)*tasks_per + 1;
    end_i = min(task*tasks_per, totalTasks);
    tic
    for i_task = start_i: end_i
        task_now = tasks(i_task);
        imgName = task_now.idName;
        fprintf('Begin to compute GLCM textures for %s\n',imgName);
        mergeGLCMTextureFourDirection(task_now.maskFilePath, task_now.texturePath, task_now.idName, task_now.ImgPath, textureNames2nd)
        fprintf('Finished computing GLCM textures for %s with %0.2f mins for task %d/%d\r\n',imgName, toc/60,i_task-start_i+1,end_i-start_i+1); 
    end
end