%crosscorrelation to substract trigger from animaltrack
% on standby right now as usinig ccrosscorrelation does not seem to work to erase 'trigger noise'

clear
clc

dataname1='*T1_Trigger*.WAV';
dataname_data='*T1_Trigger*p5.mat';
gg_data=dir(dataname_data);
gg=dir(dataname1);
info = audioinfo(gg(1).name); %gets info esp. the length of audiotrack

load(gg_data(1).name);

samplerate=info.SampleRate;

bin_size=samplerate/100; %How large the bin is
part_pieces=10; %THe number of parts the track is divided into 10->plots a tenth of the track
part_part=samplerate*2; % the part of the part the tricks will be shifted on (the nr of seconds the part part is long)
% bin_nr=floor(part_part/bin_step)*2; %The number of bins used (the number of times the bins can shift in the part part)

answer_part='a'; %sets answer to false in order to enter the Loop

all_tda=[]; %stores all tda occurences in one matrix
all_tdt=[];
%pools all animal and trigger part-occurences, respectively
for pooler=1:length(timedata_at.tda)
    all_tda=horzcat(all_tda,[(timedata_at(1).tda{pooler}(:,2))';(timedata_at(1).tda{pooler}(:,4))'] ); %beginning 1.row , ending=2.row
    all_tdt=horzcat(all_tdt,[(timedata_at(1).tdt{pooler}(:,2))';(timedata_at(1).tdt{pooler}(:,4))'] ); %beginning 1.row , ending=2.row
end

for part=1:part_pieces
    
    if answer_part~='q'
        
        if part*ceil(info(1).TotalSamples/part_pieces)<=info(1).TotalSamples %to avoid stepping outside matrix
            [data11,samplerate] = audioread(gg(1).name,[part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+1,part*ceil(info(1).TotalSamples/part_pieces)]);
            delay=part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces);
        elseif part*ceil(info(1).TotalSamples/part_pieces)>info(1).TotalSamples
            [data11,samplerate] = audioread(gg(1).name,[part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+1,(info(1).TotalSamples)]);
            delay=part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces);
        end
        %declares which one is animal which one is trigger
        if timedata_at.answer_at(1)=='q'
            andata=data11(1:end,1);
            trdata=data11(1:end,2);
        elseif timedata_at.answer_at(1)=='a'
            andata=data11(1:end,2);
            trdata=data11(1:end,1);
        end
        
        %         if part*ceil(info(1).TotalSamples/1)<=info(1).TotalSamples %to avoid stepping outside matrix
        %             [data11,samplerate] = audioread(gg(1).name,[part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+1,part*ceil(info(1).TotalSamples/part_pieces)]);
        %             delay=part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces);
        %         elseif part*ceil(info(1).TotalSamples/part_pieces)>info(1).TotalSamples
        %             [data11,samplerate] = audioread(gg(1).name,[part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+1,(info(1).TotalSamples)]);
        %             delay=part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces);
        %         end
        
        subplot(2,1,1)
        hold on
        %         plot(timedata_at(1).tda{part,1}(:,2)',timedata_at(1).tda{part,1}(:,1)','kx',timedata_at(1).tda{part,1}(:,4)',timedata_at(1).tda{part,1}(:,3)','rx')
        plot(part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+(1:length(data11)),andata(:,1))
        
        editor_title=sprintf('This is part [%d/%d]',part,part_pieces);
        title(editor_title,'Fontsize',10)
        
        subplot(2,1,2)
        hold on
        plot(part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+(1:length(data11)),trdata(:,1))
        %         plot(timedata_at(1).tdt{part,1}(:,2)',timedata_at(1).tdt{part,1}(:,1)','kx',timedata_at(1).tdt{part,1}(:,4)',timedata_at(1).tdt{part,1}(:,3)','rx')
        editor_title2=sprintf('Dont know how many to delete cause they´re all in one merry spot? Simply treat them as one point\n the program will delete all except for the first and last\n if you want more than 8(4-x pairs)  ''q''=10  ''w''=12  ''e''=14 ''r''=16 ''t''=18, you will get no 20+, thats just overkill');
        title(editor_title2,'Fontsize',10)
        set(gcf,'units','centimeters','position',[1 0.5 33 17.5])
        the_one_title=sprintf('Is this a suitable part Yes=[q], No=[a]');
        title(the_one_title)
        waitforbuttonpress;
        answer_part = get(gcf,'CurrentCharacter'); %whether suitable part or not
        the_part=part;
        close(gcf)
    end
    
end

if the_part*ceil(info(1).TotalSamples/part_pieces)<=info(1).TotalSamples %to avoid stepping outside matrix
    partsize=([the_part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+1,the_part*ceil(info(1).TotalSamples/part_pieces)]);
elseif the_part*ceil(info(1).TotalSamples/part_pieces)>info(1).TotalSamples
    partsize=([the_part*ceil(info(1).TotalSamples/part_pieces)-ceil(info(1).TotalSamples/part_pieces)+1,(info(1).TotalSamples)]);
end
bin_max_vals=1:bin_size:floor(partsize(1,2)/bin_size)*bin_size-part_part-partsize(1,1); %rounds so that the bin_span fits the part length,chop off part_part at beginning and end so that tthe bins can be shifted for one part_part

bin_tda=nan(1,length(bin_max_vals)-1);
rel_tda=all_tda(1,all_tda(1,:)-partsize(1,1)>0)-partsize(1,1); %the relevant tda,only the onsets are looked at,(speeds up, hopefully)
%calculate bin values for animaltrack
for tda_counter=1:length(bin_max_vals)-1
    bin_tda(tda_counter)=length(find((rel_tda>bin_max_vals(tda_counter))&(rel_tda<bin_max_vals(tda_counter+1))));
end
bin_tda_val=conv(bin_tda,gaussmf(-100:0.05:100,[10 0]) ); %gauss mf (range)[sd centerpoint]
% plot(bin_tda_val)   to check
% plot(gaussmf(-100:0.05:100,[3 0]))


bin_tdt=nan(1,length(bin_max_vals)-1);
rel_tdt=all_tdt(1,all_tdt(1,:)-partsize(1,1)>0)-partsize(1,1); %the relevant tda,only the onsets are looked at,(speeds up, hopefully)
%calculate bin values for animaltrack

for tdt_counter=1:length(bin_max_vals)-1
    bin_tdt(tdt_counter)=length(find((rel_tdt>bin_max_vals(tdt_counter))&(rel_tdt<bin_max_vals(tdt_counter+1))));
end
bin_tdt_val=conv(bin_tdt,gaussmf(-100:0.05:100,[10 0]) ); %gauss mf (range)[sd centerpoint]

[ta_corr,lags]=xcorr(bin_tda_val,bin_tdt_val);
[~,iii] = max(abs(ta_corr));
lagdiff=lags(iii); %'diff in samplerate'
timediff = lags(iii)/samplerate; %diff in seconds
plot(lags,ta_corr)

corr_data.bin_size=bin_size;
corr_data.timediff=timediff;
corr_data.ta_corr=ta_corr;
% savename=[gg(1).name(1:end-4),'corr_data'];
% save(savename,'corr_data')

andata2=andata(1:end-abs(lagdiff)+1);  %abs is used, as diff  can be + or -
trdata2=trdata(abs(lagdiff):end);

ta2 = ta_corr(lags>0);
lags2 = lags(lags>0);
% 
% [~,dl] = findpeaks(Rmm,lags,'MinPeakHeight',0.22);
% mtNew = filter(1,[1 zeros(1,dl-1) mean_antr_ratio],andata); %filter 

% 
andata3=andata(abs(lagdiff):end);
trdata3=trdata(1:end-abs(lagdiff)+1);

sample=[rel_tdt(1):rel_tdt(1)+300]; %get a sample of a call part
mean_antr_ratio=mean(andata2(sample)./trdata2(sample)); %get ratio of animal and trigger track using sample
an_tr_data=andata2-trdata2*mean_antr_ratio;

mean_antr_ratio2=mean(andata3(sample)./trdata3(sample)); %get ratio of animal and trigger track
an_tr_data2=andata3-trdata3*mean_antr_ratio2;

%% to check
subplot(4,1,1)
plot(andata(1000000:2000000))
title('animal track')
subplot(4,1,2)
plot(trdata(1000000:lagdiff:2000000))
title('trigger track')
subplot(4,1,3)
plot(an_tr_data(1000000:2000000))
title('animal-trigger track')
subplot(4,1,4)
plot(an_tr_data2(1000000:2000000))
title('animal-trigger track2')


playtrack3=audioplayer(andata_33(3300000:4300000),samplerate);

play(playtrack)
play(playtrack2)
play(playtrack3)

% % Define Adaptive Filter Parameters
% filterLength = 32;
% weights = zeros(1,filterLength);
% step_size = 0.004;
% % Initialize Filter's Operational inputs
% output = zeros(1,length(andata2));
% err = zeros(1,length(andata2));
% input = zeros(1,filterLength);
% % For Loop to run through the data and filter out noise
% for n = 1: length(andata2),
%       %Get input vector to filter
%       for k= 1:filterLength
%           if ((n-k)>0)
%               input(k) = trdata2(n-k+1);
%           end
%       end
%       output(n) = weights * input';  %Output of Adaptive Filter
%       err(n)  = andata(n) - output(n); %Error Computation
%       weights = weights + step_size * err(n) * input; %Weights Updating 
%   end
% andata_33 = err;
% 


%another attempt at filtering 
FilterLength=32;
signal_in=andata2;
desired=trdata2;
SignalLength=length(andata2);
for n = 1:SignalLength
  % Compute the output sample using convolution:
  signal_out(n,ch) = weights' * signal_in(n:n+FilterLength-1,ch);
  % Update the filter coefficients:
  err(n,ch) = desired(n,ch) - signal_out(n,ch) ;
  weights = weights + mu*err(n,ch)*signal_in(n:n+FilterLength-1,ch);
end

% % where SignalLength is the length of the input signal, 
% % FilterLength is the filter length, and mu is the adaptation step size.
% 
% % Convolution
% % The convolution for the filter is performed in:
% signal_out(n,ch) = weights' * signal_in(n:n+FilterLength-1,ch); 
% %  What Is Convolution?
% % Calculation of error
% % The error is the difference between the desired signal and the output signal:
% err(n,ch) = desired(n,ch) - signal_out(n,ch);
% Adaptation
% % The new value of the filter weights is the old value of the filter weights plus a correction factor that is based on the error signal, the distorted signal, and the adaptation step size:
% weights = weights + mu*err(n,ch)*signal_in(n:n+FilterLength-1,ch);
% 

