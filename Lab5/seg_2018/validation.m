%VALIDATION  Validate brain segmentation against an expert
%  This function validates your brain segmentation against that of the expert.
%

% Last Modified: 4/20/2016 Christopher L. Dean


TEST_SLICE = 130;


% Set path prefixes for the script
%---------------------------------
CLASSIFICATION_PREFIX = 'output/classification';
BRAIN_PREFIX = 'output/brain';
MRI_PREFIX = 'data/swrot/spgr/I';
LABELS_PREFIX = 'data/swrot/segtruth/I';


% Image specifications (do not modify)
%-------------------------------------
LABEL_WHITE = 8;
LABEL_GRAY = 4;
LABEL_CSF = 5;


% Read and display your result for the test slice
%------------------------------------------------
my_result_fn =  sprintf('%s.%0.3d', BRAIN_PREFIX, TEST_SLICE);
my_result = mri_read(my_result_fn);


% Read and display the expert's result for the test slice
%--------------------------------------------------------
gold_standard_fn = sprintf('%s.%0.3d', LABELS_PREFIX, TEST_SLICE);
gold_standard = mri_read(gold_standard_fn);


% Plot results
%-------------
figure; display_image(my_result,'My Result');
figure; display_image(gold_standard,'Expert Result');


% Generate the probability tables
%-------
% Expert Gray
 GG = size(intersect(find(gold_standard == LABEL_GRAY), find(my_result == LABEL_GRAY)),1);
 GW = size(intersect(find(gold_standard == LABEL_GRAY), find(my_result == LABEL_WHITE)),1);
 GC = size(intersect(find(gold_standard == LABEL_GRAY), find(my_result == LABEL_CSF)),1);

 % Expert White
 WG = size(intersect(find(gold_standard == LABEL_WHITE), find(my_result == LABEL_GRAY)),1);
 WW = size(intersect(find(gold_standard == LABEL_WHITE), find(my_result == LABEL_WHITE)),1);
 WC = size(intersect(find(gold_standard == LABEL_WHITE), find(my_result == LABEL_CSF)),1);

 % Expert CSF
 CG = size(intersect(find(gold_standard == LABEL_CSF), find(my_result == LABEL_GRAY)),1);
 CW = size(intersect(find(gold_standard == LABEL_CSF), find(my_result == LABEL_WHITE)),1);
 CC = size(intersect(find(gold_standard == LABEL_CSF), find(my_result == LABEL_CSF)),1);
 
 finalMat = [GG,WG,CG;
     GW,WW,CW;
     GC,WC,CC];

 

