function [r,p,alpha_bounds,se] = perm_corr(x,y)
	[r,~] = corr(x,y);
	for perm_i = 1:10000
		rs(perm_i) = corr(x,y(randperm(length(y))));
	end
	p= 2*min([sum(rs>r);sum(rs<r)],[],1)/length(rs); % two-sided
	alpha_bounds = quantile(rs,[.025, .975]);
	se = std(rs);
end

