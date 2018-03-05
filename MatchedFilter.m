% Andrew Mullen
% 3/2/2018
clear all
close all

load('perfectWave.mat')
load('filteredSinusRhythm.mat')

matchFiltCoeff = fliplr(perfectWave);

figure;
stem(real(matchFiltCoeff))
title('Matched Filter Coefficients')

figure;
plot(yFiltered)
xlabel('Sample')
ylabel('Voltage (mv)')
title('Underlying Signal')
y = filter(matchFiltCoeff,1,yFiltered);
figure;
plot(y)
xlabel('Samples')
ylabel('Correlation')
title('Matched Filter Idealized Sinus Rhythm')

figure
hold on;
yyaxis left
plot(y)
xlabel('Samples')
ylabel('Magnitude (mV)')
ylim([-6,6])
yyaxis right
ylabel('Correlation')
plot(yFiltered)
title('Underlying Signal And Correlation w/ Matched Filter')
ylim([-1,1])
legend('Data','Correlation Matched Filter')
xlim([0,2500])

%% Approach w/ Real Data V

load('data/n_424.mat');

InitialTest = filter(matchFiltCoeff,1,n_424);
figure
subplot(2,1,1)
title('Underlying Signal And Correlation w/ Matched Filter')
% hold on;
plot(n_424)
xlabel('Samples')
ylabel('Magnitude (mV)')
xlim([10000,11000])

% xlim()
% ylim([-6,6])
% yyaxis right
subplot(2,1,2)
ylabel('Correlation')
plot(InitialTest)
% ylim([-1,1])
legend('Data','Correlation Matched Filter')
xlim([20*250,20*250 + 1000])
ylim([-1500,1500])

%Everything Went to crap

timeToCrap = 120;

load('data/n_424.mat');


InitialTest = filter(matchFiltCoeff,1,n_424);
figure
subplot(2,1,1)
title('Underlying Signal And Correlation w/ Matched Filter')
plot(n_424)
xlabel('Samples')
ylabel('Magnitude (mV)')
xlim([timeToCrap*250,timeToCrap*250 + 1000])


subplot(2,1,2)
ylabel('Correlation')
plot(InitialTest)
legend('Data','Correlation Matched Filter')
xlim([timeToCrap*250,timeToCrap*250 + 1000])
ylim([-1500,1500])

 

% Filter the data before running on matched filter

%% Create the bandpass filter needed
HPF = 29.38/125;
LPF = 5.615/125;

B = fir1(400,[LPF,HPF],'bandpass');

sampleToFilt = n_424;
filteredInput = filter(B,1,sampleToFilt);

% Filter the data before it gets processed

InitialTest = filter(matchFiltCoeff,1,filteredInput);
figure
subplot(2,1,1)
title('Underlying Signal And Correlation w/ Matched Filter')
% hold on;
plot(filteredInput)
xlabel('Samples')
ylabel('Magnitude (mV)')
xlim([10000,11000])

% xlim()
% ylim([-6,6])
% yyaxis right
subplot(2,1,2)
ylabel('Correlation')
plot(abs(InitialTest))
% ylim([-1,1])
legend('Data','Correlation Matched Filter')
xlim([20*250,20*250 + 1000])
ylim([-1500,1500])




% Repeat the filtering
matchFilteredDataFilt = filter(matchFiltCoeff,1,filteredInput);
figure
subplot(2,1,1)
title('Underlying Signal And Correlation w/ Matched Filter')
plot(filteredInput)
xlabel('Samples')
ylabel('Magnitude (mV)')
xlim([timeToCrap*250,timeToCrap*250 + 1000])


subplot(2,1,2)
ylabel('Correlation')
plot(matchFilteredDataFilt)
legend('Data','Correlation Matched Filter')
xlim([timeToCrap*250,timeToCrap*250 + 1000])
ylim([-1500,1500])
