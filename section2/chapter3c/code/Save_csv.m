T1 = array2table(IAC_out,...
    'VariableNames',{'output'});
IAC=[IAC ,T1];
writetable(IAC,'IAC.csv')

T2 = array2table(NON_IAC_out,...
    'VariableNames',{'output'});
NON_IAC=[NON_IAC ,T2];
writetable(NON_IAC,'NON_IAC.csv')
