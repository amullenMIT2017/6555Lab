function [alarm,t] = va_detect(ecg_data,Fs)%,transitionTime)
%VA_DETECT  ventricular arrhythmia detection skeleton function
%  [ALARM,T] = VA_DETECT(ECG_DATA,FS) is a skeleton function for ventricular
%  arrhythmia detection, designed to help you get started in implementing your
%  arrhythmia detector.
%
%  This code automatically sets up fixed length data frames, stepping through 
%  the entire ECG waveform with 50% overlap of consecutive frames. You can customize 
%  the frame length  by adjusting the internal 'frame_sec' variable and the overlap by
%  adjusting the 'overlap' variable.
%
%  ECG_DATA is a vector containing the ecg signal, and FS is the sampling rate
%  of ECG_DATA in Hz. The output ALARM is a vector of ones and zeros
%  corresponding to the time frames for which the alarm is active (1) 
%  and inactive (0). T is a vector the same length as ALARM which contains the 
%  time markers which correspond to the end of each analyzed time segment. If Fs 
%  is not entered, the default value of 250 Hz is used. 
%
%  Template Last Modified: 3/4/06 by Eric Weiss, 1/25/07 by Julie Greenberg

% Added another variable to va_detect which is the transitionTime in the
% sample ecg_data where the 

%  Processing frames: adjust frame length & overlap here
%------------------------------------------------------
frame_sec = 10; % sec
overlap = 0.5;  % 50% overlap between consecutive frames


% Input argument checking
%------------------------
if nargin < 2
    Fs = 250;   % default sample rate
end;
if nargin < 1
    error('You must enter an ECG data vector.');
end;
ecg_data = ecg_data(:);  % Make sure that ecg_data is a column vector
 

% Initialize Variables
%---------------------
frame_length = round(frame_sec*Fs);  % length of each data frame (samples)
frame_step = round(frame_length*(1-overlap));  % amount to advance for next data frame
ecg_length = length(ecg_data);  % length of input vector
frame_N = floor((ecg_length-(frame_length-frame_step))/frame_step); % total number of frames
alarm = zeros(frame_N,1);	% initialize output signal to all zeros
t = ([0:frame_N-1]*frame_step+frame_length)/Fs;

% Generate filter for the data
% This is the same filter that was used in part 1 of the lab.
HPF = 29.38/125;
LPF = 5.615/125;

B = fir1(400,[LPF,HPF],'bandpass');

filteredData = filter(B,1,ecg_data);   

% "Adaptive threshold" Take average of max(abs(correlation))
% Our goal is to make an adaptive threshold and adaptive matched filter
% In order to do this, we make an assumption that the first 5 segements of
% data are a patient's "healthy" baseline levels
% Prior to making a patient specific matched filter, the detection
% algorithm did a poor job of identifying differences.
valsToAve = zeros(121,5);
for j = 1:5
    seg = filteredData(((j-1)*frame_step+1):((j-1)*frame_step+frame_length));
    
    % Generate the data describing the peaks in the signal
    % Use the prexisiting findpeaks algorithm to get valuable information.
    [pks,locs,w,p] = findpeaks(seg);
    % Find the "true peaks" with prominence
    [MAX,MAXIN] = max(p);
    
    lowBound  = locs(MAXIN) - 60;
    highBound = locs(MAXIN) + 60;
    % If the most prominent peak came at the end of the arary, updated so
    % you don't overflow.
    if highBound > 2500
        p(MAXIN) = 0;
        [MAX,MAXIN] = max(p);
        lowBound  = locs(MAXIN) - 60;
        highBound = locs(MAXIN) + 60;        
    end
    % Take a sample data segment to gerenate the matched filter from
    sampleBeat = seg(lowBound:highBound);
    % Visualize data
    close all
    figure(1);
    stem(sampleBeat)
    % Flip the filter for preparation
    matchFiltCoeff = fliplr(sampleBeat);
    % Generate five different PQRST complexes to average together
    valsToAve(:,j) = matchFiltCoeff;
    finalMatchFilt = mean(valsToAve,2);
end    
% Set the thresholds using the matched filter method
potentialThres = zeros(1,5);
for k = 1:5
    filteredSeg = filter(B,1,seg);
    correlation = filter(finalMatchFilt,1,filteredSeg);
    potentialThres(k) = max(abs(correlation));
end
% Take 75% of the mean threshold determined by baseline levels of overlap
threshold = mean(potentialThres)*0.75;

% Analysis loop: each iteration processes one frame of data
%----------------------------------------------------------
allCorrelation = zeros(1,frame_N);
for i = 1:frame_N
    %  Get the next data segment
    seg = filteredData(((i-1)*frame_step+1):((i-1)*frame_step+frame_length));
    filteredSeg = filter(B,1,seg);   
    %  Perform computations on the segment . . .
    correlation = filter(finalMatchFilt,1,filteredSeg);
    close all
    figure(1);
    subplot(2,1,1)
    stem(abs(correlation));
    if max(abs(correlation)) >= threshold
        alarm(i) = 0;
    else 
        alarm(i) = 1;
    end
    allCorrelation(i) = max(abs(correlation));
end
figure;
% Plot all the datas that you use to determine alarm and plot the threshold
stem(allCorrelation)
hold on
line([0,60],[threshold, threshold]);
