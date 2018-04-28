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

kurtosisMaternal = kurtosis(mecg1);
kurtosisFetal = kurtosis(fecg1);
kurtosisNoise = kurtosis(noise1);

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

% Genearet the wiener filters

[yhat, H] = wienerFilter(fecg1,clinicalObs)

% SVD

load('data/X.dat')
plot3ch(X);

[U,S,V] = svd(X,0);
plot3dv(V(:,1),S(1,1),'red')
plot3dv(V(:,2),S(2,2),'blue')
plot3dv(V(:,3),S(3,3),'green')

figure;
subplot(3,1,1)
plot(tVec,U(:,1))
title('Mixture of Signals')
subplot(3,1,2)
plot(tVec,U(:,2))
title('Fetal Like Heartbeat')
subplot(3,1,3)
plot(tVec,U(:,3))
title('Mixture of Signals, maybe more dominated by Materanl ECG')
xlabel('Time (sec)')

% Plot the eigenspecturm of S
figure;
stem(S)
xlim([0,4])
xlabel('Column Number')
ylabel('Eigenspectrum Magnitude')
title('Eigenspectrum of S')

% Alter the eingespecturm to only keep the fetal ECG eigenvalue
% and reinvert
Saltered = S;
Saltered(1,1) = 0;
Saltered(3,3) = 0;

SVDReconstruct = U*Saltered*V;
figure;
subplot(3,1,1)
plot(tVec,SVDReconstruct(:,1))
ylabel('Ch1')
title('Channels of Reconstructed Signal Using SVD')
subplot(3,1,2)
hold on
ylabel('Ch2')
plot(tVec,SVDReconstruct(:,2))
subplot(3,1,3)
hold on
ylabel('Ch3')
plot(tVec,SVDReconstruct(:,3))
xlabel('Time (sec)')

% Do ICA

[W, ZHAT] = ica(X.');
WInvers = inv(W);

% Make a scatter plot of the data
plot3ch(X);
plot3dv(WInvers(:,1))
plot3dv(WInvers(:,2))
plot3dv(WInvers(:,3))

% Plot the identified data from ICA
figure;
subplot(3,1,1)

plot(tVec,ZHAT(1,:))
title('Maternal Signal Estiamted ICA')
ylabel('Component 1')
subplot(3,1,2)
plot(tVec,ZHAT(2,:))
title('Noise Signal Estimated ICA')
ylabel('Component 2')
subplot(3,1,3)
plot(tVec,ZHAT(3,:))
title('Fetal Signal Estimated ICA')
ylabel('Component 3')
xlabel('Time (sec)')

% Eliminate all WInverse except the final column?
WInverseAltered = WInvers;
WInverseAltered(:,1:2) = 0;
ICAReconstruction = WInverseAltered*ZHAT;

% Plot the ICA Reconstructions
figure
subplot(3,1,1)
plot(tVec,ICAReconstruction(1,:))
title('ICA Reconstructions')
ylabel('Channel 1')
subplot(3,1,2)
plot(tVec,ICAReconstruction(2,:))
ylabel('Channel 2')
subplot(3,1,3)
plot(tVec,ICAReconstruction(3,:))
ylabel('Channel 3')
xlabel('Time (sec)')
