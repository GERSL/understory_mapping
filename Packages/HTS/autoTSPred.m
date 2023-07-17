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