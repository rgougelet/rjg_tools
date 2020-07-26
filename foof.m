[pxx, f] = pwelch(squeeze(data(16,:)),4*500,[],500,500,'power' );
ex = fft(data(16,:),4*500);
plot(real(ex))
f = 0:0.01:250;
pxx = 113*f.^(-.81);
pxx(1) = 0;
sym_pxx = [pxx,fliplr(pxx)];
ipxx = ifft(sym_pxx,'symmetric');
plot(sym_pxx)
f(1) = [];
pxx(1) = [];
f = f(1:200);
pxx = pxx(1:200);
chis = -0.01:-0.01:-2.5;
bs = .1:.1:200;
numelems = length(bs)*length(chis)
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
clf;
plot(f,pxx); hold on;
plot(f,min_b*f.^(min_chi),'k')