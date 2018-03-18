% Andrew Mullen
close all
clear all
L = 257;
Fs = 8000;
N = 18;
B = 200;

bank = filt_bank(N,L,Fs,B);
bank = sum(bank,2);
F = 1:4000;

figure;

Band = abs(freqz(bank(:,1),1,F,Fs)); 
plot(F,Band,'r');
for z=2:N
    Band = abs(freqz(bank(:,z),1,F,Fs));
    hold on;
    plot(F,Band,'b'); 
end