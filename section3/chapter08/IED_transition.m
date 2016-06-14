
% IEDtransition
% Matthieu Komorowski 2015
% This function will compute and display the proportion of patients in each state, following the transition matrix in the intervention group.


I=100; % number of patients intubated
E=0;   % number of patients extubated
D=0;   % number of patients dead
% define transition matrices
tctl=[0.8280 0.0280 0; 0.1500 0.9600 0;0.0220 0.0120 1.0000];
tint=[0.8620 0.0088 0;0.1200 0.9820 0;0.0180 0.0092 1.0000];


for i=1:5  %number of iterations
    
    I2=I*tint(1,1)+E*tint(1,2);  % new value for number of patients intubated
    E2=I*tint(2,1)+E*tint(2,2);  % new value for number of patients extubated
    D2=I*tint(3,1)+E*tint(3,2)+D;% new value for number of patients dead
    I=I2;E=E2;D=D2;              % old values are replaced with new values
    [I E D]                      % displays values at each step
end

