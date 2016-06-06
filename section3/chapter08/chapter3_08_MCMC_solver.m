% MCMC_solver
% Matthieu Komorowski 2015
% This function will compute 10.000 simulations for both the control and intervention group, and compute the distribution of ventilator-free days.


 
%  ventilation free days for the control group
 
rec=zeros(29,10000);   %array to store results
rand('seed', 1);

for s=1:10000  %10000 samples simulated
    S=1;  %initial state (Intubated)
    
for i=1:29  % 29 steps
    
p=rand();  %random value between 0 and 1
 
if S==1
if p<tctl(2,1)
    S=2; %extubation
elseif p>1-tctl(3,1)
    S=3;%death
end
 
elseif S==2;
if p<tctl(1,2)
S=1;  %reintubation
elseif p>1-tctl(3,2)
S=3; %death
end
end
 
rec(i,s)=S;  % record current state
 
end
 
end
 
rec=sum(rec==2);  %number of ventilator-free days for each of the 10,000 samples
% displays statistics of the variable of interest (ventilator-free days)
[mean(rec) median(rec) std(rec) iqr(rec)]
%plots the distribution of ventilator-free days
subplot(1,2,2)
histogram(rec)
axis([-0.5 28.5 0 1500])
title('Control group')
xlabel('Days')
ylabel('Count')
axis square
 
 
%  ventilation free days for the intervention group
 
rec=zeros(29,10000);
 
for s=1:10000
    S=1;
for i=1:29
    
p=rand();
 
if S==1
if p<tint(2,1)
    S=2; %extubation
elseif p>1-tint(3,1)
    S=3;%death
end
 
elseif S==2;
if p<tint(1,2)
S=1;  %reintubation
elseif p>1-tint(3,2)
S=3; %death
end
end
 
rec(i,s)=S;
 
end
 
end
 
rec=sum(rec==2); %number of ventilator-free days for each of the 10000 samples
% displays statistics of the variable of interest (ventilator-free days)
[mean(rec) median(rec) std(rec) iqr(rec)]
%plots the distribution of ventilator-free days
subplot(1,2,1)
histogram(rec)
axis([-0.5 28.5 0 1500])
title('Intervention group')
xlabel('Days')
ylabel('Count')
axis square
