function [diffbar,p,test_interval,se] = perm_ttest(x,y,nperm)
	diffs = x-y;
	xbar = mean(x);
	ybar = mean(y);
	diffbar = mean(diffs);
	for perm_i = 1:nperm
		flip = randi(0:1,10,1);
		xbars(perm_i) = mean(diffs.*flip-diffs.*~flip);
	end
	p= 2*min([sum(xbars>diffbar);sum(xbars<diffbar)],[],1)/length(xbars); % two-sided
	test_interval = quantile(xbars,[.025, .975]);
	se = std(xbars);

	disp(['xbar = ',num2str(round(xbar,3)),...
		', ybar = ',num2str(round(ybar,3)),...
		', diffbar =', num2str(round(diffbar,3)),...
		', p = ',num2str(round(p,3))])
end


