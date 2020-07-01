function [difference, ci] = boot_ttest2(x,y,nperm)
difference = mean(x)-mean(y);
for perm_i = 1:nperm
	xbars(perm_i) = mean(x(randi(length(x), 1, length(x)))) - mean(y(randi(length(y), 1, length(y))));
end
% ci = (quantile(xbars,[.025, .975]))
ci = round(quantile(xbars,[.025, .975]),3)