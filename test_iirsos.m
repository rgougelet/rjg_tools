clear;
srate = 512;
x_osc = sin((5.5)*2*pi*(0:(1/srate):100));
noise = randn(size(x_osc));
x = x_osc + noise;
pn = srate*5;
% xpad = [zeros(1,pn), x, zeros(1,pn)];
xpad = x;
figure; plot(x);

% iir
tic;
iir_x = iirsos.bp(xpad, srate, [5 6], [4.9,6.1], 1, 0, 0);
% iir_x = iir_x(pn+1:end-pn);
toc;
%     [n, wn] = buttord([3 8]./srate, [2 9]./srate, 3, 6);
%     [iir_b, a] = butter(n, wn, 'bandpass');
%     iir_b = iir_b*hamming(n);
mean(abs(iir_x-x_osc))
figure; plot(iir_x); hold on; plot(x_osc);

% fir
tic;
[m, ~] = firwsord('hamming', 512, 1); % from the eeglab firfilt plugin
b = firws(m, [5, 6]/(srate/2));
fir_x = filtfilt(b, 1, xpad);
% fir_x = fir_x(pn+1:end-pn);
toc;
mean(abs(fir_x-x_osc))
figure; plot(fir_x); hold on; plot(x_osc);

figure; plot(abs(iir_x-noise));
hold on; plot(abs(fir_x-noise));
legend({'IIR error','FIR error'});
figure; plot(iir_x)