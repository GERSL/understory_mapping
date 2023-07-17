function mergeGLCMTextureFourDirection(maskFilePath, texturePath, imgName, ImgPath,textureNames2nd)
    
    nrows = globalsets.dimImg(1);
    ncols = globalsets.dimImg(2);
    angles =  globalsets.angles;
    
    % judge whether the texture file exists
    if isfile(fullfile(ImgPath,[imgName,'_8_',char(textureNames2nd(8)),'.tif']))
        fprintf('Texture image have existed: %s \n',fullfile(ImgPath,imgName));
        for i_angle = 1:length(angles)
            angle = char(angles{i_angle});
            if isfile(fullfile(texturePath,[imgName,'_dir',angle]))
                delete (fullfile(texturePath,[imgName,'_dir',angle]));
                fprintf('Having removed %s\n',fullfile(texturePath,[imgName,'_dir',angle]));
            else
                fprintf('No need to remove the unidirectional file');
            end
        end
        return
    end
    fprintf('Check the texture images in path %s \n',ImgPath);
    

    for i_angle = 1:length(angles)
        angle = char(angles{i_angle});
        fprintf('Begin to load %s angle \n',angle);
        if isfile (fullfile(texturePath,[imgName,'_dir',angle]))
            texture2nd(i_angle).value = multibandread(fullfile(texturePath,[imgName,'_dir',angle]),[nrows,ncols,8],'single',0,'bip','ieee-le');
            fprintf('Loaded GLCM textures for %s angle \n',angle);
        else
            fprintf('Lack GLCM textures for %s angle \n',angle);
            return
        end
    end
    textureFourDir = (texture2nd(1).value+texture2nd(2).value+texture2nd(3).value+texture2nd(4).value)/4;
    clear texture2nd
    geotif_obj = GRIDobj(maskFilePath); % Mask with samples
    fprintf('Begin to export Texture images \n');
    for it = 1: length(textureNames2nd)
        geotif_obj.Z = single(textureFourDir(:,:,it));
        GRIDobj2geotiff(geotif_obj, fullfile(ImgPath,[imgName,'_',num2str(it),'_',char(textureNames2nd(it)),'_part.tif']));
    end
    for it = 1:length(textureNames2nd)
        movefile(fullfile(ImgPath,[imgName,'_',num2str(it),'_',char(textureNames2nd(it)),'_part.tif']),fullfile(ImgPath,[imgName,'_',num2str(it),'_',char(textureNames2nd(it)),'.tif'])) % and then rename it as normal format
    end
    for i_angle = 1:length(angles)
        angle = char(angles{i_angle});
        delete (fullfile(texturePath,[imgName,'_dir',angle]));
        fprintf('Having removed %s\n',fullfile(texturePath,[imgName,'_dir',angle]));
    end
    fprintf('Exported GLCM textures for %s \n',imgName);
end