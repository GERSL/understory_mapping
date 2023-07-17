function main_Phase1_calculateVariable(iCore, totalCores)
    %% This function shows the steps of the variable caculation; These functions could run directly
    % Although the functions could run in one time, it is highly
    % recommended to run step by step (especially for time-consuming texture calculation).
    if ~exist('iCore', 'var')
        iCore = 1;
    end
    if ~exist('totalCores', 'var')
        totalCores = 1;
    end
    
    %% First step is to build the harmonic time series model from the all Sentinel-2 images (500 cores suggest)
    autoComputeInputsS2TimeSeries(iCore, totalCores);
     
    %% Second step is to generate the synthetic images (16 cores suggest)
    batchGenerateCoefImages(iCore, totalCores); 
     
    %% third step is to calculate the texture information based on synthetic images
%     % first calculate the texture in four seperate directions (Slow: 240 cores suggest)
    batchComputeGLCMTextureSingleDir(iCore, totalCores); 

%     % then merge these texture information into the direction average
    batchComputeGLCMTexturesFromSingleDir(iCore, totalCores); 

    %% Forth step is to load the texture information into the variables
    addGLCMVariables(iCore, totalCores);
    
    %% Fifth step is "RENAME" the variable folder and remove the old version
%     To avoid the conflict when adding the texture information into the
%     original variable folder. We firstly generated a new folder to
%     reserve the results and then rename the folder name, and then remove
%     the old version
    replaceVariableFolder();

    %% The calculation of the input variables are completed. Then move to model building and classification
end