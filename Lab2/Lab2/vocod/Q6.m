close all
clear
clc

%% Load data
load('data/cw161_8k.mat')
% Extract just a stressed vowel.  The empty flask stood on the tin tray,
% empahsis on ay in tray
samIndexVowelSt = 2.642*8000;
addedDif = 0.1*8000;
sampleVowel = cw161(samIndexVowelSt:samIndexVowelSt+addedDif);

% % soundsc(sampleVowel);
% figure;
% tSub = linspace(0,100,size(filtOutput,1));
% plot(tSub,filtOutput)
% xlabel('Time (mSec')
% ylabel('Speaker Recorded Voltage (mv)')
% title('Sub Sample Vowel Recording')

Fs = 8000;
filt = fir1(60,500/Fs,'low');
filtOutput = filter(filt,1,sampleVowel);

Fny = Fs/2;
[coeff,gain] = lpcoef(sampleVowel,12);
F = 0:Fny/1024:Fny-Fny/1024;
%calculating the frequency response of the all pole filter
H = abs(freqz(gain,coeff,F,Fs)); %the order of coefficients is B,A
figure;
hold all;
plot(F,mag2db(H));
Y = abs(fft(sampleVowel,2048));
plot(F,mag2db(Y(1:length(H))));
%xlim([0 600]);
title('Frequency responce of the all pole filter');
xlabel('Frequency (Hz)');
ylabel('Amplitude (dB)');
legend('LP Spectrum with Order of 20','DFT Spectrum');


