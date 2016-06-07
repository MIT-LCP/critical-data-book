function plot_univariate_lr(var,IAC, NON_IAC, IAC_out, NON_IAC_out)

% plot univariate logistic regression 

figure;

scatter(IAC.(var),IAC_out, [], [0 0.5 0.5])
xx_IAC = linspace(0,max(IAC.(var)));
hold on
scatter(NON_IAC.(var),NON_IAC_out,[], [0 0 0])
xx_NON = linspace(0,max(NON_IAC.(var)));

legend('IAC','Non-IAC')

hold on
b = glmfit(IAC.(var),IAC_out,'binomial');
yfit = glmval(b,xx_IAC,'logit');
plot(IAC.(var),IAC_out,'o',xx_IAC,yfit,'-','Color',[0 0.5 0.5])

hold on
b = glmfit(NON_IAC.(var),NON_IAC_out,'binomial');
yfit = glmval(b,xx_NON,'logit');
plot(NON_IAC.(var),NON_IAC_out,'o',xx_NON,yfit,'-', 'Color', [0 0 0])

var = strtok(var, '_');
xlabel(var);
ylabel('output');