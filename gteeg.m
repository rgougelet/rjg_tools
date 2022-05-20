function p = gteeg(varargin)
	if isempty(varargin)
		p.n.epochs = 1;
		p.n.pnts = 500;
		p.izero = 101;
		p.srate = 500;
		p.dc = 0;
		p.baseline.osc.f = 5;
		p.baseline.osc.a = 0;

		% non-oscillatory erp
		p.erp.nosc.crit.t = [-200 0 50 100 200 300 400 500 600 798];
		p.erp.nosc.crit.v = [0 0 -3 8 -2 6 -1 5 2 0];
		p.erp.nosc.crit.t = 0;
		p.erp.nosc.crit.v = 0;

		% time-locked, non-phase-locked
		p.erp.osc.on.set.pnts = p.izero;
		p.erp.osc.off.set.ms = [500 700];
		p.erp.osc.ramp.up.length.ms = 50;
		p.erp.osc.ramp.down.length.ms = 50;
		p.erp.osc.f = 30;
		p.erp.osc.a = 0;
        
        % event-related synchronization
		% time-locked, phase-locked
		p.ers.osc.on.set.pnts = p.izero;
		p.ers.osc.off.set.ms = [800];
		p.ers.osc.ramp.up.length.ms = 50;
		p.ers.osc.ramp.down.length.ms = 50;
		p.ers.osc.f = 10;
		p.ers.osc.a = 5;

        % event-related desynchronization
		% time-locked, non-phase-locked 
		% could also be phase-locked, if phase resetting was implemented, 
		% but its not
		p.erd.osc.on.set.pnts = p.izero;
		p.erd.osc.off.set.ms = [500 700];
		p.erd.osc.ramp.up.length.ms = 50;
		p.erd.osc.ramp.down.length.ms = 50;
		p.erd.osc.f = 20;
		p.erd.osc.a = 0;

		% noise
		p.noise.pink.chi = -0.25;
		p.noise.pink.sd = 0;
		p.noise.white.sd = 0;
    else
        p = varargin{:};
	end
	
	% Every time-related input parameter is in milliseconds, except
	% izero, the index at which t = 0, and npnts, the length of each epoch
	% in samples.

	% todo:
	% allow for user-defined amps and freqs

	% time
	p.t.s = ((1:p.n.pnts)'-p.izero)/p.srate;
	p.t.ms = p.t.s*1000;

	% dc
	p.dc = fillosc(p, p.dc);

	% oscillatory baseline
	p.baseline.osc.f = fillosc(p, p.baseline.osc.f);
	p.baseline.osc.a = fillosc(p, p.baseline.osc.a);
	for ep_i = 1:p.n.epochs
		p.baseline.osc.poffset(ep_i) = 2*pi*(randi(1000,1,1)/1000);
		p.baseline.osc.p(:,ep_i) = p.baseline.osc.poffset(ep_i) + p.t.s.*p.baseline.osc.f(:,ep_i)*2*pi;
		p.baseline.osc.p(:,ep_i) = mod(p.baseline.osc.p(:,ep_i),2*pi);
		p.baseline.osc.data(:, ep_i) = p.baseline.osc.a(:,ep_i).*sin(p.baseline.osc.p(:,ep_i));
	end

	% non-oscillatory erp (time-locked, non-phase-locked)
	if numel(p.erp.nosc.crit.t)>1 && numel(p.erp.nosc.crit.v)>1
		erp = pchip(p.erp.nosc.crit.t, p.erp.nosc.crit.v , p.t.ms)';
	else
		erp = 0;
	end
	for ep_i = 1:p.n.epochs
		p.erp.nosc.data(:,ep_i) = erp;
	end
	
	%% oscillatory erp (time-locked, non-phase-locked)
	p.erp.osc.on.set.ms = pnts2ms(p,p.erp.osc.on.set.pnts);
	p.erp.osc.off.set.pnts = ms2pnts(p,p.erp.osc.off.set.ms);
	p.erp.osc.ramp.up.length.pnts = p.srate*p.erp.osc.ramp.up.length.ms/1000;
	p.erp.osc.ramp.down.length.pnts = p.srate*p.erp.osc.ramp.down.length.ms/1000;

	p.erp.osc.f = fillosc(p, p.erp.osc.f);
	p.erp.osc.a = fillosc(p, p.erp.osc.a);
	for ep_i = 1:p.n.epochs
		p.erp.osc.poffset(ep_i) = 2*pi*(randi(1000,1,1)/1000);
		p.erp.osc.p(:,ep_i) = p.erp.osc.poffset(ep_i) + p.t.s.*p.erp.osc.f(:,ep_i)*2*pi;
		p.erp.osc.p(:,ep_i) = mod(p.erp.osc.p(:,ep_i),2*pi);

		on = p.erp.osc.on.set.pnts;
		ramp.up.off = on+p.erp.osc.ramp.up.length.pnts;
		if length(p.erp.osc.off.set.pnts) == 1
			off = p.erp.osc.off.set.pnts;
		elseif length(p.erp.osc.off.set.pnts) == 2
			off = randi(p.erp.osc.off.set.pnts,1);
		else
			error('Offset must be length 1 or 2')
		end
		ramp.down.on = off-p.erp.osc.ramp.down.length.pnts;
		p.erp.osc.a(1:on, ep_i) = 0;
		p.erp.osc.a(off+1:end, ep_i) = 0;
		p.erp.osc.a(on:ramp.up.off, ep_i) = ...
			p.erp.osc.a(on:ramp.up.off,ep_i).*linspace(0,1,p.erp.osc.ramp.up.length.pnts+1)';
		p.erp.osc.a(ramp.down.on:off, ep_i) = ...
			p.erp.osc.a(ramp.down.on:off,ep_i).*linspace(1,0,p.erp.osc.ramp.down.length.pnts+1)';
		p.erp.osc.data(:, ep_i) = p.erp.osc.a(:,ep_i).*sin(p.erp.osc.p(:,ep_i));
	end

	%% event-related synchronization (time-locked, phase-locked)
	p.ers.osc.on.set.ms = pnts2ms(p,p.ers.osc.on.set.pnts);
	p.ers.osc.off.set.pnts = ms2pnts(p,p.ers.osc.off.set.ms);
	p.ers.osc.ramp.up.length.pnts = p.srate*p.ers.osc.ramp.up.length.ms/1000;
	p.ers.osc.ramp.down.length.pnts = p.srate*p.ers.osc.ramp.down.length.ms/1000;

	p.ers.osc.f = fillosc(p, p.ers.osc.f);
	p.ers.osc.a = fillosc(p, p.ers.osc.a);
	for ep_i = 1:p.n.epochs
		p.ers.osc.poffset(ep_i) = 0;
		p.ers.osc.p(:,ep_i) = p.ers.osc.poffset(ep_i) + p.t.s.*p.ers.osc.f(:,ep_i)*2*pi;
		p.ers.osc.p(:,ep_i) = mod(p.ers.osc.p(:,ep_i),2*pi);

		on = p.ers.osc.on.set.pnts;
		ramp.up.off = on+p.ers.osc.ramp.up.length.pnts;
		if length(p.ers.osc.off.set.pnts) == 1
			off = p.ers.osc.off.set.pnts;
		elseif length(p.ers.osc.off.set.pnts) == 2
			off = randi(p.ers.osc.off.set.pnts,1);
		else
			error('Offset must be length 1 or 2')
		end
		ramp.down.on = off-p.ers.osc.ramp.down.length.pnts;
		p.ers.osc.a(1:on, ep_i) = 0;
		p.ers.osc.a(off+1:end, ep_i) = 0;
		p.ers.osc.a(on:ramp.up.off, ep_i) = ...
			p.ers.osc.a(on:ramp.up.off,ep_i).*linspace(0,1,p.ers.osc.ramp.up.length.pnts+1)';
		p.ers.osc.a(ramp.down.on:off, ep_i) = ...
			p.ers.osc.a(ramp.down.on:off,ep_i).*linspace(1,0,p.ers.osc.ramp.down.length.pnts+1)';
		p.ers.osc.data(:, ep_i) = p.ers.osc.a(:,ep_i).*sin(p.ers.osc.p(:,ep_i));
	end

	%% event-related desynchronization (time-locked, non-phase-locked)
	%~~~~~~~~~~~~~~\__________________________/~~~~~~~~~~~~~
	%													 on.set                                        off.set
	%    ramp.down.on ramp.down.off         ramp.up.on ramp.up.off
	p.erd.osc.on.set.ms = pnts2ms(p,p.erd.osc.on.set.pnts);
	p.erd.osc.off.set.pnts = ms2pnts(p,p.erd.osc.off.set.ms);
	p.erd.osc.ramp.up.length.pnts = p.srate*p.erd.osc.ramp.up.length.ms/1000;
	p.erd.osc.ramp.down.length.pnts = p.srate*p.erd.osc.ramp.down.length.ms/1000;

	p.erd.osc.f = fillosc(p, p.erd.osc.f);
	p.erd.osc.a = fillosc(p, p.erd.osc.a);
	for ep_i = 1:p.n.epochs
		p.erd.osc.poffset(ep_i) = 2*pi*(randi(1000,1,1)/1000);
		p.erd.osc.p(:,ep_i) = p.erd.osc.poffset(ep_i) + p.t.s.*p.erd.osc.f(:,ep_i)*2*pi;
		p.erd.osc.p(:,ep_i) = mod(p.erd.osc.p(:,ep_i),2*pi);

		on = p.erd.osc.on.set.pnts;
		if length(p.erd.osc.off.set.pnts) == 1
			off = p.erd.osc.off.set.pnts;
		elseif length(p.erd.osc.off.set.pnts) == 2
			off = randi(p.erd.osc.off.set.pnts,1);
		else
			error('Offset must be length 1 or 2')
		end
		ramp.up.on = off-p.erd.osc.ramp.up.length.pnts;
		ramp.up.off = off;
		ramp.down.on = on;
		ramp.down.off = on+p.erd.osc.ramp.down.length.pnts;

		p.erd.osc.a(ramp.down.off:ramp.up.on, ep_i) = 0;
		p.erd.osc.a(ramp.down.on:ramp.down.off, ep_i) = ...
			p.erd.osc.a(ramp.down.on:ramp.down.off,ep_i).*linspace(1,0,p.erd.osc.ramp.down.length.pnts+1)';
		p.erd.osc.a(ramp.up.on:ramp.up.off, ep_i) = ...
			p.erd.osc.a(ramp.up.on:ramp.up.off,ep_i).*linspace(0,1,p.erd.osc.ramp.up.length.pnts+1)';
		p.erd.osc.data(:, ep_i) = p.erd.osc.a(:,ep_i).*sin(p.erd.osc.p(:,ep_i));
	end

	%% 1/f noise
	for ep_i = 1:p.n.epochs
		nyq = p.srate/2;
		f = 0:(p.srate/p.n.pnts):nyq;
    noise = zeros(size(p.t.s));
    for f_i = 1:length(f)
      if f(f_i) ~= 0; amp = f(f_i)^p.noise.pink.chi; else; amp = 0; end
      noise = noise + amp*sin(2*pi*f(f_i)*p.t.s+rand*2*pi);
    end
    p.noise.pink.data(:,ep_i) = noise;
	end

	%% white noise
	p.noise.white.data = p.noise.white.sd*randn(p.n.pnts,p.n.epochs);

	%% sum
	p.data =	p.dc+...
		p.baseline.osc.data+...
		p.erp.nosc.data+...
		p.erp.osc.data+...
		p.ers.osc.data+...
		p.erd.osc.data+...
		p.noise.pink.data+...
		p.noise.white.data;

	% highpass filter the data
% 	p.filt.hp.f = 1; % in hz
% 	p.filt.hp.cutoffdist = 0.1; % in hz
% 	p.filt.hp.window_type = 'blackman';
% 	p.filt.hp.filt_ord = pop_firwsord(p.filt.hp.window_type, p.srate, p.filt.hp.cutoffdist);
% 	EEG.trials = p.n.epochs;
% 	EEG.srate = p.srate;
% 	EEG.nbchan = 1;
% 	EEG.pnts = p.n.pnts;
% 	EEG.data(1,:,:) = p.data;
% 	EEG = pop_firws(EEG, 'fcutoff', p.filt.hp.f,	'wtype', p.filt.hp.window_type, 'forder', p.filt.hp.filt_ord, 'ftype','highpass');
% 	p.data = s(EEG.data);

	% lowpass filter the  data
% 	p.filt.lp.f = 55.5; % in hz
% 	p.filt.lp.cutoffdist = 0.5; % in hz
% 	p.filt.lp.window_type = 'blackman';
% 	p.filt.lp.filt_ord = pop_firwsord(p.filt.lp.window_type, p.srate, p.filt.lp.cutoffdist);
% 	EEG.trials = p.n.epochs;
% 	EEG.srate = p.srate;
% 	EEG.nbchan = 1;
% 	EEG.pnts = p.n.pnts;
% 	EEG.data(1,:,:) = p.data;
% 	EEG = pop_firws(EEG, 'fcutoff', p.filt.lp.f,	'wtype', p.filt.lp.window_type, 'forder', p.filt.lp.filt_ord, 'ftype','lowpass');
% 	p.data = s(EEG.data);

	end

function v = fillosc(p, v)
	os = ones(length(p.t.s),1);
	if numel(v) == 1
		v = repmat(v*os,1,p.n.epochs);
	elseif numel(v) == p.n.pnts
		v = repmat(v,1,p.n.epochs);
	elseif numel(v) == p.n.pnts*p.n.epochs
	else
		error('Dimension mismatch')
	end
end

function pnts = ms2pnts(p, mss)
	for msi = 1:length(mss)
		[~, pnts(msi)] = min(abs(p.t.ms-mss(msi)));
	end
end

function ms = pnts2ms(p, pnt)
	ms = p.t.ms(pnt);
end