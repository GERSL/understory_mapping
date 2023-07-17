%% Load HLS data
function textureLayers = load2ndTextureData (dir_working,folder_image,folder_Texture, tileName, ...
                                                textureNames2nd,nameStr, pixLoc, numColumns)                          
    dir_Texture = fullfile(dir_working, folder_image, folder_Texture, tileName);
%     imgsTx = [dir(fullfile(dir_Texture, 'T*_2nd_*tif'));dir(fullfile(dir_Texture, 'T*_1st_*tif'))];
    imgsTx = dir(fullfile(dir_Texture, 'T*_GLCM_*tif'));
%     imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_2nd_(\w*)_',nameStr,'(\w*)'], 'match');
%     imgs2nd = [imgs2nd{:}];
    
    textureLayers = zeros(length(textureNames2nd), 15,numColumns, 'double'); %Ys
    
    pixEdge = [1, numColumns];
    
    % Each texture
    for it = 1: length(textureNames2nd)
        % See the Eqs from https://www.l3harrisgeospatial.com/docs/backgroundtexturemetrics.html
        switch textureNames2nd{it}
            case 'Mean'
                imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileName);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(1,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'Variance'
                imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(2,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'Homogeneity'
                 imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(3,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'Constract' 
                imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(4,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'Dissimilarity'
                 imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(5,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'Entropy'
                imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(6,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'SecondMoment' % also named by Energy in Matlab
                imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(7,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
            case 'Correlation'
                imgs2nd = regexpi({imgsTx.name}, ['T(\w*)_GLCM_',nameStr,'_(\w*)_',num2str(it),'_',textureNames2nd{it},'(\w*)'], 'match');
                imgs2nd = [imgs2nd{:}];
                irow = regexp(imgs2nd,'\d*','Match'); % row of the pixels
                irow = vertcat(irow{:});
                bands = irow(:,end-1);
                bands = str2double(bands);
                [~,sorted] = sort(bands);
                imgs2nd = imgs2nd(sorted);
                if length(imgs2nd)~=15
                    fprintf('not enough band image for 2nd texture %s \r\n', tileNameS2);
                    return
                end
                for i = 1: 15
                    path_img = fullfile(dir_Texture, [imgs2nd{i},'.tif']);
                    textureLayers(8,i,:) = imread(path_img, 'PixelRegion', {[pixLoc(1), pixLoc(1)+pixEdge(1)-1], [pixLoc(2), pixLoc(2)+pixEdge(2)-1]});
                end
        end
    end
end

