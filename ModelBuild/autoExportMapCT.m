function autoExportMapCT(dir_working,path_Classified,folder_Classified,path_Map,folder_Map,folder_S2ExtCT,tileName)
    dir_map = fullfile(dir_working, path_Map, folder_Map);
    if ~isfolder(dir_map)
        mkdir(dir_map);
    end
    path_wholemap = fullfile(dir_map, [tileName,'_wholeCover.tif']);
%     path_typemap = fullfile(dir_map, [tileNameHLS, nameStr,'_withInDeciduous.tif']);
    path_probmap = fullfile(dir_map, [tileName, '_Prob.tif']);
    
    % Mask the study area
    maskRng =  fullfile(dir_working,'layers' ,folder_S2ExtCT, [tileName, '.tif']); % Remain CT
    maskGridobj = GRIDobj(maskRng);
    maskCT = maskGridobj.Z;
    maskCT(isnan(maskCT)) = 0;
    
    maskGridobj.Z = zeros(maskGridobj.size);
    typeGridobj = maskGridobj;
    typeGridobj.Z = uint8(typeGridobj.Z);
    probGridobj = maskGridobj;
    probGridobj.Z = int16(probGridobj.Z);
    
    rowfiles = dir(fullfile(dir_working, path_Classified, folder_Classified, tileName, 'classified_R*.mat'));

    for irow = 1: length(rowfiles)
        rowfile = rowfiles(irow);
        rowfileName = rowfile.name;

        row = str2double(rowfileName(13:end-4)); % classified_R2083.mat
        fprintf('Processing %d th row\n', row);

        rowfile = fullfile(dir_working, path_Classified,folder_Classified, tileName, rowfileName);
        % load the data for each row
        load(rowfile); % named by record_row
        
        columns = [record_row.Column]';
        rows = zeros(size(columns)) + row;
        inds = sub2ind(maskGridobj.size, rows, columns);
        typeGridobj.Z(inds) = [record_row.Type];
        probGridobj.Z(inds) = [record_row.Prob].*100;
    end
    
    typeGridobj.Z(~maskCT)= 0;
    probGridobj.Z(~maskCT)= 0;
    typeGridobj.Z(typeGridobj.Z==12)= 9;
    GRIDobj2geotiff(typeGridobj, path_wholemap);
    GRIDobj2geotiff(probGridobj, path_probmap);
end
