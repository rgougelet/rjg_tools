function [xbar,p,test_interval,se] = perm_ttest(x,y)
	diffs = x-y;
	xbar = mean(diffs);
	for perm_i = 1:1000000
		flip = randi(0:1,10,1);
		xbars(perm_i) = mean(diffs.*flip-diffs.*~flip);
	end
	p= 2*min([sum(xbars>xbar);sum(xbars<xbar)],[],1)/length(xbars); % two-sided
	test_interval = quantile(xbars,[.025, .975]);
	se = std(xbars);
end


