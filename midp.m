function i = midp(x,p)
	
c = cumsum(x)/sum(x);
[~,m1] = min(abs(c-p(1)/100));
[~,m2] = min(abs(c-p(2)/100));
i = [m1,m2];