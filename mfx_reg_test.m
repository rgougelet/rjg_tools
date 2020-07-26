clc; close all; clear
M = 10;
n = 150;
N = M*n;
fi = 5;

ws_res = .5*randn(N,1); % within subject variability
subj = repmat((1:M)',n,1); % number of trials equal among subjs
% subj = randi(M,N,1); % number of trials not equal among subjs
subj_x = accumarray([(1:N)' subj], ones(N,1));
b = abs(randn(M,1)); % between-subject variability
for subj_i = 1:N
	bs_res(subj_i,:) = 2*b(subj_x(subj_i,:)==1)*randn;
end
B = 10*randn(M,1); % between-subject means
y = subj_x*B+bs_res+ws_res;

% figure(fi+1);
% boxplot(y,subj)
% title('Response'); xlabel('Subjects'); ylabel('Value');
% figure(fi+2);
% boxplot(y,'labels','y');
% title('Response');  ylabel('Value');

% single-mean model (poor-man's random effects)
% ignores between-subject variability
% has large residuals because the "group effects" are
% incorporated into them
sm_lm = fitlm(ones(size(y)),y,'Intercept',false);
% figure(fi+3);
% boxplot(sm_lm.Residuals.Standardized.*subj_x)
% title('Single-mean model'); xlabel('Subject'); ylabel('Residuals');
% sm_lm.ModelCriterion.AIC

% fixed-effects model (not generalizable to population)
ffx_lm = fitlm(subj_x,y,'Intercept',false);
figure(fi+4);
boxplot(ffx_lm.Residuals.Standardized.*subj_x)
title('Fixed-effects model'); xlabel('Subject'); ylabel('Residuals');
ffx_lm.ModelCriterion.AIC

% mixed-effects model
mfx_lm = fitlmematrix(ones(N,1), y, ones(N,1), categorical(subj), 'FitMethod','REML')
% figure(fi+5);
% boxplot(mfx_lm.Residuals.Raw.*subj_x)
% title('Mixed-effects model'); xlabel('Subject'); ylabel('Residuals');
mfx_lm.ModelCriterion.AIC
corr(mfx_lm.randomEffects+mfx_lm.fixedEffects,B) % fits rfx coefficients with ffx offset
% figure(fi+6);plot(mfx_lm.randomEffects+mfx_lm.fixedEffects,B,'o')
[mfx_lm.fixedEffects, sm_lm.Coefficients.Estimate] % same as intercept of single-mean (when balanced)
[~,~,stats] = covarianceParameters(mfx_lm);
[ffx_lm.RMSE, stats{2}{1,3}] % same rfx std as RMSE of fixed-effects model
[std(sm_lm.Residuals.Raw), stats{1}{1,5}] % similar rfx intercept to std of single-mean residuals
std(y)
return
%% block design with repeated measures
% the subject's variability is fixed for each condition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; close all; clear
M = 10; % number of subjects
n = 15000; % trials per subject
N = M*n; % total number of trials
K = 4; % number of conditions
fi = 5;

% within condition variability
ws_res = .5*randn(N,1); 
y = ws_res;

% subjects
% subj = repmat([1:M]',N/M,1); % number of trials equal among subjs
subj = randi([1,M],N,1); % number of trials unequal among subjs
subj_x = dummyvar(subj); 
b = abs(randn(M,1)); % between-subject variability
bs_res = sum((subj_x.*b').*randn(N,M),2);
B = randn(M,1); % subject means
y = y + subj_x*B+bs_res;
figure(fi+1);
boxplot(y,subj)
title('Response'); xlabel('Subjects'); ylabel('Value');

% conditions
% cond = repmat([1:M]',N/M,1); % number of trials equal among conditions
cond = randi([1,K],N,1); % number of trials unequal among conditions
cond_x = dummyvar(cond); 
c = abs(randn(K,1)); % between-condition variability
cs_res = sum((cond_x.*c').*randn(N,K),2);
C = 5*randn(K,1); % condition means
y = y + cond_x*C+cs_res;
figure(fi+2);
boxplot(y,cond)
title('Response'); xlabel('Condition'); ylabel('Value');

figure(fi+3);
boxplot(y,{cond,subj})
title('Response'); xlabel('Condition x Subjects'); ylabel('Value');

%% single-mean model (generalizable to population of trials)
% ignores between-subject and between-condition variability
sm_lm = fitlm(ones(size(y)),y,'Intercept',false)
figure(fi+4);
boxplot(sm_lm.Residuals.Raw,{cond,subj})
title('Single-mean model'); xlabel('Condition x Subject'); ylabel('Residuals');
sm_lm.ModelCriterion.AIC


%% many means model (generalizable to populations of trials, but ignores between-subject variability)
sm_lm = fitlm(cond_x,y,'Intercept',false)
figure(fi+5);
boxplot(sm_lm.Residuals.Raw,{cond,subj})
title('Many-mean model'); xlabel('Condition x Subject'); ylabel('Residuals');
sm_lm.ModelCriterion.AIC

%% fixed-effects model (not generalizable)
S = [];
for i = 1:N
	s = [];
	for j = 1:K
		ij = cond_x(i,j);
		if ij == 0
			s = [s, zeros(size(subj_x(i,:)))];
		elseif ij == 1
			s = [s, subj_x(i,:)];
		end
	end
	S = [S;s];
end

ffx_lm = fitlm([cond_x,subj_x],y,'Intercept',false)
figure(fi+6);
ffx_lm.ModelCriterion.AIC
boxplot(ffx_lm.Residuals.Raw,{cond,subj})
title('Fixed-effects model'); xlabel('Condition x Subject'); ylabel('Residuals');

%% mixed-effects model
Helmert_contrast = [1 -1 -1 -1; 1 1 -1 -1; 1 0 2 -1; 1 0 0 3];
% rfx_lm = fitlmematrix(repmat([ones(K,1),[zeros(1,K-1); eye(K-1)]],N/K,1), y, {ones(N,1),ones(N,1)}, {categorical(cond),categorical(subj)}, 'FitMethod','REML');
rfx_lm = fitlmematrix(repmat(eye(K),N/K,1), y, {ones(N,1),ones(N,1)}, {categorical(cond),categorical(subj)}, 'FitMethod','REML');
% rfx_lm = fitlmematrix(ones(N,1), y, {ones(N,1),ones(N,1)}, {categorical(cond),categorical(subj)}, 'FitMethod','REML');

% rfx_lm = fitlmematrix(repmat(Helmert_contrast,N/K,1), y, {ones(N,1),ones(N,1)}, {categorical(cond),categorical(subj)}, 'FitMethod','REML');

figure(fi+7);
boxplot(rfx_lm.Residuals.Raw,{cond,subj})
title('Random-effects model'); xlabel('Subject'); ylabel('Residuals');
rfx_lm.ModelCriterion.AIC
% plot(rfx_lm.Fitted,rfx_lm.Residuals.Standardized,'o')
% rfx_lm.fixedEffects
% rfx_lm.randomEffects
