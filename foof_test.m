clear; close all; clc;
% load a datset manually here
EEG.icaact = pagemtimes(EEG.icaweights,EEG.data);
datavar = mean(var(EEG.data(:, :), [], 2));
pvaf = [];
for c_i = 1:62
    projvar = mean(var(EEG.data(:, :) - ...
        EEG.icawinv(:, c_i) * EEG.icaact(c_i, :), [], 2));
    pvaf(c_i) = 100 *(1 - projvar/ datavar);
end

% datavar = sum(sum((EEG.data(:, :)-m(EEG.data(:,:),2)).^2,2));
% for c_i = 1:62
%   proj = EEG.icawinv(:, c_i) * EEG.icaact(c_i, :);
%   projvar = sum(sum( (proj-m(proj,2)).^2 ));
%   pvaf(c_i) = 100*(projvar/datavar);
% end
% 
% rpvaf = [];
% 
% for c_i = 2:62
%     proj = EEG.icawinv(:, c_i) * EEG.icaact(c_i, :);
%     projvar = sum(sum( (proj-m(proj,2)).^2 ));
%     
%     prev_proj = EEG.icawinv(:, c_i-1) * EEG.icaact(c_i-1, :);
%     prev_projvar = sum(sum( (prev_proj-m(prev_proj,2)).^2 ));
%     
%     rpvaf(c_i-1) = 100 *(1 - projvar / datavar);
% end

% pvaf = (1./(2:63));
% pvaf = pvaf./sum(pvaf);
cspvaf = cumsum(pvaf);
rpvaf = 100*pvaf(2:end)./(100-cspvaf(1:end-1));

% ic = EEG.icaact(:,:);
% for ici = 1:size(ic,1)
%   ent(ici) = wentropy(ic(ici), 'shannon');
% end
% [pxx, f] = pwelch(squeeze(data(16,:)),4*500,[],500,500,'power' );
% ex = fft(data(16,:),4*500);
% [pxx, f] = pwelch(squeeze(data(16,:)),4*500,[],500,500,'power' );
% ex = fft(data(16,:),4*500);
% plot(real(ex))
% f = 0:0.01:250;
% pxx = 113*f.^(-.81);
% pxx(1) = 0;
% sym_pxx = [pxx,fliplr(pxx)];
% ipxx = ifft(sym_pxx,'symmetric');
% plot(sym_pxx)
% f(1) = [];
% pxx(1) = [];
% f = f(1:200);
% pxx = pxx(1:200);

f = 1:62';
pxx = pvaf;
chis = -0.01:-0.01:-2.5;
bs = .1:.1:200;
numelems = length(bs)*length(chis);
mse = [];
for chi_i = 1:length(chis)
	chi_i
	for b_i = 1:length(bs)
		chi = chis(chi_i);
		b = bs(b_i);
		m = b*f.^(chi);
		err = m-pxx;
		mse(b_i, chi_i) = mean(err.^2);
	end
end
[mse_min, mse_min_lin_i] = min(mse(:));
[min_b_i, min_chi_i] = ind2sub(size(mse),mse_min_lin_i);
min_b = bs(min_b_i);
min_chi = chis(min_chi_i);
figure;
plot(f,pxx); hold on;
plot(f,min_b*f.^(min_chi),'k')
xlim([1,f(end)]);
xlabel('Component Rank')
ylabel('Percent Variance Accounted For');

figure; plot(2:62,rpvaf);
xlabel('Component Rank by PVAF')
ylabel('Remaining Percent Variance Accounted For');