function [DATA_in_M,orig_data_in] = create_missingness_datasets(data_in,perc,rem_col,type)
% This file create the missingness in the datasets depending if the
% dataset is 'IAC' or 'NON_IAC'
switch type
    case 'multi'
        % Creates missingness for the different percentages
        [DATA_in_M] = create_missing_special(data_in,perc);
        orig_data_in =data_in;
    case 'univar'
        [DATA_in_M] = create_missing_special_univariate(data_in,perc,rem_col);
        orig_data_in =data_in;
    otherwise
        error('myApp:argChk1', 'WRONG type of missigness selected, please try: univar or multi')
end




