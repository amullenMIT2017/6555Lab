% Andrew Mullen & Yichu Jin
% 4/20/2018
% Will handle the first day of quesitons ____ through _____
% Pre-lim
% Load the data of several .dat files and add them into what is being
% really measured.

close all
clear all

% Load all of the data
load('data/fecg1.dat')
load('data/mecg1.dat')
load('data/noise1.dat')

% load the fecg2 data
load('data/fecg2.dat')

% Generate the theoretically obsereved signal

clinicalObs = fecg1 + mecg1 + noise1;

% Plot the four different signals
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
title('PDF of Maternal ECG')
xlabel('Recorded Voltage (mV)')
ylabel('Probability Mass')
hold on
subplot(3,1,2)
histogram(fecg1,100,'Normalization','pdf')
title('PDF of Fetal ECG')
xlabel('Recorded Voltage (mV)')
ylabel('Probability Mass')
subplot(3,1,3)
histogram(noise1,100,'Normalization','pdf')
title('PDF of Noise')
xlabel('Recorded Voltage (mV)')
ylabel('Probability Mass')


% Question 4

figure;
[PxxFetal,FFetal] = pwelch(fecg1,[],[],[],256);
[PxxMaternal,FMaternal] = pwelch(mecg1,[],[],[],256);
[PxxNoise,FNoise] = pwelch(noise1,[],[],[],256);

plot(FFetal,PxxFetal)
xlabel('Frequency (Hz)')
ylabel('Power')
title('Fetal, Maternal, and Noise ECG Welch Spectral Content')
hold on
plot(FMaternal,PxxMaternal)
plot(FNoise,PxxNoise)
legend('Fetal ECG','Maternal ECG','Noise')

% Genearet the wiener filters

[yhat, H] = wienerFilter(fecg1,clinicalObs)

% SVD

load('data/X.dat')
plot3ch(X);

[U,S,V] = svd(X,0);
plot3dv(V(:,1),S(1,1),'red');
plot3dv(V(:,2),S(2,2),'blue');
plot3dv(V(:,3),S(3,3),'green');

figure;
subplot(3,1,1)
plot(tVec,U(:,1))
title('SVD Mixture of Signals')
subplot(3,1,2)
plot(tVec,U(:,2))
title('SVD Fetal Like Heartbeat')
subplot(3,1,3)
plot(tVec,U(:,3))
title('SVD Mixture of Signals, maybe more dominated by Maternal ECG')
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
title('Maternal Signal Estimated ICA')
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

% Generate the norms for the two sets of scatter plots 
SVDFirstPlot = [-7.121,3.635,10.91].*2;
%     7.121,-3.635,-10.91];
SVDSecondPlot = [6.563,5.044,2.604].*2;

SVDThirdPlot = [2.891,-5.72,3.793].*2;

SVDnormOne = norm(SVDFirstPlot);
SVDnormTwo = norm(SVDSecondPlot);
SVDnormThree = norm(SVDThirdPlot);

ICAFirstPlot = [16.95,13.28,19.62].*2;
ICASecondPlot = [7.214,6.898,12.95].*2;
ICAThirdPlot = [12.95,4.015,18.68].*2;

ICAnormOne = norm(ICAFirstPlot);
ICAnormTwo = norm(ICASecondPlot);
ICAnormThree = norm(ICAThirdPlot);

% Calculate angles of V
AnglesSVD(1,2) = dot(V(:,1),V(:,2));
AnglesSVD(2,1) = dot(V(:,1),V(:,2));
AnglesSVD(1,3) = dot(V(:,1),V(:,3));
AnglesSVD(3,1) = dot(V(:,1),V(:,3));
AnglesSVD(2,3) = dot(V(:,2),V(:,3));
AnglesSVD(3,2) = dot(V(:,2),V(:,3));
AnglesSVD(1,1) = 1;
AnglesSVD(2,2) = 1;
AnglesSVD(3,3) = 1;


AnglesICA(1,2) = dot(WInvers(:,1),WInvers(:,2));
AnglesICA(2,1) = dot(WInvers(:,1),WInvers(:,2));
AnglesICA(1,3) = dot(WInvers(:,1),WInvers(:,3));
AnglesICA(3,1) = dot(WInvers(:,1),WInvers(:,3));
AnglesICA(2,3) = dot(WInvers(:,2),WInvers(:,3));
AnglesICA(3,2) = dot(WInvers(:,2),WInvers(:,3));
AnglesICA(1,1) = 1;
AnglesICA(2,2) = 1;
AnglesICA(3,3) = 1;


% Compare the correlation coefficients

% First need to select the correct data
% Weiner Data
wienerData = yhat;

% SVD channel = 
SVDCompare = SVDReconstruct(:,1);

ICACompare = ICAReconstruction(1,:);

% Calcualte correlation coefficients with fecg2

WienerCorrelate = corrcoef(fecg2,wienerData);
SVDCorrelate = corrcoef(fecg2,SVDCompare);
ICACorrelate = corrcoef(fecg2,ICACompare);

% create plot of the time series reconstructions

figure;
subplot(4,1,1)
plot(tVec,fecg2)
xlabel('Time (sec)')
ylabel('Voltage (mV)')
title('Fetal ECG2 Data ')

subplot(4,1,2)
plot(tVec,wienerData)
xlabel('Time (sec)')
ylabel('Voltage (mV)')
title('Wiener Data Estimation')

subplot(4,1,3)
plot(tVec,SVDCompare)
xlabel('Time (sec)')
ylabel('Voltage (mV)')
title('SVD Data Estimation')

subplot(4,1,4)
plot(tVec,ICACompare)
xlabel('Time (sec)')
ylabel('Voltage (mV)')
title('ICA Data Estimation')




