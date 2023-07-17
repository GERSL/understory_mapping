function modelRF = createClassifierFromIterativeSelectRepresentativeSample(fileID,y_input,understorySamples,numSamples,sampleCodes,variable,selectedVariables,numSamplesTotal,typesUniq,iterTimesDisagree,dir_out,understoryRFModelName,importanceIdx)
    extra_options.importance = 1;

    ids_all_used = []; % used sample IDs
    ids_disagree = []; % disagree samole IDs
    record_acc_prop = zeros(iterTimesDisagree, 2);
    fprintf(fileID,'\n RepSamples & iterations: OA - minAcc \r\n');
    super_y_input = mergeCategories(y_input,{[5 6 7 8 9]},[12],[]); % Merge different kinds of background into one super class
    super_classes = unique(super_y_input);
    for i_select = 1: iterTimesDisagree
        samp_remain_prop = 0.95; % half for remain and half for new
        %% randomly select training samples according to the array of 'numSamples'
        ids_all =[];

        for i_type = 1: length(typesUniq)
            typeCode = typesUniq(i_type);
            if isempty(ids_all_used) % first time to select training samples, when we do not consider 'samp_remain_prop'
                idsType = find(y_input== typeCode);
                idsTmp = randperm(length(idsType), min(numSamples(i_type),length(idsType)));
                ids_all = [ids_all; idsType(idsTmp)];
            else % to consider 'samp_remain_prop'
                num_remain = round(numSamples(i_type)*samp_remain_prop);
                num_new = numSamples(i_type)-num_remain;

                % exclude disagree IDs already in the last time sample pool
                in_usedsamp = ismember(ids_disagree, ids_all_used);
                ids_disagree(in_usedsamp) = [];
                % select new samples at disagreement sample pool
                ids_disagree_type = find(y_input(ids_disagree) == typeCode);

                % when disagreement samples are less than the 10%
                num_new = min(length(ids_disagree_type), num_new); 
                num_remain = numSamples(i_type)-num_new;

                ids_disagree_type_tmp = randperm(length(ids_disagree_type), num_new);
                ids_disagree_type = ids_disagree(ids_disagree_type(ids_disagree_type_tmp));  % back to used IDs to new

                ids_remain_Type = find(y_input(ids_all_used) == typeCode); % thisfor used IDs at the last time
                ids_remain_Type_tmp = randperm(length(ids_remain_Type), min(num_remain,length(ids_remain_Type)));
                ids_remain_Type = ids_all_used(ids_remain_Type(ids_remain_Type_tmp)); % back to used IDs to remain

                ids_all = [ids_all; ids_remain_Type; ids_disagree_type];
            end
        end
        ids_all_used = ids_all;
        recordSamplesAllSelected = understorySamples(ids_all);

        [x_input_train,~,~] = getClassificationInputsSelectVariables(recordSamplesAllSelected,variable);
        if ~isempty(importanceIdx)
        % filter the variables according to importance
             x_input_train = x_input_train(:,importanceIdx);
        end
        y_input_train = [recordSamplesAllSelected.Type]';

        % merge the sub category into super classes
        y_input_train = mergeCategories(y_input_train,{[5 6 7 8 9]},[12],[]);

        modelRF = classRF_train(x_input_train, y_input_train, 500, 500, extra_options);
        
        [x_input_test,~,~] = getClassificationInputsSelectVariables(understorySamples,variable);
        
        if ~isempty(importanceIdx)
        % filter the variables according to importance
             x_input_test = x_input_test(:,importanceIdx);
        end
        
        [y_input_test] = classRF_predict(x_input_test,modelRF); % class
        % merge the sub category into super classes
        y_input_test = mergeCategories(y_input_test,{[5 6 7 8 9]},[12],[]);
        % the disagreement IDs at the super level of four target understory
        % and combined background 
        ids_disagree = find(y_input_test~=super_y_input);
        %% overall accuracy estimate based on all samples
        orig_label = cell(size(super_y_input));
        pred_label = cell(size(y_input_test));
        for icode = 1: length(super_classes)
            code = super_classes(icode);
            names = char(sampleCodes(:,2));
            name = names(find([sampleCodes{:,1}]==code),:);
            orig_label(super_y_input==code)={name};
            pred_label(y_input_test==code)={name};
        end

        [OA,minAcc, ~,~,~,~,~] = accuracyCalculate(pred_label,orig_label);
        record_acc_prop(i_select,:) = [OA,minAcc];
        fprintf(fileID,' %0.3f - %0.3f\r\n', OA,minAcc);
        fprintf('iterationTimes - %d: %0.3f - %0.3f\r\n', i_select-1,OA,minAcc);
        if i_select ==1 || i_select == iterTimesDisagree
            [C,order] = confusionmat(orig_label,pred_label);
            figure1 = figure('visible','off','Position', [10 10 1000 500]);
            cm = confusionchart(C,order,'RowSummary','row-normalized','ColumnSummary','column-normalized');
            if isempty(importanceIdx)
                saveas(figure1,fullfile(dir_out,[understoryRFModelName,'_v',num2str(length(selectedVariables)),'_n',num2str(numSamplesTotal),'_i',num2str(i_select-1),'.jpg']));
            else
                saveas(figure1,fullfile(dir_out,[understoryRFModelName,'_v',num2str(length(importanceIdx)),'_n',num2str(numSamplesTotal),'_i',num2str(i_select-1),'.jpg']));
            end
%              save(fullfile(dir_out,['modelRF_variables_',num2str(length(selectedVariables)),'_',num2str(i_select-1)]),'modelRF','-v7.3');
        end
    end % end of training data.
    if isempty(importanceIdx)
        save(fullfile(dir_out,[understoryRFModelName,'_v',num2str(length(selectedVariables)),'_n',num2str(numSamplesTotal),'_i',num2str(iterTimesDisagree-1)]),'modelRF','-v7.3');
    else
        save(fullfile(dir_out,[understoryRFModelName,'_v',num2str(length(importanceIdx)),'_n',num2str(numSamplesTotal),'_i',num2str(iterTimesDisagree-1)]),'modelRF','-v7.3');
    end
    %% plot the accuracy change during the iterative selection
    x_plot = 1: size(record_acc_prop, 1);
    
    OA = record_acc_prop(x_plot,1);
    minACC = record_acc_prop(x_plot,2);

    fig_out = figure('visible','off','Position', [10 10 1000 500]);
    defaultFontSize = 16;
%     tiledlayout(1, 2, 'TileSpacing','tight', 'Padding', 'compact') ;
    set(gcf,'color','w');  
    
%     nexttile; % overal accracy
    plot_OA = plot(x_plot,OA,'LineStyle','-','Color','k','LineWidth',2);
    set(plot_OA,{'DisplayName'},{'Overall accuracy'});
   
    plotMin = plot(x_plot,minACC,'LineStyle','--','Color','k','LineWidth',2);
    set(plotMin,{'DisplayName'},{'Minimum accuracy'});
    xticks([1, 2, 6 : 5: iterTimesDisagree]);
    xticklabels({0, 1, 5 : 5: iterTimesDisagree-1});
    xlim([1, iterTimesDisagree]);
    xlabel('Iteration Times');
    ylabel('Accuracy'); % for left y axis
    legend('Location', 'best');
    hold on;
    set(gca,'DefaultTextFontSize',defaultFontSize);
    if ~isempty(importanceIdx)
        saveas(fig_out,fullfile(dir_out,[understoryRFModelName,'_v',num2str(length(selectedVariables)),'_n',num2str(numSamplesTotal),'_i',num2str(iterTimesDisagree-1),'_AccuracyIterative.jpg']));
    else
        saveas(fig_out,fullfile(dir_out,[understoryRFModelName,'_v',num2str(length(importanceIdx)),'_n',num2str(numSamplesTotal),'_i',num2str(iterTimesDisagree-1),'_AccuracyIterative.jpg']));
    end
end