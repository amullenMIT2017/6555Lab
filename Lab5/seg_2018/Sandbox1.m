% Andrew Mullen
% 5/4/2018
close all
clear all
fname = 'data/sw/spgr/I.082';
A = mri_read(fname);

display_image(A,'I.082')
saveas(gcf,'Question1/original','png')
AthreshLow = A;
AthreshHigh = A;
% Segment based on a threshold
threshold = 67;


AthreshLow(AthreshLow<threshold) = 0;
AthreshHigh(AthreshHigh>threshold) = 0;
figure;
display_image(AthreshLow,'Thresholded I.082 - White Matter')
saveas(gcf,'Question1/thresholdedWhite','png')
figure;
display_image(AthreshHigh,'Thresholded I.082 - Gray Matter')


% Create a Gaussian filter to eliminate some noise from the images
% Arbitratily defined sigma value
sigma = 1.2;
filteredImage = imgaussfilt(A,sigma);
figure
display_image(filteredImage, 'Guassian Filter I.082')
saveas(gcf,'Question1/gaussianFilt','png')


filtThreshLow = filteredImage;
filtThreshHigh = filteredImage;


filtThreshLow(filtThreshLow<threshold) = 0;
filtThreshHigh(filtThreshHigh>threshold) = 0;
figure;
display_image(filtThreshLow,'Thresholded I.082 - Gaussian Filtered White Matter')
saveas(gcf,'Question1/gaussianFiltWhite','png')
figure;
display_image(filtThreshHigh,'Thresholded I.082 - Gaussian Filtered Gray Matter')



% Median Filtering approach
m = 4;
n = 4;
medianFiltImage = medfilt2(A,[m,n]);
figure;
display_image(medianFiltImage,'Median Filtered Image I.082')
saveas(gcf,'Question1/medianFilt','png')


medThreshLow = medianFiltImage;
medThreshHigh = medianFiltImage;

medThreshLow(medThreshLow<threshold) = 0;
medThreshHigh(medThreshHigh>threshold) = 0;
figure;
display_image(medThreshLow,'Thresholded I.082 - Median Filtered White Matter')
saveas(gcf,'Question1/medianFiltWhite','png')
figure;
display_image(medThreshHigh,'Thresholded I.082 - Median Filtered Gray Matter')

% Only present the White matter of the images
