function [EEG] = cleaning_utility(orig_EEG)
% EEG data preprocessing should be fast and easy, require no special algorithms,
% and be able to reasonably recover data from typical EEG datasets.
% It strictly uses well-known summary statistics and fast visualizations
% to make cleaning data intuitive, easy, and most importantly, quick.

% This utility accepts 2D, chans x samp, or 3D data, i.e. chans x samp x epoch
% and returns in the same dimension, but for 2D data must convert it into
% 3D to function.

% This utility only operates on the EEG.reject.rejmanual field.
clc;
fprintf('Welcome to the EEG cleaning utility...\n')
EEG = orig_EEG;
nDim = length(size(EEG.data));
% 2 or 3d only
if nDim ~= 2 && nDim ~= 3
	error('Data not 2D or 3D');
end
% convert data to 3d if 2d
if nDim == 2
	prompt = {...
		'Your data are 2D and must be converted to 3D...\n'
		'How long should the chunks be in seconds?\n'
		'Input: '
		};
	chnk_length_in_secs = str2double(input([prompt{:}],'s'));
% TODO: implement overlap
% 	prompt = ...
% 		['\nHow much percent overlap (0 to 100)?\n'...
% 		'Input: '];
% 	overlap = str2double(input(prompt,'s'))/100;
	chnk_length_in_samps = EEG.srate*chnk_length_in_secs;
	n_chnks = floor(EEG.pnts/chnk_length_in_samps);
	% add events as chunk boundaries for splitting
	for chnk_i = 1:n_chnks
		EEG.event(end+1).type = 'split';
		EEG.event(end).latency = 1+(chnk_i-1)*chnk_length_in_samps;
	end
	EEG = pop_editeventvals(EEG,'latency',1);
	EEG = pop_epoch(EEG,{'split'},[0  chnk_length_in_secs],'epochinfo', 'yes');
% TODO: implement overlap
% 	EEG = pop_epoch( EEG, {'split'},...
% 			[-overlap*chnk_length_in_secs  (1-overlap)*chnk_length_in_secs],...
% 			'epochinfo', 'yes');
	% remove split events
	rej = 1:length({EEG.event.type});
	rej = rej(strcmp({EEG.event.type},'split'));
	EEG = pop_editeventvals(EEG,'delete',rej);
	EEG = eeg_checkset(EEG);
end

% create rejection array if empty
if isempty(EEG.reject.rejmanual)
	EEG.reject.rejmanual = false(1,EEG.trials);
end
if ~exist('EEG.etc.thresh','var') || isempty(EEG.etc.thresh)
	EEG.etc.thresh = '';
	orig_EEG.etc.thresh = '';
end
main_str = '';
% keep running as long as string is continuously reset to empty
while isempty(main_str)
	% gui is best used docked
	if ~exist('gui','var') || ~isvalid(gui)
		gui = figure('Name','EEG Cleaning Utility','NumberTitle','off');
		set(gui,'WindowStyle','docked')
	else
		figure(gui)
	end		

	prompt = {...
		'\nMain Menu\n'
		' 2. Remove epochs/chunks by standard deviation\n'
% 		' 3. Remove epochs/chunks by amplitude\n'
% 		' 4. Quick plot EEG data\n'
		' 5. Remove channels via pairwise correlation\n'
		' 6. Plot data with vis_artifacts\n'
		' 9. Save and exit\n'
		' 0. Exit without saving\n'
		'Enter a menu item number: '};
	main_str = input([prompt{:}],'s');
	if main_str == '0' 
		figure(gui); close; EEG = orig_EEG; return
	elseif main_str == '9'
		figure(gui); close; EEG = eeg_checkset(EEG); return
	elseif main_str == '6'
		main_str = '';
		viz_arts(EEG);
	elseif main_str == '5'
		main_str = '';
		[EEG, gui] = rm_chans_corr(EEG, gui);

% 	elseif main_str == '4'
% 		main_str = '';
% 		[temp_EEG, EEG, gui] = quickplot(temp_EEG, EEG, gui);
% 
% 	elseif main_str == '3'
% 		main_str = '';
% 		[temp_EEG, EEG, gui] = rm_amps(temp_EEG, EEG, gui);
	elseif main_str == '2'
		main_str = '';
		[EEG, gui] = rm_sds(EEG, gui);
		figure(gui); close;
	else
		disp(['Invalid input. You must type a menu item number.' newline]);
		main_str = '';
	end
end

% TODO: convert data back to 2D if input as 2D
% if length(size(tempEEG.data)) ~= nDim
% 
% end