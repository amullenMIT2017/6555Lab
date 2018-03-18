function y = lowPassFilt(x)
% Andrew Mullen & Yichu Jin 3/18/2018

% Make FIR1 filter and then lowpass below 500 Hz

% 60th order filter (don't care about phase)
Fs= 8000;
filt = fir1(60,500/Fs,'low');

y = filter(filt,1,x);


end