%MRI_CLASSIFY  Perform statistical image classification (requires updates)
%  While this script is mostly complete, you are responsible for modifying the
%  contents of this function to make it fully operational. Be sure to create an
%  "output/classification" directory within your personal directory and modify
%  CLASSIFICATION_PREFIX to point to this directory.

% Last Modified: 5/17/2016 Christopher L. Dean

close all
clear all
% Set path prefixes for the script
%------------------------------------------------
CLASSIFICATION_PREFIX = 'output/classification';
MRI_PREFIX = 'data/swrot/spgr/I';
LABELS_PREFIX = 'data/swrot/segtruth/I';


% Training and test image specifications (do not modify)
%-------------------------------------------------------
TRAINING_SLICES = 120:2:150;
TEST_SLICES = 102:190;
SLICE_NUM = 120;

% Create output directory if it does not exist
if ~exist('output','dir')
    [success, message] = mkdir('output');
    if ~success
        error('Could not create directory "output".  Recieved message "%s"',message);
    end
end


%---------------------------------------------------
% Read and display an MRI slice and its segmentation
%---------------------------------------------------
mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, SLICE_NUM); % create filename
img = mri_read(mri_fn);  % img is the raw MRI image
labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, SLICE_NUM);
labels = mri_read(labels_fn);  % labels is the image with labeled segments

% Display img & labels using grayscale colormap
%...  INSERT YOUR CODE HERE.


%------------------------------------------------------------------
% Next we compile the segmented intensity data for all MRI training
% slices and build some class-conditional probability models.
%------------------------------------------------------------------
LABEL_WHITE = 8; % pixel label/value corresponding to white matter
LABEL_GRAY = 4;  % pixel label/value corresponding to grey matter
LABEL_CSF = 5;   % pixel label/value corresponding to cerebrospinal fluid
NUM_LABELS = 3;  % number of labels


% The following loops over the training slices and collects
% the intensity values that correspond to each tissue class
%----------------------------------------------------------
intensity_white = []; % compiles all white matter intensity data
intensity_gray  = []; % compiles all gray matter intensity data
intensity_csf   = []; % compiles all csf intensity data
for i = TRAINING_SLICES
    %% read mri image & corresponding labelled img
    mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i);
    img = mri_read(mri_fn);
    labels_fn = sprintf('%s.%0.3d', LABELS_PREFIX, i);
    labels = mri_read(labels_fn);

    %% concatenate the observed intensity values in this slice
    intensity_white = [intensity_white; img(find(labels == LABEL_WHITE))];
    intensity_gray  = [intensity_gray;  img(find(labels == LABEL_GRAY))];
    intensity_csf   = [intensity_csf;   img(find(labels == LABEL_CSF))];
end;

%---------------------
% Histogram PDF Models
%---------------------

% Here is an example of how to display a histogram
% of the intensities observed as white matter
%-------------------------------------------------
% figure; hist(intensity_white,100); title('White Matter: Intensity Histogram');
% size(intensity_white)
% figure; hist(intensity_gray,100); title('Gray Matter: Intensity Histogram');
% size(intensity_gray)
% figure; hist(intensity_csf,100); title('CSF Matter: Intensity Histogram');
% size(intensity_csf)



% Construct Histogramming-Based PDFs (call your version of HistPDF)
%------------------------------------------------------------------
% ... INSERT YOUR CODE HERE.
num_bins = 150;
[pdfWhite,xWhite] = HistPDF(intensity_white, num_bins);
figure;
stairs(xWhite,pdfWhite)
hold on
[pdfGray,xGray] = HistPDF(intensity_gray, num_bins);
stairs(xGray,pdfGray)

[pdfCsf,xCsf] = HistPDF(intensity_csf, num_bins);
stairs(xCsf,pdfCsf)
xlabel('Intensity')
ylabel('Frequency of Occurence')
title('PDFs of Intensity by Tissue type')

saveas(gcf,'PDFTissueTypes','png')
%--------------------
% Gaussian PDF Models
%--------------------

% Fit Gaussian distributions to white, gray, and csf intensity data
% %------------------------------------------------------------------
tissue_means = [mean(intensity_white),mean(intensity_gray),mean(intensity_csf)];
%     % its three elements are white, gray, csf means
tissue_vars =  [var(intensity_white),var(intensity_gray),var(intensity_csf)];
    % its three elements are white, gray, csf variances

% Define the Gaussian probability density function
%-------------------------------------------------
gauss = @(x, m, s) (1/(sqrt(2*pi)*s))*exp(-(x-m).*(x-m)/(2*s*s));

% Construct Gaussian PDFs
%------------------------
% ... INSERT YOUR CODE HERE.
gaussianWhite =  gauss([0:150], tissue_means(1), sqrt(tissue_vars(1)));
gaussianGrey =  gauss([0:150], tissue_means(2), sqrt(tissue_vars(2)));
gaussianCsf =  gauss([0:150], tissue_means(3), sqrt(tissue_vars(3)));

hold on


% Plot the Gaussian PDFs, along with their histogram-based counterparts
%----------------------------------------------------------------------
% ... INSERT YOUR CODE HERE.
hold on
plot(gaussianWhite)
plot(gaussianGrey)
plot(gaussianCsf)
legend('White Matter','Gray Matter','CSF','Gaussian Approximation White Matter','Gaussian Approximation Grey Matter','Gaussian Approximation CSF')

%------------------------------------------
% Perform Maximum Likelihood Classification
%------------------------------------------
h1 = figure; set(h1, 'nextplot', 'replace');
h2 = figure;
h3 = figure;  % for tissue likelihoods
for i = TEST_SLICES
    %% read mri image
    mri_fn = sprintf('%s.%0.3d', MRI_PREFIX, i)
    img = mri_read(mri_fn);
    w = zeros(length(img(:)),NUM_LABELS);
    for k = 1:NUM_LABELS
        w(:,k) = gauss(img(:), tissue_means(k), sqrt(tissue_vars(k)));
    end;

    % Display the tissue likelihoods for the pixels in the slice
    % Change 1 to zero to suppress display of tissue likelihoods
    if 1
        figure(h3);
        imagesc([reshape(w(:,1), size(img)); ...
            reshape(w(:,2), size(img)); ...
            reshape(w(:,3), size(img))]);
        colormap(gray)
        title('Tissue Likelihoods');
    elseif ~isempty(h3)
        close(h3)
        h3 = [];
    end;

    % Classify Image Pixels
    classification = zeros(size(img));
    
    % put your ML classification code here
    % For each voxel find the maximum likelihood and its corresponding
    % Gaussian. Then and assign label values of the corresponding Gaussian
    % to that voxel.
    % ...

    % Display the image and classification
    [fpath,fname,ext] = fileparts(mri_fn);
    name = [fname,ext];
    figure(h1); display_image(img,['MRI Image: ',name]);
    figure(h2); display_image(classification,['Classified: ',name,...
        sprintf(' (%d=White, %d=Gray, %d=CSF)',LABEL_WHITE,LABEL_GRAY,LABEL_CSF)]);

    % Write the classification for use downstream
    out_fn = sprintf('%s.%0.3d', CLASSIFICATION_PREFIX, i);
    mri_write(classification, out_fn);
    fprintf(1,['Classification file %s has been written. ',...
        'Hit any key to continue.\n'],name);
    pause;
end;
