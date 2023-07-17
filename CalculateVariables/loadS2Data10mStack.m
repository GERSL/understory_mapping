%% Load HLS data
function [x_date, y_ref, y_ids, y_sensor, y_Fmask, y_orbit] = loadS2Data10mStack (dir_working,folder_S2, tileNameS2, ...
                                                pixLoc, numColumns, dataset, years,ids)       
    if ~exist('dataset', 'var')
        dataset = 'stack';
    end
    % which years?
    if ~exist('years', 'var')
        years = [0 9999];% [start year   end year]
    end
    % if only one year input, then we copt one to start and one to end
    if length(years) == 1
        years = [years years];
    end

    % number of bytes: int16
    num_byte = 2;
    nbands = 11;

    % tileNameS2 = tileNameS2(end-5:end);
    dir_S2 = fullfile(dir_working, folder_S2, dataset, tileNameS2);
    
    imgsS2 = dir(fullfile(dir_S2, 'T*'));
    % T18TYM_S2A_2019003_20190103T15464
    imgsS2 = regexpi({imgsS2.name}, 'T(\w*)_(\w*)_(\w*)_(\w*)', 'match');
    if isempty(imgsS2)
        error('Could not find S2 image for directory %s\n', tileNameS2);
    end
    imgsS2 = [imgsS2{:}];
    imgsS2 = vertcat(imgsS2{:});
    % sort according to yeardoy
    % doys = str2num(imgsS2(:, 16:18));

    
    dates = datenum(imgsS2(:,20:27), 'yyyymmdd');
    % within year range
    idsDate = find(dates >= datenum(min(years),1,1) & dates < datenum(max(years)+1,1,1));
    dates = dates(idsDate);
    imgsS2 = imgsS2(idsDate, :);
   
    % sort
    [~, sort_order] = sort(dates);
    x_date = dates(sort_order, :);
    imgsS2 = imgsS2(sort_order, :);
    % number of S2 images
    numS2Image = size(imgsS2,1);
    
    % Orbit info
    y_orbit = str2num(imgsS2(:,end-2:end));
    %% Read in Xs & Ysq
    % transforming to serial date number (0000 year)
    y_ref = zeros(numS2Image, numColumns, nbands, 'int16'); %Ys
    % y_ref_stack = zeros(numS2Image, nbands, numColumns, 'int16'); %Ys
    % y_sensor = zeros(numS2Image, 1, 'uint8');
    y_sensor = year(datetime(x_date, 'ConvertFrom', 'datenum'));
    x_date = day(datetime(x_date, 'ConvertFrom', 'datenum'),'dayofyear');
    
    for i = 1: numS2Image
        im = fullfile(dir_S2, imgsS2(i, :),[imgsS2(i, :),'_MTLstack']);
        if ~isfile(im)
            error('Could not find stack image for directory %s\n', imgsS2(i, :));
        end
        dummy_name = im;
        fid_t = fopen(dummy_name,'r'); % get file ids
        fseek(fid_t,num_byte*(pixLoc(1)-1)*numColumns*nbands,'bof');
        line_t(i,:) = fread(fid_t,nbands*numColumns,'int16','ieee-le'); % get Ys
    end
    y_ref_stack = reshape(line_t,numS2Image,nbands,numColumns);
    y_ref_stack = permute(y_ref_stack,[1,3,2]); 
    y_ref = y_ref_stack(:,:,(1:end-1));
    y_Fmask = y_ref_stack(:,:,end);
    y_Fmask(y_ref(:,:,1)<=0|y_ref(:,:,1)>=10000|...
        y_ref(:,:,2)<=0|y_ref(:,:,2)>=10000| ...
        y_ref(:,:,3)<=0|y_ref(:,:,3)>=10000| ...
        y_ref(:,:,4)<=0|y_ref(:,:,4)>=10000| ...
        y_ref(:,:,5)<=0|y_ref(:,:,5)>=10000| ...
        y_ref(:,:,6)<=0|y_ref(:,:,6)>=10000| ...
        y_ref(:,:,7)<=0|y_ref(:,:,7)>=10000| ...
        y_ref(:,:,8)<=0|y_ref(:,:,8)>=10000| ...
        y_ref(:,:,9)<=0|y_ref(:,:,9)>=10000| ...
        y_ref(:,:,10)<=0|y_ref(:,:,10)>=10000)= 255;
    % Calculate the indices
    if ~isempty(ids)
        for i_ids = 1:length(ids)
            switch ids{i_ids}
                case 'EVI'
                    indexvalue = 2.5*(y_ref(:,:,4)-y_ref(:,:,3))./(y_ref(:,:,4)+6*y_ref(:,:,3)-7.5*y_ref(:,:,1)+10000);
                case 'NDVI'
                    indexvalue = (y_ref(:,:,4)-y_ref(:,:,3))./(y_ref(:,:,4)+y_ref(:,:,3)+eps);
                case 'SAVI'
                    indexvalue = 1.5*(y_ref(:,:,4)-y_ref(:,:,3))./(y_ref(:,:,4)+y_ref(:,:,3)+5000);
                case 'NBR'
                    indexvalue = (y_ref(:,:,4)-y_ref(:,:,6))./(y_ref(:,:,4)+y_ref(:,:,6)+eps);
                case 'RENDVI'
                    indexvalue = (y_ref(:,:,8)-y_ref(:,:,7))./(y_ref(:,:,8)+y_ref(:,:,7)+eps);
            end
            y_ids(:, :, i_ids) = indexvalue;
        end
        y_ids = y_ids*10000;
    end
    
end