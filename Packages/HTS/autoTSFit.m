function [fit_cft,rmse,v_dif]=autoTSFit(x,y,df)
% Revisions: 
% v1.0 Using lasso for timeseries modeling (01/27/2013)
% Auto Trends and Seasonal Fit between breaks
% INPUTS:
% x - Julian day [1; 2; 3];
% y - predicted reflectances [0.1; 0.2; 0.3];
% df - degree of freedom (num_c)
%
% OUTPUTS:
% fit_cft - fitted coefficients;
% General model TSModel:
% f1(x) = a0 + b0*x (df = 2)
% f2(x) = f1(x) + a1*cos(x*w) + b1*sin(x*w) (df = 4)
% f3(x) = f2(x) + a2*cos(x*2w) + b2*sin(x*2w) (df = 6)
% f4(x) = f3(x) + a3*cos(x*3w) + b3*sin(x*3w) (df = 8)

n=length(x); % number of clear pixels
% num_yrs = 365.25; % number of days per year
w=2*pi/365.25; % num_yrs; % anual cycle
% fit coefs
fit_cft = zeros(df,1);

% global lamda_lasso

%% LASSO Fit
% build X
X = zeros(n,df-1);
X(:,1) = 0; % we do not need the slope

if df >= 4
    X(:,2)=cos(w*x);
    X(:,3)=sin(w*x);
end

if df >= 6
    X(:,4)=cos(2*w*x);
    X(:,5)=sin(2*w*x);
end

if df >= 8
    X(:,6)=cos(3*w*x);
    X(:,7)=sin(3*w*x);
end

if df >= 10
    X(:,8)=cos(4*w*x);
    X(:,9)=sin(4*w*x);
end
if df >= 12
    X(:,10)=cos(5*w*x);
    X(:,11)=sin(5*w*x);
end
if df >= 14
    X(:,12)=cos(6*w*x);
    X(:,13)=sin(6*w*x);
end
if df >= 16
    X(:,14)=cos(7*w*x);
    X(:,15)=sin(7*w*x);
end
if df >= 18
    X(:,16)=cos(8*w*x);
    X(:,17)=sin(8*w*x);
end
% lasso fit with lambda = 20
fit = glmnet_fast(X,y,glmnetSetL(20));  

% curr_cft=[fit.a0;fit.beta];
fit_cft(1:df) = [fit.a0;fit.beta]; % curr_cft;

% %% OLS Fit
% 
% % build X
% X = zeros(n,df);
% X(:,1) = ones(n,1);
% X(:,2) = x;
% 
% if df >= 4
%     X(:,3)=cos(w*x);
%     X(:,4)=sin(w*x);
% end
% 
% if df >= 6
%     X(:,5)=cos(2*w*x);
%     X(:,6)=sin(2*w*x);
% end
% 
% if df >= 8
%     X(:,7)=cos(3*w*x);
%     X(:,8)=sin(3*w*x);
% end 
% 
% % curr_cft=[fit.a0;fit.beta];
% fit_cft(1:df) = X\y; % curr_cft;

yhat=autoTSPred(x,fit_cft);
% rmse=median(abs(y-yhat));
v_dif = y-yhat;
rmse=norm(v_dif)/sqrt(n-df);
% f(x) = a0 + b0*x + a1*cos(x*w) + b1*sin(x*w) (df = 4)
end
function outfity=autoTSPred(outfitx,fit_cft)
% Auto Trends and Seasonal Predict
% INPUTS:
% outfitx - Julian day [1; 2; 3];
% fit_cft - fitted coefficients;
% OUTPUTS:
% outfity - predicted reflectances [0.1; 0.2; 0.3];
% General model TSModel:
% f(x) =  a0 + b0*x + a1*cos(x*w) + b1*sin(x*w) 

% num_yrs = 365.25; % number of days per year
% w=2*pi/num_yrs; % anual cycle 
w = 2*pi/365.25;

outfity=[ones(size(outfitx)),outfitx,...% overall ref + trending
        cos(w*outfitx),sin(w*outfitx),...% add seasonality
        cos(2*w*outfitx),sin(2*w*outfitx),...% add bimodal seasonality
        cos(3*w*outfitx),sin(3*w*outfitx),... % add trimodal seasonality
        cos(4*w*outfitx),sin(4*w*outfitx),... % add forth term
        cos(5*w*outfitx),sin(5*w*outfitx),... % add fifth term
        cos(6*w*outfitx),sin(6*w*outfitx),... % add sixth term
        cos(7*w*outfitx),sin(7*w*outfitx),... % add forth term
        cos(8*w*outfitx),sin(8*w*outfitx),... % add fifth term
        ]*fit_cft;
end