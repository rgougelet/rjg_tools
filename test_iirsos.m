srate = 512;
x_osc = sin((5.5)*2*pi*(0:(1/srate):180));
x = x_osc + randn(size(x_osc));
pn = srate*5;
xpad = [zeros(1,pn), x, zeros(1,pn)];

% iir
tic;
iir_data = iirsos.bp(xpad, srate, [5 6], [4.9,6.1], .1, 1, 1);
iir_data = iir_data(pn+1:end-pn); toc;
%     [n, wn] = buttord([3 8]./srate, [2 9]./srate, 3, 6);
%     [iir_b, a] = butter(n, wn, 'bandpass');
%     iir_b = iir_b*hamming(n);
% mean(abs(iir_data-x_osc))
% 
% % fir
% tic; [m, ~] = firwsord('hamming', 512, 1); % from the eeglab firfilt plugin
% b = firws(m, [5, 6]/(srate/2));
% fir_data = filtfilt(b, 1, xpad);
% fir_data = fir_data(pn+1:end-pn); toc;
% mean(abs(fir_data-x_osc))
% 
% figure; plot(abs(iir_data-x_osc));
% hold on; plot(abs(fir_data-x_osc));
% legend({'IIR error','FIR error'});