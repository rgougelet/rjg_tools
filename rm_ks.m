function [EEG, gui] = rm_ks(EEG, gui)
	str = '';
	if isempty(EEG.reject.rejmanual)
		EEG.reject.rejmanual = false(1,EEG.trials);
	end
% 	% clean
% 	block_size_in_secs = 1;
% 	block_size_in_samps = floor(EEG.srate*block_size_in_secs);
% 
% 	quant_size_in_samp = block_size_in_samps;
% 	tic
% 	n_blocks = floor(length(EEG.data)/block_size_in_samps);
% 	data_mask = zeros(size(EEG.data));
% 	block_mask = [];
% 	block_ps = [];
% 	for chan_i = 1:EEG.nbchan
% 		chan = EEG.data(chan_i,:);
% 		chan_quants = quantile(chan,0:(1/quant_size_in_samp):1);
% 		for block_i = 1:n_blocks
% 			block_start_i = (block_i-1)*block_size_in_samps+1;
% 			block_end_i = (block_i)*block_size_in_samps;
% 			block = chan(block_start_i:block_end_i);
% 			[h,p] = kstest2(block,chan_quants,0.05/n_blocks);
% 			data_mask(chan_i,block_start_i:block_end_i) = h;
% 			block_mask(chan_i,block_i) = h;
% 			block_ps(chan_i,block_i) = p;
% 		end
% 	end
% 	toc
% 	figure;heatmap(block_mask,'GridVisible','off')
% caxis([0 1])
% 	figure;plot(sum(double(block_ps>(0.001/n_blocks*EEG.nbchan)),1))
% good_data = EEG;
% good_data.event = [];
% good_data.data(logical(data_mask))=NaN;
% bad_data = EEG;
% bad_data.event = [];
% bad_data.data(~logical(data_mask))=NaN;
% vis_artifacts(good_data,bad_data, 'windowlength',40);