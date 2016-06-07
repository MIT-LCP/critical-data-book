function normalized_matrix=normalize_matrix(matrix_input)

for i=1:size(matrix_input,2)    
    max_feature=max(matrix_input(:,i));
    min_feature=min(matrix_input(:,i));
    for ii=1:size(matrix_input,1)
        normalized_matrix(ii,i)=(matrix_input(ii,i)-min_feature)/(max_feature-min_feature);
    end   
end
