% health_forecast
% Matthieu Komorowski 2015
% This function computes 100 Monte-Carlo simulations of a 5-day health forecast and displays the results.


% Initialization of the variables
rand('seed', 1);
twea=[0.9 0.5 ; 0.1 0.5];  % 2x2 transition matrix
rec=zeros(5,100);  % array where the results are stored
 
for s=1:100  % 100 repetitions
    S=1; %initial state (Healthy)
    
for i=1:5  % 5 days in the future (5 steps)
    
p=rand();  %random value between 0 and 1
 
if S==1
if p<twea(2,1)  %rule for transitioning to state 2
S=2;
end
 
elseif S==2;
if p<twea(1,2) %rule for transitioning to state 1
S=1;  
end
end
 
rec(i,s)=S;  %record current state
 
end
 
end
 
%displays results in histogram
histogram(rec(end,:));
title('Estimated health in 5 days (10,000 instances)');
set(gca,'Xtick',1:2,'XTickLabel',{'Heathy','Ill'})
ylabel('Count')
 
%displays mean and standard deviation of state=Healthy
mean(rec(end,:)==1)
std(rec(end,:)==1)
