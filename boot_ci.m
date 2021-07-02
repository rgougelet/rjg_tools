function [ci, h, p] = boot_ci(x, nperm, alpha, tail)
%% single sample bootstrap confidence interval
if ~exist('alpha', 'var')
  alpha = 0.05;
end
if ~exist('tail', 'var')
  tail = 0;
end
for perm_i = 1:nperm
	xbars(perm_i) = mean(x(randi(length(x), 1, length(x))));
end

if tail == 0
confidence_bounds = [alpha/2, 1-alpha/2];
ci = quantile(xbars, confidence_bounds);
elseif tail == -1
    p = nansum(abs(xbar_diffs)>=abs(difference), dim)/nperm;

confidence_bounds = [alpha/2, 1-alpha/2];
ci = quantile(xbars, confidence_bounds);
elseif tail == 1
  
end
