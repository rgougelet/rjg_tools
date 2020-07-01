function ci = boot_ttest(x,nperm)
for perm_i = 1:nperm
	xbars(perm_i) = mean(x(randi(length(x), 1, length(x))));
end
% ci = (quantile(xbars,[.025, .975]))
xbar = round(mean(x),3)
ci = round(quantile(xbars,[.025, .975]),3)
