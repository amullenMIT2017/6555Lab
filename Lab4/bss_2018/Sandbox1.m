% Andrew Mullen & Yichu Jin
% 4/20/2018
% Will handle the first day of quesitons ____ through _____
% Pre-lim
% Load the data of several .dat files and add them into what is being
% really measured.

close all
clear all

load('data/fecg1.dat')
load('data/mecg1.dat')
load('data/noise1.dat')

clinicalObs = fecg1 + mecg1 + noise1;
figure;
tVec = linspace(0,10,2560);
subplot(2,2,1)
plot(tVec,mecg1)
xlabel('Samples [n]')
ylabel('Measurement (mV)')
title('Maternal ECG Data')
ylim([-10,10])
hold on
subplot(2,2,2)
plot(tVec,fecg1)
xlabel('Samples [n]')
ylabel('Measurement (mV)')
title('Fetal ECG Data')
ylim([-10,10])

subplot(2,2,3)
plot(tVec,noise1)
xlabel('Samples [n]')
ylabel('Measurement (mV)')
title('Noise Data')
ylim([-10,10])

subplot(2,2,4)
plot(tVec,clinicalObs)
xlabel('Samples [n]')
ylabel('Measurement (mV)')
title('Theoretical Clinical Observation Data')
ylim([-10,10])

% Question 1

% Determine Heart Rates
maternalBeatOne = 4.662;
maternalBeatTwo = 5.651;
deltaMaternal = maternalBeatTwo - maternalBeatOne;
maternalHR = 60/deltaMaternal

% Determine fetal HR
fetalBeatOne = 2.013;
fetalBeatTwo = 2.413;
deltaFetal = fetalBeatTwo - fetalBeatOne;
fetalHR = 60/deltaFetal

% Question 2 Determind first and second order moments
fetalMean = mean(fecg1);
fetalVar = var(fecg1);

maternalMean = mean(mecg1);
maternalVar = var(mecg1);

noiseMean = mean(noise1);
noiseVar = var(noise1);

% Question 3 plot the pdfs of the signals

figure;
histMaternal = histogram(mecg1,100,'Normalization','pdf');
title('PDFs of Recorded Signals')
xlabel('Recorded Voltage (mV)')
hold on;
histFetal = histogram(fecg1,100,'Normalization','pdf');
histNoise = histogram(noise1,100,'Normalization','pdf');
legend('Maternal ECG','Fetal ECG','Noise')

kurtosisMaternal = kurtosis(histMaternal.Values);
kurtosisFetal = kurtosis(histFetal.Values);
kurtosisNoise = kurtosis(histNoise.Values);

subplot(3,1,1)
histogram(mecg1,100,'Normalization','pdf')
title('PDFs of Maternal ECG')
xlabel('Recorded Voltage (mV)')
hold on
subplot(3,1,2)
histogram(fecg1,100,'Normalization','pdf')
title('PDFs of Fetal ECG')
xlabel('Recorded Voltage (mV)')
subplot(3,1,3)
histogram(noise1,100,'Normalization','pdf')
title('PDFs of Noise')
xlabel('Recorded Voltage (mV)')

% Question 4

figure;
[PxxFetal,FFetal] = pwelch(fecg1,[],[],[],256);
[PxxMaternal,FMaternal] = pwelch(mecg1,[],[],[],256);
plot(FFetal,PxxFetal)
xlabel('Frequency (Hz)')
ylabel('Power')
title('Fetal and Maternal ECG Welch Spectral Content')
hold on
plot(FMaternal,PxxMaternal)
legend('Fetal ECG','Maternal ECG')


