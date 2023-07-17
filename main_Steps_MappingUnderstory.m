%% This page demonstrates the examples of running the Matlab functions to map understory in Connecticut

% If any questions, please feel free to contact Xiucheng Yang (xiucheng.yang@uconn.edu).

%% Phase 0. Preparation of whole available Sentinel-2 data in target years
% Download S2 --> unzip --> sen2cor atmosphere correction --> Fmask cloud detection


%% ******** Phase 1. Extract temporal and texture variables from Sentinel-2 data ************
% Prepare the variables derived from harmonic time series fitting and GLCM texture calculation
% See Folder <CalculateVariables>
    main_calculateVariable.m % For detailed workflow
    %% Phase 1-1  First step is to build the harmonic time series model from the all Sentinel-2 images (500 cores suggest)
    autoComputeInputsS2TimeSeries(iCore, totalCores);
     
    %% Phase 1-2 Second step is to generate the synthetic images (16 cores suggest)
    batchGenerateCoefImages(iCore, totalCores); 
     
    %% Phase 1-3,4 Third step is to calculate the texture information based on synthetic images
    % The seperate processing is to save the memory
    % first calculate the texture in four seperate directions (Slow: 240 cores suggest)
    batchComputeGLCMTextureSingleDir(iCore, totalCores); 
    % then merge these texture information into the direction average
    batchComputeGLCMTexturesFromSingleDir(iCore, totalCores); 
    
    %% Phase 1-5 Forth step is to load the texture information into the variables
    addGLCMVariables(iCore, totalCores);
    
    %% Phase 1-Supplementary Last step is "RENAME" the variable folder and remove the old version
    %  To avoid the conflict when adding the texture information into the
    %     original variable folder. We firstly generated a new folder to
    %     reserve the results and then rename the folder name, and then remove
    %     the old version
    replaceVariableFolder();


%% ******* Phase 2. Build the Random forest classifier for understory mapping ******
% See Folder <ModelBuild> to build the model from the variables
    %% Preparing Step: Read the whole variables of the training samples and saved in MAT format
    readSamplesS2Variables(); 
    % See the results as --> "understorySampleVariables.mat"    
    %% Phase 2-1 : Build the Random Forest model based on the default optimal variables (If transferred to other applications, Test the parameters)
    BuildRFModelWithIterativeSelectRepresentativeSample();
    % See the built RF model: --> "modelRF_understorySpecies_v264_n8000_i10.mat"
    
    %% Phase 2-2: Classify the rows based on the RF Model
    batchClassifyCT(iCore, totalCores);
    
    %% Phase 2-3: Export the maps
    batchExportMapCT(iCore, totalCores)


%% HPC folder provide the slurm files in UConn HPC
% see folder <HPC>

