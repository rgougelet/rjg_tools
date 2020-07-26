function viz_arts(EEG)
if ~check_rej(EEG)
	disp('No data have been marked for deletion.'); return;
end
rej_EEG = EEG;
rej_EEG.data(:,:,EEG.reject.rejmanual) = NaN;
vis_artifacts_rjg(rej_EEG,EEG, 'WindowLength', 40);
% vis_artifacts(rej_EEG,EEG);

