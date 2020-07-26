classdef iirsos
	properties
	end
	methods (Static)
		%% HIGH PASS method
		function [data, srate, sixdbcutoff_hz, passband_hz, desired_passband_ripple, n] = ...
			hp(data,srate, sixdbcutoff_hz, passband_hz, desired_passband_ripple, plot_freq_response, verbose)
		tic;
		if size(data,1)>size(data,2)
			warning('Only works on data with channels as rows');
		end
		[sos, n] = iirsos.design_hp(srate, sixdbcutoff_hz, passband_hz, desired_passband_ripple,plot_freq_response,verbose);
		x = data(:,:)';
		x = sosfilt(sos,x);
		x = flip(sosfilt(sos,flip(x)));
		data = reshape(x',size(data));
		if verbose
			disp(['IIR SOS Highpass: Filtered in ',num2str(toc,3),' seconds'])
		end
		end
		% design highpass
		function [sos, n] = design_hp(srate, sixdbcutoff_hz, passband_hz, desired_passband_ripple, plot_freq_response, verbose)
		nyq = srate/2;
		wp = (passband_hz/nyq); % normalize passband edge
		d = (passband_hz-sixdbcutoff_hz)/nyq; % normalized desired distance to -6db dropoff
		ws = -d+wp; % normalized -6db stopband edge
		rs = 6; % set -6 db dropoff
		[n,wn] = buttord(wp,ws,desired_passband_ripple,rs);

		[A,B,C,D] = butter(n,wn, 'high'); % highpass
		sos = ss2sos(A,B,C,D); % convert to sos representation
		if plot_freq_response
			figure; freqz(sos, srate*100, srate);	title('Stopband')
			subplot(2,1,1); xlim(gca,[0,passband_hz+passband_hz*.1])
			subplot(2,1,2); xlim(gca,[0,passband_hz+passband_hz*.1])
			figure; freqz(sos, srate*100, srate); title('Passband');
			subplot(2,1,1);
			xlim(gca,[passband_hz+passband_hz*.1,nyq])
			ylim(gca,[-.1,.1])
			subplot(2,1,2);
			xlim(gca,[passband_hz+passband_hz*.1,nyq])
			ylim(gca,[-.1,.1])
		end
		[h,f] = freqz(sos, srate*100, srate );
		[~,cutoff_i] = min(abs(mag2db(abs(h))+6));
		if verbose
			disp(['IIR SOS Highpass: Filter order: ',num2str(n),' points'])
			% -6dB cutoff in hz
			disp(['IIR SOS Highpass: -6 dB cutoff point at: ',num2str(f(cutoff_i)),' Hz'])
			% pb ripple
			disp(['IIR SOS Highpass: Average passband ripple: ',num2str(mean(abs(mag2db(abs(h(f>=passband_hz)))))),' dB'])
		end
		end
		
		%% BAND PASS method
		function [data, srate, inner_hz, outer_hz, desired_passband_ripple, n] =...
			bp(data,srate, inner_hz, outer_hz, desired_passband_ripple, plot_freq_response, verbose)
		tic
		if size(data,1)>size(data,2)
			warning('Only works on data with channels as rows, epochs ok');
		end
		
		[sos, n] = iirsos.design_bp(srate, inner_hz, outer_hz, desired_passband_ripple, plot_freq_response, verbose);
		
		% filter
		x = data(:,:)';
		x_sos = sosfilt(sos,x);
		x_sosf = flip(sosfilt(sos,flip(x_sos)));
		data = reshape(x_sosf',size(data));
		if verbose
			disp(['IIR SOS Bandpass: Filtered in ',num2str(toc,3),' seconds'])
		end
		end
		
		% design bandpass
		% inverts bandstop filter by swapping arguments
		function [sos, n] = design_bp(srate, inner_hz, outer_hz, desired_passband_ripple, plot_freq_response, verbose)
		nyq = srate/2;
		
		% normalize inputs
		passband_w = inner_hz./nyq;
		stopband_w = outer_hz./nyq;
		
		% set hz cutoff
		% changing the width of the stopband vs passband
		% and max dB passband ripple is the better way to sharpen the filter 
		% keep this fixed at 6 just to make reporting easier
		rs = 6;
		
		% get filter representation
		[n,wn] = buttord(passband_w,stopband_w,desired_passband_ripple,rs);
		[A,B,C,D] = butter(n,wn, 'bandpass');
		sos = ss2sos(A,B,C,D);
		
		% check -6db cutoff
		[h,f] = freqz(sos, nyq*1000, srate);
% 		[~,cutoff_i] = findpeaks(-abs(mag2db(abs(h))+rs),'MinPeakDistance',diff(inner_hz)*1000);
		[~,db1] = min(abs(f-outer_hz(1)));
		[~,db2] = min(abs(f-outer_hz(2)));
		db_at_cutoff = (mag2db(abs(h([db1, db2]))))';
		
		% check pb ripple
		lf = f >= inner_hz(1);
		rf = inner_hz(2) >= f;
		fb = f(lf&rf);
		pbr = (lf&rf);
		pbr_db = mag2db(abs(h(pbr)));

		if verbose
			disp(['IIR SOS Bandpass: Filter order: ',num2str(n),' points'])
			disp(['IIR SOS Bandpass: Rolloff at intended -6dB points: ',num2str(db_at_cutoff,3),' db'])
			disp(['IIR SOS Bandpass: Avg. abs. passband ripple: ',num2str(mean(abs(pbr_db))),' dB'])
			disp(['IIR SOS Bandpass: Max passband ripple: ',num2str(max(abs(pbr_db))),' dB'])
		end
		% plot if desired
		if plot_freq_response
			figure; 
			subplot(2,1,1); rjgplot(f, mag2db(abs(h)), 'Frequency (Hz)', 'dB','Frequency Response');
			subplot(2,1,2); rjgplot(f, mag2db(abs(h)), 'Frequency (Hz)', 'dB','-6db to Max Ripple');
			ylim(gca, [-6, max(mag2db(abs(h)))])
		end
		
		end
		
		%% BAND STOP method
		function [data, srate, passband_w, stopband_w, desired_passband_ripple, rs, n] = ...
			bs(data, srate, inner_hz, outer_hz, desired_passband_ripple, plot_freq_response, verbose)
		tic
		if size(data,1)>size(data,2)
			warning('Only works on data with channels as rows');
		end
		nyq = srate/2;
		% normalize inputs
		stopband_w = inner_hz./nyq;
		passband_w = outer_hz./nyq;
		
		% set hz cutoff
		% changing the width of the stopband vs passband is how to sharpen the filter
		% keeping this fixed just makes reporting easier
		rs = 6;
		
		% get filter representation
		[n,wn] = buttord(passband_w,stopband_w,desired_passband_ripple,rs);
		[A,B,C,D] = butter(n,wn, 'stop');
		sos = ss2sos(A,B,C,D);
		
		% plot if desired
		if plot_freq_response
			figure; freqz(sos, srate*100, srate );	title('Stopband')
			subplot(2,1,1); xlim(gca,outer_hz)
			subplot(2,1,2); xlim(gca,outer_hz)
			lines = findobj(gcf,'Type','Line');
			for i = 1:numel(lines)
				lines(i).LineWidth = 1.6;
			end
			figure;freqz(sos, srate*100, srate); title('Passband Ripple');
			subplot(2,1,1);	ylim(gca,[-1,1])
			subplot(2,1,2);	ylim(gca,[-1,1])
			lines = findobj(gcf,'Type','Line');
			for i = 1:numel(lines)
				lines(i).LineWidth = 1.6;
			end
		end
		
		% check -6db cutoff
		[h,f] = freqz(sos, srate*1000, srate );
		[~,cutoff_i] = mink(abs(mag2db(abs(h))+6),2);
		db_cutoff = f(cutoff_i)';
		if verbose
			disp(['IIR SOS Bandstop: -6 dB cutoff point at: ',num2str(db_cutoff),' Hz']);
		end
		
		% check pb ripple
		lf = f <= outer_hz(1);
		rf = outer_hz(2) <= f;
		pbr = lf | rf;
		if verbose
			disp(['IIR SOS Bandstop: Average passband ripple: ',num2str(mean(abs(mag2db(abs(h(pbr)))))),' dB'])
		end

		% filter
		x = data(:,:)';
		x = sosfilt(sos,x);
		x = flip(sosfilt(sos,flip(x)));
		data = reshape(x',size(data));
		if verbose
			disp(['IIR SOS Bandstop: Filtered in ',num2str(toc,3),' seconds'])
		end

		end
		
		%% verify that what's in the article is best approach
		function [] = test_output_approach
		srate = 512;
		x_osc = sin(3*2*pi*(0:1/srate:1000));
		x = x_osc + randn(size(x_osc));
		nyq = srate/2;
		% normalize inputs
		stopband_w = [2.9 3.1]./nyq;
		passband_w = [2.8 3.2]./nyq;
		
		% set hz cutoff
		% changing the width of the stopband vs passband is how to sharpen the filter
		% keeping this fixed just makes reporting easier
		rs = 6;
		
		% get filter representation
		[n,wn] = buttord(stopband_w,passband_w,10e-6,rs);
		[A,B,C,D] = butter(n,wn, 'bandpass');
		sos = ss2sos(A,B,C,D);
		[sos_abcd,G_abcd] = ss2sos(A,B,C,D);
		[z,p,k] = butter(n,wn, 'bandpass');
		[sos_zpk, G_zpk] = zp2sos(z,p,k);
		
		% try different filter approaches
		% in order of effectiveness
		close all;
		x_sos = sosfilt(sos,x);
		x_sosff = flip(sosfilt(sos,flip(x_sos)));
		mean(abs(x_osc-x_sosff))
		% 		figure; plot(x_osc-x_sosff)
		
		x_abcd = filtfilt(sos_abcd,G_abcd,x);
		mean(abs(x_osc-x_abcd))
		% 		figure; plot(x_osc-x_abcd)
		
		x_zpk = filtfilt(sos_zpk,G_zpk,x);
		mean(abs(x_osc-x_zpk))
		% 		figure; plot(x_osc-x_zpk)
		
		x_abcd = sosfilt(sos_abcd,x);
		x_abcdf = flip(sosfilt(sos_abcd,flip(x_abcd)));
		mean(abs(x_osc-x_abcdf))
		% 		figure; plot(x_osc-x_abcdf)
		
		x_zpkf = sosfilt(sos_zpk,x);
		x_zpkf = flip(sosfilt(sos_zpk,flip(x_zpkf)));
		mean(abs(x_osc-x_zpkf))
		% 		figure; plot(x_osc-x_zpkf)
		end

		%% test against fir
		function compare_to_fir()
		srate = 512;
		x_osc = sin((5.5)*2*pi*(0:1/srate:20));
		x = x_osc+ randn(size(x_osc));
		pn = srate*5;
		xpad = padarray(x',pn,'circular','both')';

		% iir
		iir_data = iirsos.bp(xpad,srate,[3 8],[2,9],.1,0);
		iir_data = iir_data(pn+1:end-pn);
% 		[n,wn] = buttord([3 8]./srate,[2 9]./srate,3,6);
% 		[iir_b,a] = butter(n,wn,'bandpass');
% 		iir_b = iir_b*hamming(n);
		% fir
		tic; [m, ~] = firwsord('hamming', 512, 1);
		b = firws(m,[2,9]/(srate/2));
		fir_data = filtfilt(b,1,xpad); toc
		fir_data = fir_data(pn+1:end-pn);

		mean(abs(iir_data-x_osc))
		mean(abs(fir_data-x_osc))

		figure; plot(iir_data-x_osc); hold on; plot(fir_data-x_osc);
		end
	end
end