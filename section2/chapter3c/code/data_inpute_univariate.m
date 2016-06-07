function [ data_in_new ] = data_inpute_univariate(inp_case,data_in,data_out,separate,constraint)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Separate data from each class
if separate == 0
   indx = true(length(data_in{:,1}),1); 
    switch inp_case
        case 'remove'
            % Do nothing, the removel will be done during the regression!
            data_in_new =  data_in;            
        case 'mean'
            inpute_func=@nanmean;
            [data_in_new] = inpute_value(inpute_func,data_in,constraint,indx);
        case 'median'
            inpute_func=@nanmedian;
            [data_in_new] = inpute_value(inpute_func,data_in,constraint,indx);   
        case 'linear'
            type='linear';
            [data_in_new] = inpute_regression(type,data_in,constraint,indx);
        case 'randlinear'
            type='randlinear';
            [data_in_new] = inpute_regression(type,data_in,constraint,indx);
        case 'quadratic'
            type='quadratic';
            [data_in_new] = inpute_regression(type,data_in,constraint,indx);
        case 'hotdeck'
            data_in_new = array2table(hot_deck_input(data_in));
        case 'knn'
            k=1;
            [aux_data] = knnimpute(data_in{:,:},k);    
            [data_in_new] = array2table(aux_data);
        otherwise
            error('myApp:argChk1', 'Wrong inpute method stated, for data not separated by classes')
    end
elseif separate == 1
    [indx0,indx1] = index_by_class(data_out);
    indx0=logical(indx0);
    indx1=logical(indx1);
    switch inp_case
        case 'remove'
            % Do nothing, the removel will be done during the regression!
            data_in_new =  data_in;
        case 'mean'
            inpute_func=@nanmean;
            [data_in_new] = inpute_value(inpute_func,data_in,constraint,indx0);
            [data_in_new] = inpute_value(inpute_func,data_in_new,constraint,indx1);
        case 'median'
            inpute_func=@nanmedian;
            [data_in_new] = inpute_value(inpute_func,data_in,constraint,indx0);
            [data_in_new] = inpute_value(inpute_func,data_in_new,constraint,indx1); 
        case 'randomsamp'
            [data_in_new] = random_sampling(data_in,indx0);
            [data_in_new] = random_sampling(data_in_new,indx1);
        case 'linear'
            type='linear';
            [data_in_new] = inpute_regression(type,data_in,constraint,indx0);
            [data_in_new] = inpute_regression(type,data_in_new,constraint,indx1);   
        case 'randlinear'
            type='randlinear';
            [data_in_new] = inpute_regression(type,data_in,constraint,indx0);
            [data_in_new] = inpute_regression(type,data_in_new,constraint,indx1);
        case 'quadratic'
            type='quadratic';
            [data_in_new] = inpute_regression(type,data_in,constraint,indx0);
            [data_in_new] = inpute_regression(type,data_in_new,constraint,indx1);
        case 'hotdeck'
            aux_total = zeros(size(data_in,1),size(data_in,2));
            [aux_data0] = hot_deck_input(data_in(indx0,:));
            aux_total(indx0,:)=aux_data0;
            [aux_data1] = hot_deck_input(data_in(indx1,:));
            aux_total(indx1,:)=aux_data1;            
            data_in_new= array2table(aux_total);
        case 'knn'
            k=1;
            aux_total = zeros(size(data_in,1),size(data_in,2));
            [aux_data0] = knnimpute(data_in{indx0,:},k);
            aux_total(indx0,:)=aux_data0;
            [aux_data1] = knnimpute(data_in{indx1,:},k);
            aux_total(indx1,:)=aux_data1;
            [data_in_new] = array2table(aux_total);
        otherwise
            error('myApp:argChk2', 'Wrong inpute method stated, for data separated by classes')
    end
end
