function plot_histograms_categorical(alinecohortdatajune15, pathh, ftsize)

%% plot demographic
% Demographic: Admission age, gender, race, daytime admission (7am to 7pm), day of admission
% and service unit (medical or surgical ICU), and admission Sequential Organ Failure Assessment
% (SOFA) score.

categoricall_IAC(:,1)=alinecohortdatajune15.GENDER_NUM(alinecohortdatajune15.ALINE_FLG==1);
categoricall_IAC(:,2)=alinecohortdatajune15.SERVICE_NUM(alinecohortdatajune15.ALINE_FLG==1);
categoricall_IAC(:,3)=alinecohortdatajune15.DAY_ICU_INTIME_NUM(alinecohortdatajune15.ALINE_FLG==1);
categoricall_IAC(:,4)=alinecohortdatajune15.ALINE_TIME_DAY(alinecohortdatajune15.ALINE_FLG==1);

categoricall_NON_IAC(:,1)=alinecohortdatajune15.GENDER_NUM(alinecohortdatajune15.ALINE_FLG==0);
categoricall_NON_IAC(:,2)=alinecohortdatajune15.SERVICE_NUM(alinecohortdatajune15.ALINE_FLG==0);
categoricall_NON_IAC(:,3)=alinecohortdatajune15.DAY_ICU_INTIME_NUM(alinecohortdatajune15.ALINE_FLG==0);
categoricall_NON_IAC(:,4)=alinecohortdatajune15.ALINE_TIME_DAY(alinecohortdatajune15.ALINE_FLG==0);


for i=1:size(categoricall_IAC,2)
    idx_IAC=isnan(categoricall_IAC(:,i));
    aux_IAC=categoricall_IAC(:,i);
    aux_IAC(idx_IAC,:)=[];
    
    idx_NON_IAC=isnan(categoricall_NON_IAC(:,i));
    aux_NON_IAC=categoricall_NON_IAC(:,i);
    aux_NON_IAC(idx_NON_IAC,:)=[];
    
    figure;
    [counts_IAC,centers_IAC]=hist(aux_IAC,length(unique(aux_IAC)));
    [counts_NON_IAC,centers_NON_IAC]=hist(aux_NON_IAC,length(unique(aux_NON_IAC)));
    
    if length(counts_IAC)~=length(counts_NON_IAC) % so existe IAC
        bh=bar(centers_IAC',[counts_IAC']);
        set(bh(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0], 'LineWidth', 2);
    else
        bh=bar(centers_NON_IAC',[counts_IAC' counts_NON_IAC']);
        set(bh(1),'FaceColor',[0 0 0],'EdgeColor',[0 0 0], 'LineWidth', 2);
        set(bh(2),'FaceColor',[0 0.5 0.5],'EdgeColor',[0 0.5 0.5], 'LineWidth', 2);      
    end
    
    ylabel('Frequency');
    h = get(gca, 'ylabel');
    set(h, 'FontSize', ftsize);
    set(gca, 'FontSize', ftsize);
    hold on
    
    if i==1
        gender = {'Male';'Female'};
        set(gca,'XTick', centers_IAC,'XTickLabel',gender);
        name='gender';
    elseif i==2
        unit = {'MICU';'SICU'};
        set(gca,'XTick', centers_IAC,'XTickLabel',unit);
        name='unit';
    elseif i==3
        months = {'Sunday';'Monday';'Tuesday';'Wednesday';'Thursday';'Friday';'Saturday'};
        set(gca,'XTick', centers_IAC, 'XTickLabel',months)
        name='months';
    elseif i==4
        xlabel('Days');
        name='aline_time_day';
    elseif i==5

    end
    
    legend('IAC', 'Non-IAC', 'Location', 'Best');

    print_name=strcat(pathh, name, '.eps');
    print('-depsc', print_name)
end
