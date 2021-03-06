% Andrew Mullen and Yichu Jin 3/9/2018
% Become familiar with data and functions of this lab

close all
clear all

% Plot the first audio sample
load('data/cw161_8k.mat')
figure;
t = linspace(0,3,size(cw161,1));
plot(t,cw161);
xlabel('Time (sec)')
ylabel('Speaker Recorded Voltage (mv)')
title('Sample Audio Recording 161')

% Plot the second audio sample
load('data/cw162_8k.mat')
figure;
t = linspace(0,3,size(cw162,1));
plot(t,cw162);
xlabel('Time (sec)')
ylabel('Speaker Recorded Voltage (mv)')
title('Sample Audio Recording 162')


% Extract just a stressed vowel.  The empty flask stood on the tin tray,
% empahsis on ay in tray

% Time (2.5 sec)
samIndexVowelSt = 2.642*8000;
addedDif = 0.1*8000;
sampleVowel = cw161(samIndexVowelSt:samIndexVowelSt+addedDif);
soundsc(sampleVowel);

% Remove the DC offset
% sampleVowel = sampleVowel - mean(sampleVowel);

figure;
tSub = linspace(0,100,size(sampleVowel,1));
plot(tSub,sampleVowel)
xlabel('Time (mSec')
ylabel('Speaker Recorded Voltage (mv)')
title('Sub Sample Vowel Recording')

% [Pxx,F] = pwelch(X,WINDOW,NOVERLAP,NFFT,Fs)
Fs= 8000;
figure;
pwelch(sampleVowel,[],[],[],Fs)

% Filter the vowel into  particular frequency band
% We don't care about the phase components of a the underlying signal
filt = fir1(60,500/Fs,'low');
% Analyze the filter we designed
figure;
freqz(filt,1,512,Fs)


figure;
filtOutput = filter(filt,1,sampleVowel);
subplot(2,1,1)
plot(tSub,filtOutput)
xlabel('Time (msec)')
ylabel('Voltage (mv)')
title('Filtered Vowel')
subplot(2,1,2)
plot(tSub,sampleVowel)
xlabel('Time (msec)')
ylabel('Voltage (mv)')
title('Unfiltered Vowel')

figure;
pwelch(filtOutput,[],[],[],Fs)

% Calculate the autocorrelation of the signal
C = xcorr(filtOutput);
t = linspace(-100,100,size(C,1));

figure;
plot(t,C);
xlim([-30,30])
xlabel('Time Lag (msec)')
ylabel('Autocorrelation')
title('')

% Empirically determined lag between autocorrelation to be 10.12 msec between
% the peaks
% This was done by hand
fundamentalPeriod = 10.12e-3;
fundamentalFrequnecy = 1/fundamentalPeriod;

% Create automatic method using the cliped function
% Set the min Underlying to the min value of the signal to only show
% positive clipping of the signal.
% The periodicity of the negative clipped values is not as detectable as
% the positive, subsequently, we decided to focus on 
minUnderlying = min(filtOutput);
maxUnderlying = 0.75*max(filtOutput);
clippedOutput = cclip(filtOutput,minUnderlying,maxUnderlying);
figure;
plot(tSub,clippedOutput)
xlabel('Time (msec)')
ylabel('Clipped Signal (mV)')
title('Clipped Output of filtered Signal')

% Use autocorrelation
CClip = xcorr(clippedOutput);
figure;
plot(t,CClip);
xlim([-30,30])
xlabel('Time Lag (msec)')
ylabel('Autocorrelation')
title('Autocorrelation Around Clipped Signal')


% Empiricially determine the differences in peaks
sampOne = 0;
sampTwo = 9.626;
fundaPeriodClip = (sampTwo - sampOne)*1e-3;
fundaFreqClip = 1/fundaPeriodClip;

%Truncate the signal for peak.m
indexTrunc = ceil(size(CClip,1)/2);
figure;
plot(CClip(indexTrunc:end))


% Find Peaks for automatic detections of fundamental Freq
[peakval, peakIndex] = peak(CClip(indexTrunc:end));
timeDif = peakIndex/Fs;
autoFundaFreqClip = 1/(timeDif);
