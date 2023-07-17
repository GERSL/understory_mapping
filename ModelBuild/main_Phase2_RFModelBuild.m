function main_Phase2_RFModelBuild(iCore, totalCores)
%This function is to build the Random forest model and conduct the
%classification; This function could run directly if dont change the
%parameters
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
end