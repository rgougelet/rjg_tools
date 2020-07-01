function i = mid95(x,p)
	
c1 = cumsum(x)/sum(x);
pp = mean(c1)+[-2*std(maw),9*std(maw)]
% xlim(mean(maw)+[-3*std(maw),3*std(maw)]);

% pp = prctile(c1,p);

% find(c1>pp(1),1)
xlim(mean(maw)+[-3*std(maw),3*std(maw)]);

[~, m1i] = min(abs(x-p(1)));
% i(1) = find(x,x(m1i),1)
% [~,lri] = min(abs(fliplr(x)-p(2)))
[~, m2i] = min(abs(x-p(2)));

% min(cumsum(x)-

lris = 1:length(x);
i(2) = lris(lri);