%% test bootstrap regression
clear
x1 = randn(1,10000);
x2 = randn(1,10000);
x = [x1;x2]
y = 2*x1 + 3*x2 + 0.5.*x1.*x2 + randn(1,10000);

bhats = reg_boot(x',y',10000)
std(bhats)
fitlm(x',y')

%% simple design matrix. we're testing two blood pressure medications 
% in 10 individuals
% drug 1 drops baseline systolic blood pressure
% by 1, whereas drug 2 drops it by 5.

o1 = experiment([5 5]);
o1.b = [1 5]
% the first approach is to use a dependent samples t-test, subtracting
% one medication's effect from the other within each subject
% the second approach is to use an independent samples t-test,

% treating the sessions 1 and 2 as independent, this is an
% incorrect assumption since measurements are taken within
% the same individuals between sessions.

%% the independent samples t-test appears more sensitive. the reason
% is that we are generating data that are actually independent.
% we need to introduce dependency.

d_dep = cat(1,d,d);
x1 = d_dep(:,1);
x2 = d_dep(:,2);
w1 = .1*randn(size(x1)).*x1;
w2 = .5*randn(size(x2)).*x2;
bw = .2*randn(size(x1));
y1 = 0*x1 + w1;
y2 = 0*x2 + w2;
y_dep = y1 + y2 + bw;
y_dep = cat(1,y,y_dep);
[~, p_dep, ~, stats] = ttest(y_dep(x1)-y_dep(x2))

% behold the greater power of the dependent-samples t-test. assume the opposite.
% what if we tested two medications in 20 patients, like above. but used
% the independent-samples t-test?


%% why not choose dependent samples? answer: what if a certain subset
% of our patient pool had a genetic anomaly that interferes with the drugs,
% rendering them ineffective (or we could imagine much worse)? in other words,
% they had different underlying models?
d_sub = cat(1,d,d);
x1 = d_dep(:,1);
x2 = d_dep(:,2);
w1 = .1*randn(n,1).*d(:,1);
w2 = .1*randn(n,1).*d(:,2);
bw = 0.2*randn(n,1);
y1 = 0*x1 + w1;
y2 = 0*x2 + w2;
y_dep = y1 + y2 + bw;
y_dep = cat(1,y,y_dep);
[~, p, ~, stats] = ttest(y_dep(x1)-y_dep(x2))

% the ultimate question is what are we interested in?


%% if we examine d we see that it has redundant information, in a way
% we only need one column to distinguish the two conditions. this 
% process relates to what's known as the "intercept" concept
% often discussed in regression. using an intercept in the model
% implies that one condition can always be dropped, but only 
% from the design matrix--we still keep all the measurements.
fitlm(x1,y,'Intercept',false) % incorrect

% the problem with this is that we're really only answering the question
% of x1 and ANYthing not x1, rather than comparing two "identical" treatments.
% instead, we replace the 0 with -1 so that the design matrix is "balanced"
% in a sense.

fitlm(x1,y,'Intercept',true)
fitlm(x1-~x1,y,'Intercept',true)
fitlm(x1-~x1,y,'Intercept',false)



%% design matrix with interaction
clear;
n1 = 500;
n2 = 500;
k = 4;
n = n1 + n2;
dd = blkdiag(ones(n1,1),ones(n2,1));
cc = blkdiag(ones(n1/2,1),ones(n2/2,1));
c = repmat(cc,2,1)
d = cat(2,dd,c)
x1 = d(:,1);
x2 = d(:,2);
x3 = d(:,3);
x4 = d(:,4);

w1 = randn(n,1).*d(:,1);
w2 = randn(n,1).*d(:,2);
w3 = randn(n,1).*d(:,3);
w4 = randn(n,1).*d(:,4);

% say we're testing two blood pressure medications
% that work better in combination, i.e. they show
% an "interaction", but imagine the combination 
% shows more varied effect in patients

y11 = 1*x1 + w1 + 1; % drug 1 alone
y12 = 10*x2 + w2 + 10; % drug 1 and 2 together, interaction
y21 = 5*x3 + w3 + 5; % drug 2 alone
y22 = 5*x4 + w4 + 1; % drug 1 and 2 together, interaction
y = y11+y12+y21+y22+5*randn(n,1);

% we should see some troubling results
lm = fitlm(d,y,'Intercept',false)
bhat = lm.Coefficients.Estimate;
res = y-d*bhat;

% if we examine the design matrix, we'll see it does not reflect
% the true design. this design is actually implying that
% the order that the medication is taken does not matter
% instead columns for y12 and y21 are equivalent. if we sort it
% by column, we see how just shuffling the rows shows how
% the matrix gives redundant information. it's easier to see this
% with a smaller version of d
d = [0 1 0 1; 1 0 0 1; 0 1 1 0; 1 0 1 0]
d = sortrows(d, 'descend')
open d

% that the interaction columns are making the design matrix
% linearly dependent. each condition needs its own column.
% also, when only one drug is taken, indicated by y11 and y22,
% we assume they are not taking a double dose. so we relabel.
%%
y1 = 1*x1 + w1 + 1;
y2 = 5*x2 + w2 + 5;
y_int = 10*x3 + w2 + 10;
y = y11+y12+y21+y22+5*randn(n,1);

lm = fitlm(d,y,'Intercept',false)
bhat = lm.Coefficients.Estimate;
res = y-d*bhat;

%% design matrix with interaction
% the results improve here.

clear;
n11 = 500;
n12 = 500;
n21 = 500;
n22 = 500;
k = 4;
n = n11 + n12 + n21 + n22;
dd = blkdiag(ones(n1/2,1),ones(n2/2,1), ones(n3/2,1),ones(n4/2,1));
d = repmat(dd,2,1)
x1 = d(:,1);
x2 = d(:,2);
x3 = d(:,3);
x4 = d(:,4);

w1 = randn(n,1).*d(:,1);
w2 = 5*randn(n,1).*d(:,2);
w3 = randn(n,1).*d(:,3);
w4 = randn(n,1).*d(:,4);

y11 = 1*x1 + w1;
y12 = 2*x2 + w2;
y21 = 20*x3 + w3;
y22 = 20*x4 + w4;
y = y11+y12+y21+y22+5*randn(n,1);

lm = fitlm(d,y,'Intercept',false)
bhat = lm.Coefficients.Estimate;
res = y-d*bhat;