function [EEG, gui, strnum] = rm_sds(EEG, gui)
	str = '';
	if ~exist('gui','var') || ~isvalid(gui)
% 		closeafter
		gui = figure('Name','EEG Cleaning Utility','NumberTitle','off');
		set(gui,'WindowStyle','docked')
	else
		figure(gui)
	end
	if isempty(EEG.reject.rejmanual)
		EEG.reject.rejmanual = false(1,EEG.trials);
	end
	nepcs = size(EEG.data,3);
	rej = EEG.reject.rejmanual;
	% get stds of epochs that are not already rejected
	stds = mean(squeeze(std(EEG.data,0,2)),1);
	estds = mean(squeeze(std(EEG.data,0,1)),1);
% 	plot(estds); hold on; plot(stds)
	% reduce srate to match downsampling

	dsrate = 1/(size(EEG.data,2)/EEG.srate);
	% filter stds to remove slow drifts
	[b,a] = butter(2,.1,'high');
	festds = filtfilt(b,a,estds);
	fstds = filtfilt(b,a,stds);
% 	clf; plot(festds); hold on; plot(fstds)

	while isempty(str) % wait for input
		plot_data = abs(fstds); plot_data(rej) = NaN;
		plot_edata = abs(festds); plot_edata(rej) = NaN;
		hist_data = fstds; hist_data(rej) = NaN;
		qq_data = fstds; qq_data(rej) = NaN;

		% plot
		figure(gui)
		subplot(2,2,[1 2]);
		plot(plot_data); hold on; 
		plot(plot_edata); hold off;
		title('Abs(Filtered Epoch Std. Devs.)');
		xlabel('Epoch Index'); ylabel('Std. Devs.');
		nbins = max(30,floor(size(EEG.data,3)/50));
		subplot(2,2,3); hist(hist_data,nbins); title('Filtered Epoch Std. Devs.');
		subplot(2,2,4); qqplot(qq_data); title('QQ');
		nrej = sum(rej);
		% interact
		prompt = {...
			['\n',num2str(nrej),' or ',num2str(ceil(100*nrej/nepcs))...
			' % of epochs/chunks removed so far.\n']
			'  Remove chunks/epochs with HP filtered standard deviation\n'
			'  greater than what? Refer to plot and enter a number.\n'
			'  Save: s, Undo: z Exit: 0 or x.\n'
			'  Input: '};
		str = input([prompt{:}],'s');
% 		if str == 'z'
% 			continue;
% 		end
		if str == 's'
			disp('  Saved.');
			EEG.reject.rejmanual = rej; 
			EEG = eeg_checkset(EEG);
			str = '';
			clf;	continue;
		end
		if str == 'x'
			clf;	return;
		end
		strnum = str2double(str);
		rej = ((abs(fstds)>strnum)|	(abs(festds)>strnum));
		rej = conv(rej,[1 1 1], 'same')>=1;
		str = '';
	end
end
