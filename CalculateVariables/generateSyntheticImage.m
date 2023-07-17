function generateSyntheticImage(dir_working,folder_S2ExtCT,folder_variable,folder_Synthetic,tileName,leafOffDay)
    % This function is used to export annual, bi-Modal, tri-Modal coefficients
    dir_CT = fullfile(dir_working,'layers', folder_S2ExtCT, [tileName, '.tif']);
    maskCT = GRIDobj(dir_CT);
    [nrows,ncols] = size(maskCT.Z);
    % % Produce the coefficient maps
    nBands = 10; % 7 Landsat bands + 1 QA band + 1WL band
    nIds = 5;
    for iDay = 1:length(leafOffDay)
        synthetic(iDay).Image = 32767*ones(nrows,ncols,nBands+nIds,'int16'); % predicted image 
        synthetic(iDay).Doy = leafOffDay(iDay);
    end
    dir_OutImage = fullfile(dir_working, folder_Synthetic, tileName);
    fprintf('The location of the exported sythetic images %s\n',dir_OutImage);
    if ~isfolder(dir_OutImage)
        mkdir(dir_OutImage);
    end

    imf = dir(fullfile(dir_working,folder_variable,tileName, 'varibles_R*'));
    num_line = size(imf,1);

    for line = 1:num_line
        % load one line of time series Modals
        
        irow = regexp(imf(line).name,'\d*','Match'); % row of the pixels
        
        % show processing status
        if line/num_line < 1
            fprintf('Processing %.2f (%d) percent\r',100*(line/num_line),str2double(irow));
        else
            fprintf('Processing %.2f percent\n',100*(line/num_line));
        end
%         if str2double(irow)<5224 | str2double(irow)>9999
%             continue
%         end
        
        record_rowS2 = load(fullfile(dir_working,folder_variable, tileName,imf(line).name));
        record_rowS2 = record_rowS2.record_row;
        recordColsS2 = [record_rowS2.Column]'; % valid columns of the pixels
        
        if isempty(recordColsS2)
            continue
        end
        SRCoefs = [record_rowS2.OptiCoeff];
        IdsCoefs = [record_rowS2.IdsCoeff];
        %% Temporal check whether c is reserved in .mat file
        if size(SRCoefs,1)==17
            SRCoefs = [SRCoefs(1,:);zeros(1,size(SRCoefs,2));SRCoefs(2:end,:)];
            IdsCoefs = [IdsCoefs(1,:);zeros(1,size(IdsCoefs,2));IdsCoefs(2:end,:)];
        end
        
        %% calculate the synthetic values
        for iDay = 1:length(leafOffDay)
            doy = leafOffDay(iDay);
            predSR = autoTSPred(doy,SRCoefs);
            predIds = autoTSPred(doy,IdsCoefs);
            predSR = reshape(predSR,nBands,[]);
            predIds = reshape(predIds,nIds,[]);
            temp = [predSR;predIds]';
            synthetic(iDay).Image(str2double(irow),recordColsS2,:) = round(temp);
        end
    end
    geotif_obj = maskCT;
    for iDay = 1:length(leafOffDay)
        for iBand = 1: nBands+nIds
%         for iBand = 1: nBands   
            geotif_obj.Z = int16(synthetic(iDay).Image(:,:,iBand));
            geotif_obj.Z(maskCT.Z~=1) = 32767;
            GRIDobj2geotiff(geotif_obj, fullfile(dir_OutImage,['Synthetic_',num2str(synthetic(iDay).Doy),'_B',num2str(iBand),'.tif']));
        end
    end

    return;
end