function  [x_all,selectedVariables,labels] = getClassificationInputsSelectVariables(record_samples,variables,nameStr,termNum)
%GETCLASSIFICATIONMODELINPUTS Gegerate input array for classification model
    if ~exist('nameStr', 'var')
        nameStr = '';
    end
    if ~exist('termNum', 'var')
        termNum = 8;
    end
    doys = globalsets.leafOffDay; % DOYS calculated
    numBands = 10;
    numIds = 5;
    numCoefs = 2*termNum+1;
    x_all = [];
    labels = [];
    % field name from the different years
    optiCoeffVar = ['OptiCoeff',nameStr];
    optiRMSEVar = ['OptiRMSE',nameStr];
    idsCoeffVar = ['IdsCoeff',nameStr];
    idsRMSEVar = ['IdsRMSE',nameStr];
    %% choose the S2 bands
    inOptiBands = variables.bands;
    inOptiCoeffs = ones(1,numCoefs); 
    inOptiCoeffsAll = inOptiBands.*inOptiCoeffs(1:2*termNum+1)';
    inOptiCoeffsAll = inOptiCoeffsAll(:)';
    inOptiRMSE = 1;
    inOptiRMSE = inOptiRMSE.*inOptiBands;
    inPuts = [inOptiCoeffsAll,inOptiRMSE];
    labels = [labels,inPuts]; %coefficients of S2 bands and RMSE

    num_model_coeffs = numCoefs*numBands;
    x_OptiCoeffs = [record_samples.(optiCoeffVar)];
    x_OptiCoeffs = x_OptiCoeffs(:);
    x_OptiCoeffs = reshape(x_OptiCoeffs,[num_model_coeffs, size(x_OptiCoeffs,1)/num_model_coeffs]);
    x_OptiCoeffs = x_OptiCoeffs';
    x_OptiCoeffs_temp = [];
    for i = 1:numBands
        x_OptiCoeffs_temp = [x_OptiCoeffs_temp,x_OptiCoeffs(:,(i-1)*numCoefs+1:(i-1)*numCoefs+termNum*2+1)];
    end
    x_OptiCoeffs = x_OptiCoeffs_temp;
    % RMSE for optical data
    x_OptiRMSE = [record_samples.(optiRMSEVar)];
    x_OptiRMSE = reshape(x_OptiRMSE,[numBands, size(x_OptiRMSE,2)/numBands]);
    x_OptiRMSE = x_OptiRMSE';
    S2_all = [x_OptiCoeffs, x_OptiRMSE];
    
    S2_all(:,inPuts==0) = [];
    S2_all = double(S2_all);
    x_all = [x_all,S2_all];
  
    inIdsBands = variables.ids;
    inIdsCoeffsAll = inIdsBands.*inOptiCoeffs(1:2*termNum+1)';
    inIdsCoeffsAll = inIdsCoeffsAll(:)';
    inIdsRMSE = 1;
    inIdsRMSE = inIdsRMSE.*inIdsBands;
    inIdsPuts = [inIdsCoeffsAll,inIdsRMSE];
    labels = [labels,inIdsPuts]; %coefficients of S2 bands and RMSE; coefficients of Ids bands and RMSE;
    num_model_coeffs = numCoefs*numIds;
    x_IdsCoeffs = [record_samples.(idsCoeffVar)];
    x_IdsCoeffs = x_IdsCoeffs(:);
    x_IdsCoeffs = reshape(x_IdsCoeffs,[num_model_coeffs, size(x_IdsCoeffs,1)/num_model_coeffs]);
    x_IdsCoeffs = x_IdsCoeffs';
    
    x_IdsCoeffs_temp = [];
    for i = 1:numIds
        x_IdsCoeffs_temp = [x_IdsCoeffs_temp,x_IdsCoeffs(:,(i-1)*numCoefs+1:(i-1)*numCoefs+termNum*2+1)];
    end
    x_IdsCoeffs = x_IdsCoeffs_temp;
    
    % RMSE for optical data
    x_IdsRMSE = [record_samples.(idsRMSEVar)];
    x_IdsRMSE = reshape(x_IdsRMSE,[numIds, size(x_IdsRMSE,2)/numIds]);
    x_IdsRMSE = x_IdsRMSE';
    ids_all = [x_IdsCoeffs, x_IdsRMSE];
    ids_all(:,inIdsPuts==0) = [];
    ids_all = double(ids_all);
    x_all = [x_all,ids_all];
    
%     if mean(x_all(:,1)<1)
%         x_all = x_all*10000;
%     end
%     i_date = str2double(vertcat(variables{:}));
    i_date = variables.TXDoy; % doy of the texture: 60 80 100 120 140
    [~,ids] = ismember(i_date,doys);
    inTXBands = variables.TXbands; %without Narrowbands
    inTXCoeffs = variables.TXmetric;

    inTXCoeffsAll = inTXBands.*inTXCoeffs';
    inTXCoeffsAll = inTXCoeffsAll(:)';
    dimTX = size(inTXCoeffsAll,2);
    labelTX = zeros(1,dimTX*length(doys));
    if ids>0
        TXSyns = [record_samples.SyntheticTX];
        TX_all = [];
        for iDoy = ids %interested doy for texture calculation
            TX = TXSyns(:,:,iDoy);
            TX = TX(:);
            TX = reshape(TX,[8*15,size(TX,1)/8/15]);
            TX = (TX)';
            TX(:,inTXCoeffsAll==0)=[];
            labelTX(((iDoy-1)*dimTX+1):iDoy*dimTX) = inTXCoeffsAll;
            TX_all = [TX_all,double(TX)];
           
        end
        x_all = [x_all,TX_all];
    end
    
    x_all(find(isnan(x_all))) = 0;
    
    labels = [labels, labelTX];
    strBands = {'blue','green','red','NIR','SWIR1','SWIR2','RE1','RE2','RE3','NNIR','EVI','NDVI','SAVI','NBR','NBNDVI'};
    strSR = {'blue','green','red','NIR','SWIR1','SWIR2','RE1','RE2','RE3','NNIR'};
    coefs = {'-a0','-a1','-b1','-a2','-b2','-a3','-b3','-a4','-b4','-a5','-b5','-a6','-b6','-a7','-b7','-a8','-b8'};
    strIds = {'EVI','NDVI','SAVI','NBR','NBNDVI'};
    txs = {'-m', '-var', '-hom', '-cts', '-dis', '-ent', '-sec', '-cor'};
    txDoys = {'-80','-100','-120','-140'};
    
    for i_band = 1:length(strSR)
        if ~exist('varSRTS', 'var')
            varSRTS = strcat(strSR(i_band),coefs);
        else
            i_varSRTS = strcat(strSR(i_band),coefs);
            varSRTS = {varSRTS;i_varSRTS};
            varSRTS = vertcat(varSRTS{:});
        end
    end
    varSRTS = varSRTS';
    varSRTS = varSRTS(:);
    rmseSR = strcat(strSR,'-rmse');
    
    for i_band = 1:length(strIds)
        if ~exist('varIdsTS', 'var')
            varIdsTS = strcat(strIds(i_band),coefs);
        else
            i_varIdsTS = strcat(strIds(i_band),coefs);
            varIdsTS = {varIdsTS;i_varIdsTS};
            varIdsTS = vertcat(varIdsTS{:});
        end
    end
    varIdsTS = varIdsTS';
    varIdsTS = varIdsTS(:);
    rmseIds = strcat(strIds,'-rmse');
    
    for i_doy = 1:length(txDoys)
        for i_band = 1:length(strBands)
            if ~exist('varTX', 'var')
                varTX = strcat(strBands(i_band),strcat(txDoys(i_doy),txs));
            else
                i_varTX = strcat(strBands(i_band),strcat(txDoys(i_doy),txs));
                varTX = {varTX;i_varTX};
                varTX = vertcat(varTX{:});
            end
        end
    end
    varTX = varTX';
    varTX = varTX(:);
    
    variableID = [varSRTS;rmseSR';varIdsTS;rmseIds';varTX];
    
    selectedVariables = variableID(labels==1);
end