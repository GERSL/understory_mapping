function computeGLCMTextureSingleDirection(maskFilePath, inPath,tileName, outPath, imgName,img_rng,textureNames2nd, windowsize, direction, nl, angle)
    if ~isfolder(outPath)
        mkdir(outPath);
    end
    % judge whether the texture file exists
    if isfile(fullfile(outPath,[tileName,'_GLCM_',imgName(1:end-4),'_dir',angle]))
        fprintf('Find the single-angled texture results in path: %s \n',fullfile(outPath,[tileName,'_GLCM_',imgName(1:end-4),'_dir',angle]))
        return
    end
    maskRng = GRIDobj(maskFilePath); % Mask with samples
    
    [nrows,ncols] = size(maskRng.Z);
    textureMap = 9999*ones(nrows,ncols,length(textureNames2nd),'single'); % e.g., 1365:  1 is type; 365 is DOY;
    
    [maskRow, maskCol] = find(maskRng.Z > 0); % All data
    rowMin = min(maskRow);
    rowMax = max(maskRow);
    colMin = min(maskCol);
    colMax = max(maskCol);
    
%     % To have test for a 300*300 region
%      rowMax = min(maskRow)+2000;
%      colMax = min(maskCol)+2000;
%     
    textureFile = fullfile(inPath,imgName);
    geotif_obj = GRIDobj(textureFile);
    ROIImage = geotif_obj.Z(rowMin:rowMax,colMin:colMax);
    
    min_val = prctile(ROIImage(:), img_rng(1));
    max_val = prctile(ROIImage(:), img_rng(2));
    ROIImage(ROIImage<min_val) = min_val;
    ROIImage(ROIImage>max_val) = max_val;
    geotif_obj.Z(:,:) = 0;
    
    if ~ isfile (fullfile(outPath,[tileName,'_GLCM_',imgName(1:end-4),'_dir',angle]))
        fprintf('Computing GLCM textures for %s angle \n',angle);
        texture2nd_dir = GLCMTextures(ROIImage,textureNames2nd, windowsize,  direction,  nl);
        textureMap(rowMin:rowMax,colMin:colMax,:) = single(texture2nd_dir);
        textureMap(maskRng.Z < 1) = 9999;
        multibandwrite(textureMap,fullfile(outPath,[tileName,'_GLCM_',imgName(1:end-4),'_dir',angle]),'bip','precision','single');
%         test  = multibandread(fullfile(outPath,[tileName,'_GLCM_',imgName(1:end-4),'_dir',angle]),[nrows,ncols,8],'single',0,'bip','ieee-le');
    else
        fprintf('Having GLCM textures for %s angle \n',angle);
    end
end