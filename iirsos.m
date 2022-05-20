classdef iirsos
  properties
  end
  methods (Static)
    function [out_data] = filt(in_data, sos)
      if ~isa(in_data, 'double')
        warning(['IIR SOS works best on double precision data,' ...
          ' converting for now...'])
      end
      if size(in_data,1)>size(in_data,2)
        warning(['Second data dimension shorter than first, IIR SOS...' ...
          'works only on row data, i.e. channels as rows']);
      end
      x = double(in_data(:, :)'); % convert to double column data
      x_sos = sosfilt(sos, x);
      x_sosf = flip(sosfilt(sos, flip(x_sos)));
      sos_data = reshape(x_sosf', size(in_data));
      if ~isa(in_data, 'double')
        warning('Converting data back to original precision...')
        out_data = cast(sos_data, class(in_data));
      else
        out_data = sos_data;
      end
    end
    
    %% HIGH PASS METHOD
    function [...
        data,...
        srate,...
        passband_hz,...
        sixdbcutoff_hz,...
        desired_passband_ripple,...
        sos,...
        n] = ...
          hp(...
          data,...
          srate,...
          passband_hz,...
          sixdbcutoff_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)
      tic;
      [sos, n] = iirsos.design_hp(...
        srate,...
        passband_hz,...
        sixdbcutoff_hz,...
        desired_passband_ripple,...
        plot_freq_response,...
        verbose);
      data = iirsos.filt(data, sos);
      if verbose
        disp(['IIR SOS Highpass: Filtered in ', num2str(toc, 3),' seconds'])
      end
    end
    
    %% HIGH PASS DESIGN
    function [...
        sos,...
        n] = ...
        design_hp(...
        srate,...
        passband_hz,...
        sixdbcutoff_hz,...
        desired_passband_ripple,...
        plot_freq_response,...
        verbose)
      nyq = srate/2;
      wp = (passband_hz/nyq); % normalize passband edge
      d = (passband_hz-sixdbcutoff_hz)/nyq; % normalized desired distance to -6db dropoff
      ws = -d+wp; % normalized -6db stopband edge
      rs = 6; % set -6 db dropoff
      [n, wn] = buttord(wp, ws, desired_passband_ripple, rs);

      [A, B, C, D] = butter(n, wn, 'high'); % highpass
      sos = ss2sos(A, B, C, D); % convert to sos representation

      if verbose || plot_freq_response
        [h,f] = freqz(sos, nyq*100, srate);
      end

      if plot_freq_response
        figure;
        subplot(2,1,1); plot(f,20*log10(abs(h))); 
        xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        xlim(gca,[0,passband_hz+passband_hz*.1]);
        
        title('Highpass Filter Stopband');
        subplot(2,1,2); plot(f, unwrap(angle(h))); 
        xlabel('Frequency (Hz)'); ylabel('Phase (radians)');
        xlim(gca,[0, passband_hz+passband_hz*.1]);
        
        figure;
        subplot(2,1,1); plot(f,20*log10(abs(h))); 
        xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        xlim(gca,[passband_hz, nyq]);
        ylim(gca,[-2*std(abs(mag2db(abs(h(f>passband_hz))))),...
          2*std(abs(mag2db(abs(h(f>passband_hz)))))])
        title('Highpass Filter Passband');
        subplot(2,1,2); plot(f, unwrap(angle(h))); 
        xlabel('Frequency (Hz)'); ylabel('Phase (radians)');
        xlim(gca, [passband_hz, nyq]);
      end
      
      if verbose
        [~, cutoff_i] = min(abs(mag2db(abs(h))+6));
        disp(['IIR SOS Highpass: Passband edge: ',num2str(passband_hz),' Hz'])
        disp(['IIR SOS Highpass: Derived -6 dB cutoff point at: ',num2str(f(cutoff_i)),' Hz'])
        disp(['IIR SOS Highpass: Filter order: ',num2str(n),' points'])
        disp(['IIR SOS Highpass: Average passband ripple: ',num2str(mean(abs(mag2db(abs(h(f>=passband_hz)))))),' dB'])
      end
    end
    
    %% LOW PASS METHOD
    function [...
        data,...
        srate,...
        passband_hz,...
        sixdbcutoff_hz,...
        desired_passband_ripple,...
        sos,...
        n] = ...
          lp(...
          data,...
          srate,...
          sixdbcutoff_hz,...
          passband_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)

      tic;
      [sos, n] = iirsos.design_lp(...
        srate,...
        passband_hz,...
        sixdbcutoff_hz,...
        desired_passband_ripple,...
        plot_freq_response,...
        verbose);
      
      data = iirsos.filt(data,sos);
      if verbose
        disp(['IIR SOS Lowpass: Filtered in ', num2str(toc, 3),' seconds'])
      end
    end

    %% LOW PASS DESIGN
    function [...
        sos,...
        n] = ...
          design_lp(...
          srate,...
          passband_hz,...
          sixdbcutoff_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)
      nyq = srate/2;
      wp = (passband_hz/nyq); % normalize passband edge
      d = abs(passband_hz-sixdbcutoff_hz)/nyq; % normalized desired distance to -6db dropoff
      ws = d+wp; % normalized -6db stopband edge
      rs = 6; % set -6 db dropoff
      [n, wn] = buttord(wp, ws, desired_passband_ripple, rs);
      
      [A, B, C, D] = butter(n, wn); % lowpass
      sos = ss2sos(A, B, C, D); % convert to sos representation

      if verbose || plot_freq_response
        [h,f] = freqz(sos, nyq*1000, srate);
      end

      if plot_freq_response
        figure;
        subplot(2,1,1); plot(f,20*log10(abs(h))); 
        xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        xlim(gca,[0,passband_hz+passband_hz*.1]);
        ylim(gca,[-2*std(abs(mag2db(abs(h(f<=passband_hz))))),...
          2*std(abs(mag2db(abs(h(f<=passband_hz)))))]);
        title('Lowpass Filter Passband');
        subplot(2,1,2); plot(f, unwrap(angle(h))); 
        xlabel('Frequency (Hz)'); ylabel('Phase (radians)');
        xlim(gca,[0, passband_hz+passband_hz*.1]);
        
        figure;
        subplot(2,1,1); plot(f,20*log10(abs(h))); 
        xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
        xlim(gca,[passband_hz, nyq]);
        
        title('Lowpass Filter Stopband');
        subplot(2,1,2); plot(f, unwrap(angle(h))); 
        xlabel('Frequency (Hz)'); ylabel('Phase (radians)');
        xlim(gca, [passband_hz, nyq]);
      end

      if verbose
        [~, cutoff_i] = min(abs(mag2db(abs(h))+6));
        disp(['IIR SOS Lowpass: Passband edge: ',num2str(passband_hz),' Hz'])
        disp(['IIR SOS Lowpass: Derived -6 dB cutoff point at: ',num2str(f(cutoff_i)),' Hz'])
        disp(['IIR SOS Lowpass: Filter order: ',num2str(n),' points'])
        disp(['IIR SOS Lowpass: Average passband ripple: ',num2str(mean(abs(mag2db(abs(h(f<=passband_hz)))))),' dB'])
      end
    end
    
    %% BAND PASS METHOD
    function [...
        data,...
        srate,...
        inner_hz,...
        outer_hz,...
        desired_passband_ripple,...
        sos,...
        n] =...
          bp(...
          data,...
          srate,...
          inner_hz,...
          outer_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)
      if verbose; tic; end

      % get single order system
      [sos, n] = iirsos.design_bp(srate, inner_hz, outer_hz, desired_passband_ripple, plot_freq_response, verbose);

      % filter
      data = iirsos.filt(data,sos);

      if verbose
        disp(['IIR SOS Bandpass: Filtered in ',num2str(toc,3),' seconds'])
      end
    end
    
    %% BAND PASS DESIGN
    function [...
        sos,...
        n] =...
          design_bp(...
          srate,...
          inner_hz,...
          outer_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)
        
        % normalize inputs
        nyq = srate/2;
        passband_w = inner_hz./nyq;
        stopband_w = outer_hz./nyq;

        % set hz cutoff
        % changing the width of the stopband vs passband
        % and max dB passband ripple is the better way to sharpen the filter 
        % keep this fixed at 6 just to make reporting easier
        rs = 6;

        % get filter representation
        [n,wn] = buttord(passband_w, stopband_w, desired_passband_ripple, rs);
        [A,B,C,D] = butter(n, wn, 'bandpass');
        sos = ss2sos(A,B,C,D);

        if verbose || plot_freq_response
          [h,f] = freqz(sos, nyq*1000, srate);
        end
        if verbose
          % check -6db cutoff
          [db_at_cutoff,cutoff_i] = mink(abs(mag2db(abs(h))+6),2);
          db_at_cutoff = db_at_cutoff-6;
          disp(['IIR SOS Bandpass: -6 dB cutoff points at: ',num2str(f(cutoff_i)','%4.2f %4.2f'),' Hz']);

          % check pb ripple
          lf = f >= inner_hz(1);
          rf = inner_hz(2) >= f;
          pbr = (lf&rf);
          pbr_db = mag2db(abs(h(pbr)));

          disp(['IIR SOS Bandpass: Filter order: ',num2str(n),' points'])
          disp(['IIR SOS Bandpass: Rolloff at intended -6dB points: ',sprintf('%4.2f %4.2f', db_at_cutoff'),' dB'])
          disp(['IIR SOS Bandpass: Avg. abs. passband ripple: ',num2str(mean(abs(pbr_db))),' dB'])
          disp(['IIR SOS Bandpass: Max passband ripple: ',num2str(max(abs(pbr_db))),' dB'])
        end

        if plot_freq_response
          figure;
    %       subplot(2,1,1); rjgplot(f, mag2db(abs(h)), 'Frequency (Hz)', 'dB','Frequency Response');
    %       subplot(2,1,2); rjgplot(f, mag2db(abs(h)), 'Frequency (Hz)', 'dB','-6dB to Max Ripple');

          subplot(2,1,1); plot(f, mag2db(abs(h)));
          xlabel('Frequency (Hz)'); ylabel('dB'); title('Frequency Response');
          subplot(2,1,2); plot(f, mag2db(abs(h)));
          xlabel('Frequency (Hz)'); ylabel('dB'); title('-6db to Max Ripple');
          ylim(gca, [-6, max(mag2db(abs(h)))])
        end
        
      end
    
    %% BAND STOP METHOD
    function [...
        data,...
        srate,...
        inner_hz,...
        outer_hz,...
        desired_passband_ripple,...
        sos, n] = ...
          bs(...
          data,...
          srate,...
          inner_hz,...
          outer_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)
      tic;
      
      % get single order system
      [sos, n] = iirsos.design_bs(srate, inner_hz, outer_hz, desired_passband_ripple, plot_freq_response, verbose);

      % filter
      data = iirsos.filt(data,sos);

      if verbose
        disp(['IIR SOS Bandstop: Filtered in ',num2str(toc,3),' seconds'])
      end
    end
  
    %% BAND STOP DESIGN
    function [...
        sos,...
        n] =...
          design_bs(...
          srate,...
          inner_hz,...
          outer_hz,...
          desired_passband_ripple,...
          plot_freq_response,...
          verbose)
        
      % normalize inputs
      nyq = srate/2;
      stopband_w = inner_hz./nyq;
      passband_w = outer_hz./nyq;

      % set hz cutoff
      % changing the width of the stopband vs passband
      % and max dB passband ripple is the better way to sharpen the filter
      % keep this fixed at 6 just to make reporting easier
      rs = 6;

      % get filter representation
      [n,wn] = buttord(passband_w,stopband_w,desired_passband_ripple,rs);
      [A,B,C,D] = butter(n,wn, 'stop');
      sos = ss2sos(A,B,C,D);

      if verbose || plot_freq_response
        [h,f] = freqz(sos, nyq*1000, srate);
      end

      if verbose
        % check -6db cutoff
        [db_at_cutoff,cutoff_i] = mink(abs(mag2db(abs(h))+6),2);
        db_at_cutoff = db_at_cutoff-6;
        disp(['IIR SOS Bandstop: -6 dB cutoff points at: ',num2str(f(cutoff_i)', '%4.2f %4.2f'),' Hz']);

        % check pb ripple
        lf = f <= outer_hz(1);
        rf = outer_hz(2) <= f;
        pbr = lf | rf;
        pbr_db = mag2db(abs(h(pbr)));
        disp(['IIR SOS Bandstop: Filter order: ',num2str(n),' points'])
        disp(['IIR SOS Bandstop: Rolloff at intended -6dB points: ',num2str(db_at_cutoff,'%4.2f %4.2f'),' dB'])
        disp(['IIR SOS Bandstop: Avg. abs. passband ripple: ',num2str(mean(abs(pbr_db))),' dB'])
        disp(['IIR SOS Bandstop: Max passband ripple: ',num2str(max(abs(pbr_db))),' dB'])
      end

      if plot_freq_response
        figure; freqz(sos, srate*100, srate );  title('Stopband')
        subplot(2,1,1); xlim(gca,outer_hz)
        subplot(2,1,2); xlim(gca,outer_hz)
        lines = findobj(gcf,'Type','Line');
        for i = 1:numel(lines)
          lines(i).LineWidth = 1.6;
        end
        figure;freqz(sos, srate*100, srate); title('Passband Ripple');
        subplot(2,1,1);  ylim(gca,[-1,1])
        subplot(2,1,2);  ylim(gca,[-1,1])
        lines = findobj(gcf,'Type','Line');
        for i = 1:numel(lines)
          lines(i).LineWidth = 1.6;
        end
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
      %     figure; plot(x_osc-x_sosff)

      x_abcd = filtfilt(sos_abcd,G_abcd,x);
      mean(abs(x_osc-x_abcd))
      %     figure; plot(x_osc-x_abcd)

      x_zpk = filtfilt(sos_zpk,G_zpk,x);
      mean(abs(x_osc-x_zpk))
      %     figure; plot(x_osc-x_zpk)

      x_abcd = sosfilt(sos_abcd,x);
      x_abcdf = flip(sosfilt(sos_abcd,flip(x_abcd)));
      mean(abs(x_osc-x_abcdf))
      %     figure; plot(x_osc-x_abcdf)

      x_zpkf = sosfilt(sos_zpk,x);
      x_zpkf = flip(sosfilt(sos_zpk,flip(x_zpkf)));
      mean(abs(x_osc-x_zpkf))
      %     figure; plot(x_osc-x_zpkf)
      end

    %% test against fir
    function compare_to_fir()
      srate = 512;
      x_osc = sin((5.5)*2*pi*(0:1/srate:1800));
      x = x_osc + randn(size(x_osc));
      pn = srate*5;
      xpad = padarray(x', pn, 'circular', 'both')';

      % iir
      tic;
      iir_data = iirsos.bp(xpad, srate, [5 6], [4.9,7.1], .1, 0, 1);
      iir_data = iir_data(pn+1:end-pn); toc;
  %     [n, wn] = buttord([3 8]./srate, [2 9]./srate, 3, 6);
  %     [iir_b, a] = butter(n, wn, 'bandpass');
  %     iir_b = iir_b*hamming(n);
      mean(abs(iir_data-x_osc))

      % fir
      tic; [m, ~] = firwsord('hamming', 512, 1);
      b = firws(m, [5, 6]/(srate/2));
      fir_data = filtfilt(b, 1, xpad);
      fir_data = fir_data(pn+1:end-pn); toc;
      mean(abs(fir_data-x_osc))

      figure; plot(abs(iir_data-x_osc));
      hold on; plot(abs(fir_data-x_osc));
      legend({'IIR error','FIR error'});
    end
  end
end