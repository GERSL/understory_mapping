function glcmtextlayers = GLCMTextures(image, texturenames, windowsize,  offset,  nl)
% This version is to be more efficent by sharing some varibles 
% (i.e., 10.207390 seconds vs. 12.332346 seconds for the first 100 rows of the example Landsat data). 
%
%
% INPUT:
%
%   image:         Single Band Image. Note when sometimes image has noises, such as cloud, shadow, and statured, a linear scaled image within a certain range (i.e., 2%~98%) is recommanded.
%
%   texturenames:  {'Mean', 'Variance', 'Homogeneity', 'Constract', 'Dissimilarity', 'Entropy', 'SecondMoment', 'Correlation'}. If empty, all the textures will be created. 
%
%   windowsize:    Moving window size of computing textures.  i.e., 9 pixel means 9 pixels by 9 pixels
%
%   offset:        Direction for offsetting for second-order texture. See bellow description for details.
%
%   nl:            Number of gray level of the co-occurance matrix, like 64, 32, 16, 8
%
% Bellow desribes a simple matrix (c: central pixel, and p: pixel) to define the offset.
%
% In MATLAB (offset = [row column]): 
%
%    (135 degrees: [-1 -1])   (90 degrees: [-1 0])
%                         p - p - p (45 degrees: [-1 1])
%                         |   |   |
%                         p - c - p (0 degree: [0 1])
%                         |   |   |
%                         p - p - p
%
% In ENVI (offset = [sample line]): 
%
%    (135 degrees: [-1 -1])   (90 degrees: [0 -1])
%                         p - p - p (45 degrees: [1 -1])
%                         |   |   |
%                         p - c - p (0 degree: [1 0])
%                         |   |   |
%                         p - p - p
%
% Also see offset in matlab from https://www.mathworks.com/help/images/ref/graycomatrix.html
% Also see offset in ENVI from https://www.l3harrisgeospatial.com/docs/backgroundtexturemetrics.html
%
%
%
% References:
% Mean of ENVI's GLCM https://stackoverflow.com/questions/36005639/image-texture-glcm-mean-envi#:~:text=ENVI%20calculates%20the%20mean%20as,version%20of%20your%20original%20image.
%
% 
% AUTHOR(s): Shi Qiu
% DATE: Mar. 4, 2021
% COPYRIGHT @ GERSLab
%
%
%
% Define textures, and if no spectified, all the textures

% Define window size
windowradium = (windowsize - 1)/2; % 4 pixels

image = double(image*10000);

glcmtextlayers = zeros([size(image), length(texturenames)]);

%% Scale the entire image based on min and max
gl = [min(image(:)) max(image(:))];
slope = nl / (gl(2) - gl(1));
intercept = 1 - (slope*(gl(1)));
synimage_scaled = floor(imlincomb(slope, image, intercept, 'double'));
% Clip values if user had a value that is outside of the range
synimage_scaled(synimage_scaled > nl) = nl;
synimage_scaled(synimage_scaled < 1) = 1;

%% Offset for GLCM first
% shift to the opposite direction to have pairs
% moving window shift to the right, but the image needs to shift to the left
synimage_scaled_offset = circshift(synimage_scaled,  0 - offset);
% Fill NaN for the edges, and this will be ingored to generate GLCM
synimage_scaled_offset(1:abs(offset(1)), :) = NaN;
synimage_scaled_offset(end - abs(offset(1)) + 1: end, :) = NaN;
synimage_scaled_offset(:, 1:abs(offset(2))) = NaN;
synimage_scaled_offset(:, end - abs(offset(2)) +1: end) = NaN;

tic
%% Function of calcaulting the GLCM by moving window with 9 pixels by 9 pixels
[rlength, clength] = size(image); % length of rows and  columns
for ir = 1: rlength
%     fprintf('Computing GLCM textures for %0.2f percentage\n', ir/rlength*100);
    for ic = 1: clength
        % Pick out the pixels within the current sliding window
        win_rows = max(1, ir - windowradium): min(ir + windowradium, rlength);
        win_cols = max(1, ic - windowradium): min(ic + windowradium, clength);

        % Routes for transfering 
        Ind = [reshape(synimage_scaled(win_rows, win_cols), [], 1), ...
                reshape(synimage_scaled_offset(win_rows, win_cols), [], 1)];
        Ind(any(isnan(Ind),2),:) = []; % Remove pixel and its neighbor if their value is NaN.
        % Tabulate the occurrences of pixel pairs
        glcm = accumarray(Ind, 1, [nl nl]);
          
        % Normalize GLCM
        glcm = glcm ./ sum(glcm(:));
        
        % Get row and column subscripts of GLCM.  These subscripts correspond to the
        % pixel values in the GLCM. Ahead of time, do not need to compute
        % it for each texture
        [c,r] = meshgrid(1:size(glcm, 1),1: size(glcm, 2));
        r = r(:) - 1; c = c(:) - 1; % i = 0 : N-1, and j = 0 : N-1.
        
        % Shared varibales
        dif_rc = r-c; % shared difference
        glcm = glcm(:); % shared 1-array glcm
        mean_r = meanIndex(r,glcm); % shared mean via r-direction. The local mean value of the kernel.
        
        % Each texture
        for it = 1: length(texturenames)
            % See the Eqs from https://www.l3harrisgeospatial.com/docs/backgroundtexturemetrics.html
            switch texturenames{it}
                case 'Mean'
                    textvalue = mean_r; % The local mean value of the kernel. -1 for be consistent with ENVI
                    
                case 'Variance'
                    textvalue = sum((r - mean_r).^2 .* glcm); % The local variance of the kernel.  to use shared mean for saving computing time
                    
                case 'Homogeneity'
                    textvalue = sum(glcm ./ (1 + (dif_rc).^2)); % Also see Matlab internal function graycoprops

                case 'Constract' 
                    textvalue = sum(glcm.* (dif_rc).^2); % Also see Matlab internal function graycoprops
                    
                case 'Dissimilarity'
                    textvalue = sum(abs(dif_rc).*glcm);
                    
                case 'Entropy'
                    textvalue = - sum(glcm.*log(glcm + eps)); % plus eps for avoiding to reach negative infinity (see Haralick et al, 1973)
                    
                case 'SecondMoment' % also named by Energy in Matlab
                    textvalue = sum(glcm.^2); % rang 0 to 1.0 
                    
                case 'Correlation'
                    % Function because of complexity
                    textvalue = calculateCorrelationMR(glcm,r,c, mean_r); % to use shared mean for saving computing time
            end
            glcmtextlayers(ir, ic, it) = textvalue;
        end
    end
    fprintf('Finished processing %.2f percentage row with %0.2f mins\n', ir/rlength*100, toc/60);
end

%% Valid range
% Homogeneity
% ENVI computes homogeneity using the "inverse difference moment" equation. Values range from 0 to 1.0.
idtext = find(ismember(texturenames, 'Homogeneity'));
if ~isempty(idtext)
    glcmtextlayer = glcmtextlayers(:,:,idtext);
    glcmtextlayer(glcmtextlayer<0) = 0;
    glcmtextlayer(glcmtextlayer>1) = 1;
    glcmtextlayers(:,:,idtext) = glcmtextlayer;
end

% Second Moment
% ENVI uses the "angular second moment" equation. Values range from 0 to 1.0.
idtext = find(ismember(texturenames, 'SecondMoment'));
if ~isempty(idtext)
    glcmtextlayer = glcmtextlayers(:,:,idtext);
    glcmtextlayer(glcmtextlayer<0) = 0;
    glcmtextlayer(glcmtextlayer>1) = 1;
    glcmtextlayers(:,:,idtext) = glcmtextlayer;
end


% Correlation
% Values range from -1.0 to 1.0.
idtext = find(ismember(texturenames, 'Correlation'));
if ~isempty(idtext)
    glcmtextlayer = glcmtextlayers(:,:,idtext);
    glcmtextlayer(glcmtextlayer<-1) = -1;
    glcmtextlayer(glcmtextlayer>1) = 1;
    % isnan when 0/0 in the bellow function -- calculateCorrelation.
    % and here we label it as 1 for consistent with ENVI
    glcmtextlayer(isnan(glcmtextlayer)) = 1; 
    glcmtextlayers(:,:,idtext) = glcmtextlayer;
end

end

%-----------------------------------------------------------------------------
% based on shared mean value to saving computing time
function Corr = calculateCorrelationMR(glcm,r,c, mr)
% References: Haralick RM, Shapiro LG. Computer and Robot Vision: Vol. 1,
% Addison-Wesley, 1992, p. 460.
%
% Bevk M, Kononenko I. A Statistical Approach to Texture Description of
% Medical Images: A Preliminary Study., The Nineteenth International
% Conference of Machine Learning, Sydney, 2002.
% http://www.cse.unsw.edu.au/~icml2002/workshops/MLCV02/MLCV02-Bevk.pdf,
% p.3.
%
% Anys, Hassan, and Dong-Chen He. "Evaluation of textural and
% multipolarization radar features for crop classification." IEEE
% Transactions on geoscience and remote sensing 33.5 (1995): 1170-1181.
  
% Correlation is defined as the covariance(r,c) / S(r)*S(c) where S is the
% standard deviation.

% Calculate the mean and standard deviation of a pixel value in the row
% direction direction. e.g., for glcm = [0 0;1 0] mr is 2 and Sr is 0.
% mr = meanIndex(r,glcm);
Sr = stdIndex(r,glcm,mr);
  
% mean and standard deviation of pixel value in the column direction, e.g.,
% for glcm = [0 0;1 0] mc is 1 and Sc is 0.
mc = meanIndex(c,glcm);
Sc = stdIndex(c,glcm,mc); 

Corr = sum((r - mr) .* (c - mc) .* glcm) / (Sr * Sc); % in matlab
% Corr = (sum((r+1) .* (c+1) .* glcm) - mr.*mc) / (Sr * Sc); % in ENVI

end

%-----------------------------------------------------------------------------
function S = stdIndex(index,glcm,m)
S = sqrt(sum((index - m).^2 .* glcm));
end

%-----------------------------------------------------------------------------
function M = meanIndex(index,glcm)
M = sum(index .* glcm);
end
