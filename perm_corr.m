function [r,p,alpha_bounds,se] = perm_corr(x,y,varargin)

	if isempty(varargin); nperm = 10000; else; nperm = varargin{1}; end
	[r,~] = corr(x,y, 'rows','pairwise');
	r = round(r,4);
	for perm_i = 1:nperm
		rs(perm_i) = corr(x,y(randperm(length(y))), 'rows','pairwise');
	end
	p= round(2*min([sum(rs>r);sum(rs<r)],[],1)/length(rs),4); % two-sided
% 	p2 = nansum(abs(rs)>=abs(r))/nperm
	alpha_bounds = quantile(rs,[.025, .975]);
	se = std(rs);

% 	if p<0.1
		disp(['r = ',num2str(round(r,3)),', p = ',num2str(round(p,3))])
% 	end

