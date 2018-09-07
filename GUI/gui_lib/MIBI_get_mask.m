function mask = MIBI_get_mask(rawMaskData,cap,t,gausRad,plot,titletext)
% NOTE: to get original behavior, simply call
% MibiGetMask(rawMaskDAta,cap,t,gausRad,1,'');

% function mask = MibiGetMask(rawMaskData)
% function gets a 2d matrix of raw MIBI data to use for generating a mask
% and returns a mask of the positive regions
% cap is the capping intensity for the image. Equals 10 by default.
% t is the a value to threshold the image. Equals 0.07 by default.


% cap raw data
if ~exist('cap')
    cap = 10;
end
if ~exist('t')
    t = 0.07;
end
if ~exist('gausRad')
    gausRad = 3;
end

rawMaskDataCap = rawMaskData;
rawMaskDataCap(rawMaskDataCap>cap) = cap;

% smooth channel by gaussian, scale from 0 to 1 and threshold at 0.05
rawMaskDataG = imgaussfilt(rawMaskDataCap,gausRad);
bw = mat2gray(rawMaskDataG);
% figure;
% imshow(bw);
level = graythresh(bw);
if plot
    figure();
    hold on;
    histogram(bw);
    title(wrap_text(titletext, 100, [' ', filesep]))
    plotbrowser off;
    yl= ylim(); 
    line([level level],[0,yl(end)],'Color','red','LineStyle','--')
end
mask = imbinarize(bw,t);
if plot
    figure();
    imagesc(mask);
    title(titletext)
    plotbrowser on;
end