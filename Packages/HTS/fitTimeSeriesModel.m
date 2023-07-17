function [fit_cft,rmse,rec_v_dif, num_c] = fitTimeSeriesModel(x_date, y_ref,num_c)
    
    % initial model fit
%      num_c = 8;
     x_date = double(x_date);
     y_ref = double(y_ref);
     % previous year and last year to maintain the 1st and last connective.
     x_date = [x_date; x_date+365.25;x_date+2*365.25];
     y_ref = [y_ref;y_ref;y_ref];
     if mean(y_ref(:,1))<1
        y_ref = y_ref.*10000;
     end
     [fit_cft,rmse,rec_v_dif] = autoTSFit(x_date,y_ref,num_c);
     
     % remove the trend coefficient which is not used in this study
     fit_cft(2) = [];

end