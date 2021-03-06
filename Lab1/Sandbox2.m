% Andrew Mullen, Yichu Jin 
% 2/16/2018

%
clear all
close all
clc

load('data/n_421.mat')
noiseSample = n_421;
noiseSampleTime = 0:1/250:size(n_421,1)/250;

noiseSample = noiseSample()

load('data/n_423.mat')
subSample = n_423;
subSampleTime = 0:1/250:size(n_423,1)/250;


% Get a 10 second sample of data & time
% subSampleTime = t(startSample:startSample+tenSecondSample);
% subSample = ecg(startSample:startSample+tenSecondSample);

% Get a 10 second sample of data & time in the noisy seciton of data

% startTimeSample = 4*60*250 + 20*250;
% noiseSampleTime = t(startTimeSample:startTimeSample+tenSecondSample);
% noiseSample = ecg(startTimeSample:startTimeSample+tenSecondSample);

Fs = 250;

[Pxx,F]= pwelch(subSample,[],[],[],Fs);
dbPxx = pow2db(Pxx);
figure;
plot(F,dbPxx)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
%% TODO fix the title
title('Welchs Method Baseline')

[PxxNoise,FNoise] = pwelch(noiseSample,[],[],[],Fs);
dbPxxNoise = pow2db(PxxNoise);
figure;
plot(F,dbPxxNoise)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
%% TODO fix the title
title('Welchs Method Noise')


% Overlay the two plots
figure;
plot(F,dbPxxNoise);
hold on
plot(F,dbPxx);
legend('Noise','Baseline')
xlabel('Frequency (Hz)')
ylabel('Power (dB)')

% High cutoff of 36 Hz
% Low cutoff of 1.2 Hz
% HPF = 36.38*pi/125;
% LPF = 1.221*pi/125;
% 
% B = fir1(10,[LPF,HPF]);
% figure;
% freqz(B,1,512)

HPF = 29.38/125;
LPF = 5.615/125;

B = fir1(40,[LPF,HPF],'bandpass');
figure(4);

[mag,frq] = freqz(B,1,512,250);
dbFilterGain = mag2db(abs(mag));
plot(frq,dbFilterGain)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
title('Filter Response by Frequency')
xlim([0,125])

figure;
plot(frq,dbFilterGain)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
title('Comparison of Filter and Data')
hold on
plot(F,dbPxxNoise);
plot(F,dbPxx);
xlim([0,125])
legend('Filter','Noise','Baseline')

figure;
freqz(B,1,512);
figure();
impz(B,1);

 yFiltered = filter(B,1,subSample);
 figure;
 plot(subSampleTime,yFiltered)
 hold on
 plot(subSampleTime,subSample)
 xlabel('Time (sec)')
 ylabel('ECG Signal Volts (mv)')
 title('ECG Signal')
 legend('Filtered ECG','Normal ECG')
 xlim([min(subSampleTime),max(subSampleTime)])
 
 
 
  yFilteredNoise = filter(B,1,noiseSample);
 figure;
 subplot(2,1,1);
 plot(noiseSampleTime,yFilteredNoise)
 xlabel('Time (sec)')
 ylabel('ECG Signal Volts (mv)')
 title('ECG Filtered Noise Signal')
 xlim([min(noiseSampleTime),max(noiseSampleTime)])
 subplot(2,1,2);
 plot(noiseSampleTime,noiseSample)
 xlabel('Time (sec)')
 ylabel('ECG Signal Volts (mv)')
 title('ECG Noise Signal')
%  legend('Filtered Noise ECG','Noise ECG')
 xlim([min(noiseSampleTime),max(noiseSampleTime)])
 
 

%% Lab Part 2
% load('data/n_423.mat')
% 
% [pxx,f] = pwelch(n_423,1000,[],1024,250);
% figure;
% plot(f,pow2db(pxx))
% xlabel('Frequency (Hz)')
% ylabel('Power (dB)')
% title('Atrial Fibrillation w/ Noise')
% ylim([-20,50])
% 
% load('data/n_421.mat')
% 
% [pxx,f] = pwelch(n_421,1000,[],1024,250);
% figure;
% plot(f,pow2db(pxx))
% xlabel('Frequency (Hz)')
% ylabel('Power (dB)')
% title('Normal Sinus w/ Noise')
% ylim([-20,50])

% 
[PxxFiltered,F]= pwelch(yFiltered,[],[],[],Fs);
dbPxxFilterd = pow2db(PxxFiltered);
figure;
plot(F,dbPxxFilterd)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
%% TODO fix the title
title('Welchs Method Baseline Filtered')

[PxxNoiseFiltered,FNoise] = pwelch(yFilteredNoise,[],[],[],Fs);
dbPxxNoiseFiltered = pow2db(PxxNoiseFiltered);
figure;
plot(F,dbPxxNoiseFiltered)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
%% TODO fix the title
title('Welchs Method Noise Filtered')

%% Final Plot with Filter Response, Baseline, Noisey, Filtered Baseline & Filtered Noisey

figure;
plot(frq,dbFilterGain)
xlabel('Frequency (Hz)')
ylabel('Power (dB)')
title('Comparison of Filter and Data')
hold on
plot(F,dbPxx);
plot(F,dbPxxFilterd)
plot(F,dbPxxNoise);
plot(F,dbPxxNoiseFiltered);
xlim([0,125])
legend('Filter Response','Baseline','Baseline Filtered','Noise','Noise Filtered')



