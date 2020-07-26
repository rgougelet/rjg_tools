function bhats = reg_boot(x,y,nboot)
	bhat = x\y;
	yhat = x*bhat;
	reshat = y-yhat;

	% run bootstrap by shuffling residuals
	bhats = nan(nboot,length(bhat));
	for i = 1:nboot
		booty = yhat+reshat(randi(length(reshat),length(reshat),1));
		bhats(i,:) = x\booty;
	end


