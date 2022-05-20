function [min_chi, min_b] = foof(f, pxx)
f = reshape(f, size(pxx));
chis = 0:-0.005:-2;
bs = 0:.1:50;
[~,onef_i] = min(abs(f-1));
bs(end+1) = pxx(onef_i);
pxx(f==0)=0;
chi_bs = [];
for chi_i = 1:length(chis)
  chi = chis(chi_i);
	for b_i = 1:length(bs)
		b = bs(b_i);
    chi_bs(end+1,:) = [chi; b];
	end
end

err = [];
for chi_b_i = 1:length(chi_bs)
  chi = chi_bs(chi_b_i,1);
  b = chi_bs(chi_b_i,2);
  est_pxx = b.*f.^chi;
  est_pxx(f==0)=0;
  err(chi_b_i) = mean(abs(est_pxx-pxx));
end
[~,i] = min(err);
min_chi = chi_bs(i,1);
min_b = chi_bs(i,2);