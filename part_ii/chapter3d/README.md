# Section 2, Chapter 3

*Note: the following datasets were not committed:*

- aline.mat  
- data_catia_2.mat  
- normalized_data.mat  
- kmeansCrit1W15cluster1.xlsx  
- kmeansCrit1W15cluster2.xlsx  
- kmedoidsCrit1W15cluster1.xlsx  
- kmedoidsCrit1W15cluster2.xlsx  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%  
%                  Plot histograms  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
1) Run script main  
2) All histograms are saved in folder figures  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%  
%                  Plot cluster centers and outliers  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

1. Run script plot_clusters_cs. Description: it will perform kmeans and kmedoids and produce excel files for each cluster in each method  
2. E.g. for kmeans: Copy the time series in cluster 1 (‘KM_c1’) to ’kmeansCrit1W15cluster1’ in position 2,B. Move column AB to A. This column A tells if the time series is outlier (case 1) or not (case 0). The last line gives the cluster centers. Make a straight line scatter from line 1 to the end without first column. Mark last time series as black (center), and time series with value 1 in column 1 as red. do the same for cluster 2 (‘KM_c2’) to ‘kmeansCrit1W15cluster2’  and for Kmedoids.   

