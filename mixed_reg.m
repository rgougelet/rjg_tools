% %% linear, non-grouped, no intercept
% clear; close all; clc
% y = [1 0 -1 0]';
% x = [1 2 -1 0]';
% x = zscore(x)
% x_inv = pinv(x);
% b = x_inv*y
% yhat = x*b;
% res = mean((yhat-y).^2)
% figure; plot(x,y, 'o','LineWidth',3)
% hold on;
% plot(x,yhat, 'LineWidth',2)
% axis([-2 2 -2 2])
% plot([mean(x(1:2)), mean(x(3:4))],[mean(y(1:2)), mean(y(3:4))],'-', 'LineWidth',2)

% random effects
clear; clc; close all
y = [-2 -1 0 1 0 2]';
x = [ones(size(y)), [-2 -1 0 2 3 1]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,2),y, 'o','LineWidth',3)
hold on;
plot(x(:,2),yhat, 'LineWidth',2)
axis(3*[-1 1 -1 1])
% fixed effects
plot([mean(x(1:3,2)), mean(x(4:end,2))],[mean(y(1:3)), mean(y(4:end))],'-', 'LineWidth',2)

x = [[-2 -1 0 2 3 1]']
tbl = dataset()
tbl.x = x;
tbl.y = y;
tbl.s = categorical({'1' '1' '1' '2' '2' '2'}');
lme = fitlme(tbl, 'y~1+x+(x|s)', 'fitmethod','REML')
% B = randomEffects(lme)
% B = fixedEffects(lme)
% F = fitted(lme)
% lme.predict([1 -2], [0 0])
% designMatrix(lme,'Random')
% xnew = [1 -1; 1 0; 1 1];
% ynew = xnew*B
% plot(xnew(:,2),ynew)
% plot(-2:0.1:2,F(-2:0.1:2))
%% linear, both dummy variables, no intercept
clear; clc
y = [1 0 -1 0]';
x = [[1 2 -1 0]', [1 1 0 0]', [0 0 1 1]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,1), y,'o','LineWidth',3)
hold on;
plot(x(:,1),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%% linear, one dummy variable, with intercept
clear; clc
y = [1 0 -1 0]';
x = [[1 1 1 1]', [1 2 -1 0]', [1 1 0 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,2),y, 'o','LineWidth',3)
hold on;
plot(x(:,2),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%%  linear, both dummy variables, with intercept
clear; clc
y = [1 0 -1 0]';
x = [[1 1 1 1]', [1 2 -1 0]', [1 1 0 0]', [0 0 1 1]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,2),y, 'o','LineWidth',3)
hold on;
plot(x(:,2),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%%  interaction, no dummy variables, no intercept
clear; clc
y = [1 0 -1 0]';
x = [[1 2 -1 0]', [1 2 0 0]', [0 0 -1 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,1),y, 'o','LineWidth',3)
hold on;
plot(x(:,1),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%%  interaction, no dummy variables, with intercept
clear; clc
y = [1 0 -1 0]';
x = [[1 1 1 1]', [1 2 -1 0]', [1 2 0 0]', [0 0 -1 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,2),y, 'o','LineWidth',3)
hold on;
plot(x(:,2),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%%  interaction, with dummy variables, with intercept
clear; clc
y = [1 1 -1 0]';
x = [[1 1 1 1]', [1 2 -1 0]', [1 1 0 0]', [0 0 1 1]', [1 2 0 0]', [0 0 -1 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,2),y, 'o','LineWidth',3)
hold on;
plot(x(:,2),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%%  interaction, with dummy variables, no intercept
clear; clc
y = [1 1 -1 0]';
x = [[1 2 -1 0]', [1 1 0 0]', [0 0 1 1]', [1 2 0 0]', [0 0 -1 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,1),y, 'o','LineWidth',3)
hold on;
plot(x(:,1),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%% fixed effect
clear; clc
y = [1 0 -1 0]';
x = [[1 1 1 1]', [1 1 0 0]', [0 0 1 1]', [0 1 0 0]', [0 0 -1 0]']
% x = zscore(x,1)
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(1:2,4),y(1:2), 'bo','LineWidth',3); hold on;
plot(x(3:4,5),y(3:4), 'bo','LineWidth',3)
hold on;
plot(x(1:2,4),yhat(1:2),'r+', 'LineWidth',2)
plot(x(3:4,5),yhat(3:4),'r+', 'LineWidth',2)
axis([-2 2 -2 2])

%% random effect
clear; clc
y = [1 0 -1 0]';
x = [[1 1 1 1]', [0 1 -1 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,2),y, 'o','LineWidth',3)
hold on;
plot(x(:,2),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

%% mixed effect
clear; clc
y = [1 0 -1 0]';
x = [[1 1 1 1]', [1 1 0 0]', [0 0 1 1]', [0 1 0 0]', [0 0 -1 0]', [1 1 1 1]', [0 1 -1 0]']
x_inv = pinv(x);
b = x_inv*y
yhat = x*b;
res = mean((yhat-y).^2)
figure; plot(x(:,end),y, 'o','LineWidth',3)
hold on;
plot(x(:,end),yhat,'+', 'LineWidth',2)
axis([-2 2 -2 2])

B01 = b(1)+b(6)
B02 = b(2)+b(3)+b(end)

yyhat = [1 1 1 1]'.*B01 + [0 1 -1 0]'.*B02
figure; plot(x(:,end),y, 'o','LineWidth',3)
hold on;
plot([0 1 -1 0],yyhat, 'o')
axis([-2 2 -2 2])




