function [y_input_sur, sampleCodes_sur] = mergeCategories(y_input,subcategory, surcategory,sampleCodes)
    if length(subcategory)~= length(surcategory)
        error('The dimension of the subcategory and surcategory is different \n');
    end
    y_input_sur = y_input;

    sampleCodes_sur = sampleCodes;
    for i = 1:length(subcategory)
        subCode = subcategory{i};
        surCode = surcategory(i);
        ids = ismember(y_input,subCode);
        y_input_sur(ids) = surCode;
    end
end