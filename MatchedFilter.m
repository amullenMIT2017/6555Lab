% Andrew Mullen
% 3/2/2018
clear all
close all

% Matched filter Implementation

% tutorial
% waveform = phased.LinearFMWaveform('PulseWidth',1e-4,'PRF',5e3,...
%     'SampleRate',1e6,'OutputFormat','Pulses','NumPulses',1,...
%     'SweepBandwidth',1e5);
% wav = getMatchedFilter(waveform);
% 
% filter = phased.MatchedFilter('Coefficients',wav);
% taylorfilter = phased.MatchedFilter('Coefficients',wav,...
%     'SpectrumWindow','Taylor');
% 
% sig = waveform();
% rng(17)
% x = sig + 0.5*(randn(length(sig),1) + 1j*randn(length(sig),1));
% 
% 
% y = filter(x);
% y_taylor = taylorfilter(x);
% 
% 
% 
% 
% t = linspace(0,numel(sig)/waveform.SampleRate,...
%     waveform.SampleRate/waveform.PRF);
% subplot(2,1,1)
% plot(t,real(sig))
% title('Input Signal')
% xlim([0 max(t)])
% grid on
% ylabel('Amplitude')
% subplot(2,1,2)
% plot(t,real(x))
% title('Input Signal + Noise')
% xlim([0 max(t)])
% grid on
% xlabel('Time (sec)')
% ylabel('Amplitude')
% 
% 
% 
% plot(t,abs(y),'b--')
% title('Matched Filter Output')
% xlim([0 max(t)])
% grid on
% hold on
% plot(t,abs(y_taylor),'r-')
% ylabel('Magnitude')
% xlabel('Seconds')
% legend('No Spectrum Weighting','Taylor Window')
% hold off
% 
% waveform = phased.LinearFMWaveform('PulseWidth',1e-4,'PRF',5e3,...
%     'SampleRate',1e6,'OutputFormat','Pulses','NumPulses',1,...
%     'SweepBandwidth',1e5);
% 
% x = 0:1:1e1;
% 
% waveformSample = sin(x);
% figure;
% plot(waveformSample)
% 
% wav = getMatchedFilter(waveformSample);

% waveform = phased.RectangularWaveform('PulseWidth',1e-5,...
%     'OutputFormat','Pulses','NumPulses',1);
% coeff = getMatchedFilter(waveform)

% %waveform.pulseWidth = 1;
% fs = 500e4;
% sLFM = phased.LinearFMWaveform('SampleRate',fs,...
%     'SweepBandwidth',200e3,...
%     'PulseWidth',1e-3,'PRF',1e3);


% coeff = getMatchedFilter(sLFM)
% coeff = [12,3,4,5,6,7,8,9,10];
% coeff = ones(1,10);
% coeff = coeff.';

% filter = phased.MatchedFilter('Coefficients',coeff);


% figure;
% plot(filter)

% load('filteredSinusRhythm.mat')
% perfectWave = yFiltered(981:1151);
% save('perfectWave.mat','perfectWave')

load('perfectWave.mat')
load('filteredSinusRhythm.mat')

matchFiltCoeff = fliplr(perfectWave);

% waveform = phased.PhaseCodedWaveform('Code','Zadoff-Chu','ChipWidth',1e-6, ...
%     'NumChips',16,'OutputFormat','Pulses','NumPulses',2);
% coeff = getMatchedFilter(waveform);
figure;
stem(real(matchFiltCoeff))
title('Matched Filter Coefficients')
% axis([0 17 -1.1 1.1])

% filter = phased.MatchedFilter( ...
%     'Coefficients',getMatchedFilter(waveform));
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
% xlim()
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
% hold on;
plot(n_424)
xlabel('Samples')
ylabel('Magnitude (mV)')
xlim([timeToCrap*250,timeToCrap*250 + 1000])

% xlim()
% ylim([-6,6])
% yyaxis right
subplot(2,1,2)
ylabel('Correlation')
plot(InitialTest)
% ylim([-1,1])
legend('Data','Correlation Matched Filter')
xlim([timeToCrap*250,timeToCrap*250 + 1000])
ylim([-1500,1500])


%% New Approach see if better understanding of output of filter
% filter = phased.MatchedFilter('Coefficients',matchFiltCoeff);
% yPhased = filter(n_422);
% figure
% hold on;
% yyaxis left
% plot(n_422)
% xlabel('Samples')
% ylabel('Magnitude (mV)')
% % xlim()
% % ylim([-6,6])
% yyaxis right
% ylabel('Correlation')
% plot(real(yPhased))
% title('Underlying Signal And Correlation w/ Matched Filter')
% % ylim([-1,1])
% legend('Data','Correlation Matched Filter')
% xlim([10000,11000])
% 




