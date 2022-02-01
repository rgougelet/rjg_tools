function bhats = reg_boot(x,y,nboot)
  % y should be column vector, x length(y) x nvar
	bhat = x\y;
	yhat = x*bhat;
  reshat = y-yhat;  
  % run bootstrap by resampling residuals
  len = length(reshat);
  rnd = randi(len,len,nboot);
  booty = yhat+reshat(rnd);
	bhats = x\booty;

