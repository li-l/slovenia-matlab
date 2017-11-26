clear  %Plots the correlation in dependency to the condition
clc
%yes, script could be shortened by pooling all in a big matrix, but its simply
%not worth the time (-_-)'
cond5=load('Data_cond5m_percent.mat');
cond10=load('Data_cond10m_percent.mat');
cond35=load('Data_cond35m_percent.mat');
cond40=load('Data_cond40m_percent.mat');
cond45=load('Data_cond45m_percent.mat');

%Plots percentage of answered trials in dependence on exp condition/distance
percent_answer5=(cond5.all_dist.percent_answer);
percent_answer10=(cond10.all_dist.percent_answer);
percent_answer35=(cond35.all_dist.percent_answer);
percent_answer40=(cond40.all_dist.percent_answer);
percent_answer45=(cond45.all_dist.percent_answer);
hold on
plot(5*ones(1,size(percent_answer5,1)),percent_answer5,'mx','Linewidth',1.2)
plot(10*ones(1,size(percent_answer10,1)),percent_answer10,'bx','Linewidth',1.2)
plot(35*ones(1,size(percent_answer35,1)),percent_answer35,'gx','Linewidth',1.2)
plot(40*ones(1,size(percent_answer40,1)),percent_answer40,'kx','Linewidth',1.2)
plot(45*ones(1,size(percent_answer45,1)),percent_answer45,'yx','Linewidth',1.2)
plot([5 10 35 40 45],[mean(percent_answer5),mean(percent_answer10),mean(percent_answer35),mean(percent_answer40),mean(percent_answer45)],'ro-')
plot([5 10 35 40 45],[median(percent_answer5),median(percent_answer10),median(percent_answer35),median(percent_answer40),median(percent_answer45)],'co-')
xlim([0,50])
xlabel('Distance/condition')
ylabel('Percent of Answers to Trigger')
legend('Answer Percentage 5m','Answer Percentage 10m','Answer Percentage 35m','Answer Percentage 40m','Answer Percentage 45m','Mean Answer Percentage [5m/10m/35m/40m/45m]','Median Answer Percentage [5m/10m/35m/40m/45m]','Location','southoutside')
legend('boxoff')
set(gcf,'units','centimeters','position',[1 0.5 33 17.5],'color',[1 1 1])

corr5=cell2mat(cond5.all_dist.corr);
corr10=cell2mat(cond10.all_dist.corr);
corr35=cell2mat(cond35.all_dist.corr);
corr40=cell2mat(cond40.all_dist.corr);
corr45=cell2mat(cond45.all_dist.corr);




mean5=nan(size(cond5.all_dist.tran,1),1);
for c5=1:size(cond5.all_dist.tran,1)
mean5(c5)=mean(cond5.all_dist.tran{c5});
end

mean10=nan(size(cond10.all_dist.tran,1),1);
for c10=1:size(cond10.all_dist.tran,1)
mean10(c10)=mean(cond10.all_dist.tran{c10});
end

mean35=nan(size(cond35.all_dist.tran,1),1);
for c35=1:size(cond35.all_dist.tran,1)
mean35(c35)=mean(cond35.all_dist.tran{c35});
end


mean40=nan(size(cond40.all_dist.tran,1),1);
for c40=1:size(cond40.all_dist.tran,1)
mean40(c40)=mean(cond40.all_dist.tran{c40});
end


mean45=nan(size(cond45.all_dist.tran,1),1);
for c45=1:size(cond45.all_dist.tran,1)
mean45(c45)=mean(cond45.all_dist.tran{c45});
end



%lets get 3D

all_mean=[mean5;mean10;mean35;mean40;mean45];
all_cond=[5*ones(1,length(corr5))';10*ones(1,length(corr10))';35*ones(1,length(corr35))';40*ones(1,length(corr40))';45*ones(1,length(corr45))'];
all_corr=[corr5;corr10;corr35;corr40;corr45];

% The result is weird if you switch all cor dimensions
rep_all_mean=repmat(all_mean,1,23);
rep_all_cond=repmat(all_cond',23,1);
rep_all_corr=repmat(all_corr',23,1);
surf(rep_all_mean,rep_all_cond,rep_all_corr)
xlabel('Distance[m]')
ylabel('mean animal-trigger difference')
zlabel('corelation')

% jffun
plot3(5*ones(1,length(corr5)),mean5,corr5,'*',10*ones(1,length(corr10)),mean10,corr10,'*',10*ones(1,length(corr10)),mean10,corr10,'*',40*ones(1,length(corr40)),mean40,corr40,'*',45*ones(1,length(corr45)),mean45,corr45,'*')

legend('condition5m','condition10m','condition35m','condition40m','condition45m') %'Location','southoutside'
xlabel('Distance[m]')
set(gca,'XTickLabel',{'','5','10','35','40','45',''})
        set(gcf,'units','centimeters','position',[3 3 30 12],'color',[1 1 1])
ylabel('mean animal-trigger difference')

zlabel('corelation')
surf(all_cond,all_mean,all_corr)
% 
hold on
plot(1*ones(1,length(corr5)),corr5,'ob')
plot(2*ones(1,length(corr10)),corr10,'or')
plot(3*ones(1,length(corr35)),corr35,'og')
plot(4*ones(1,length(corr40)),corr40,'om')
plot(5*ones(1,length(corr45)),corr45,'oc')

legend('condition5m','condition10m','condition35m','condition40m','condition45m') %'Location','southoutside'
xlabel('Distance[m]')
xlim([0,6])
set(gca,'XTickLabel',{'','5','10','35','40','45',''})
        set(gcf,'units','centimeters','position',[3 3 30 12],'color',[1 1 1])
ylabel('correlation')


% all_mean=[mean5;mean10;mean35;mean40;mean45];
% all_cond=[5*ones(1,length(corr5))';10*ones(1,length(corr10))';35*ones(1,length(corr35))';40*ones(1,length(corr40))';45*ones(1,length(corr45))'];
% all_corr=[corr5;corr10;corr35;corr40;corr45];
% plot3(all_cond,all_mean,all_corr,'*')