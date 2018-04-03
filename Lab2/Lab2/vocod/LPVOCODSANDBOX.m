%Andrew Mullen & Yichu Jin
% 4/2/2018

% Generate and save the audio files for the lpvocoder analysis Lab 2 6.555

[coeff, gain, pitch] = lpvocod_ana(cw161,12);
y = lpvocod_syn(coeff, gain, pitch);
lpSynth12 = y;
lpSynthNorm8 = lpSynth12./max(lpSynth12);
audiowrite('lpSynthNorm12.wav',lpSynthNorm12,Fs);


% Generate and save the audio output of the chvocodoer

[band_envelopes,pitch] = chvocod_ana(cw161,100,16);
y = chvocod_syn(band_envelopes,pitch,100);
chSynth = y;
chSynthNorm = chSynth./max(chSynth);
audiowrite('chSynthNorm.wav',chSynthNorm,Fs);

% Save the origional audio segemet
cw161Norm = cw161./max(cw161);
audiowrite('cw161Norm.wav',cw161Norm,Fs);




