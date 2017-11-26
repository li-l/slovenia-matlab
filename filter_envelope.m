%Step1
%highpassfilter input=threshold+ data output=edited data
clear
clc
dataname1='*2_ef_Trigger_in_animaltrack_*.WAV'; 
partnr=5;

gg=dir(dataname1);

for track=1:length(gg)
    
    % [data2,samplerate]=audioread(gg(1).name);
    info = audioinfo(gg(track).name);
    
    %To save data into
    tda_all=cell(partnr,1);
    tdt_all=cell(partnr,1);
    
    for part=1:partnr
        % part=1; %Later for part=1:5
        %Later if part*ceil(info(1).TotalSamples/5)>info(1).TotalSamples
        % [data3,Fs] = audioread(dataname1,[part*ceil(info(1).TotalSamples/5)-ceil(info(1).TotalSamples/5)+1,info(1).TotalSamples]);
        if part*ceil(info(1).TotalSamples/partnr)<=info(1).TotalSamples %to avoid stepping outside matrix
        [data11,samplerate] = audioread(gg(track).name,[part*ceil(info(1).TotalSamples/partnr)-ceil(info(1).TotalSamples/partnr)+1,part*ceil(info(1).TotalSamples/partnr)]);
        delay=part*ceil(info(1).TotalSamples/partnr)-ceil(info(1).TotalSamples/partnr);
        elseif part*ceil(info(1).TotalSamples/partnr)>info(1).TotalSamples
              [data11,samplerate] = audioread(gg(track).name,[part*ceil(info(1).TotalSamples/partnr)-ceil(info(1).TotalSamples/partnr)+1,(info(1).TotalSamples)]);
        delay=part*ceil(info(1).TotalSamples/partnr)-ceil(info(1).TotalSamples/partnr);
        end
%To determine the treshold for each track
        if part==1
            hold on
            subplot(2,1,1)
            plot(data11(:,1))
            title(sprintf('which one is the animal track?press[q]for track above [a]for track below\n%s',gg(track).name))
            subplot(2,1,2)
            plot(data11(:,2))
            title11=sprintf('Normally the triggertrack has high Amplitude parts which all look the same \n click first on a peak of a call (plot above) then click on the peak of a trigger below\n just to  jog memory later, if answer is ''a'' then the pink dots are switched later');
            title(title11)
            set(gcf,'units','centimeters','position',[5 2 25 15])
            waitforbuttonpress;
            answer_at = get(gcf,'CurrentCharacter');
                        [xinput,yinput] = ginput(2); %click on call/trigger respectively
            close (gcf)
            
            if answer_at=='q'
                animal=data11(:,1);
                trigger=data11(:,2);
            elseif answer_at=='a'
                animal=data11(:,2);
                trigger=data11(:,1);
            else
                hold on
                subplot(2,1,1)
                plot(data11(:,1))
                title_title=sprintf('which one is the animal track?press[q]for track above [a]for track below \n%s',gg(track).name);
                title(title_title)
                subplot(2,1,2)
                plot(data11(:,2))
            title11=sprintf('Normally the triggertrack has high Amplitude parts which all look the same \n click first on a peak of a call (plot above) then click on the peak of a trigger below\n just to  jog memory later, if answer is ''a'' then the pink dots are switched later');
                title(title11)
                set(gcf,'units','centimeters','position',[5 2 25 15])
                
                waitforbuttonpress;
                answer = get(gcf,'CurrentCharacter');
                if answer_at=='q'
                    animal=data11(:,1);
                    trigger=data11(:,2);
                elseif answer_at=='a'
                    animal=data11(:,2);
                    trigger=data11(:,1);
                end
            end
        end
        
        if part~=1
            if answer_at=='q'
                animal=data11(:,1);
                trigger=data11(:,2);
            elseif answer_at=='a'
                animal=data11(:,2);
                trigger=data11(:,1);
            end
        end
        
% not used right now, as the voice seems to get filtered, however it is good to know it's there and waiting + can be used to kill device noise(which is most prominent at start) if need be
%  when used do not forget to un-comment the section almost at the bottom   % for voice_a=1:size..... %delete all occurences which might be human voice...
%       
%if part==1
%         %to kill (human)voice
%         play_a = audioplayer(animal(samplerate*3:samplerate*8),samplerate);
%                 play_t = audioplayer(trigger(samplerate*3:samplerate*8),samplerate);
%         
% play(play_a);
% pause(5)
% play(play_t)
% prompt_vk = {sprintf('voicekill')};
%                     dlg_title_vk = 'How much of the track shall be deemed trash?(in s)';
%                     num_lines_vk = 1;
%                     defaultans_vk = {sprintf('0')};
%                     ans_vk = inputdlg(prompt_vk,dlg_title_vk,num_lines_vk,defaultans_vk);        
%         end
        %% high pass filter
        %animal
        cutoff=5000; %treshold for filtering background noises
        [b,a] = butter(1,cutoff/(samplerate/2),'high'); %
        a1 = filter(b,a,animal); %the filtered signal
        
        %trigger
        cutoff=5000; %treshold for filtering background noises
        [b,a] = butter(1,cutoff/(samplerate/2),'high'); %
        t1 = filter(b,a,trigger); %the filtered signal
        
        %% abs
        a2=abs(a1);
        t2=abs(t1);
        %% lowpass filter
        %animal
        cutoff_low=2; %totally arbitrary at the moment
        [b,a] = butter(1,cutoff_low/(samplerate/2),'low'); %
        a3 = filter(b,a,a2); %the filtered signal
        
        %trigger
        cutoff_low=2; %totally arbitrary at the moment
        [b,a] = butter(1,cutoff_low/(samplerate/2),'low'); %
        t3 = filter(b,a,t2); %the filtered signal
        
        
        
        %% get beginning and ending ofeach call animal
        if part==1
        treshold_a=mean(a3)*3;%0.01; %as of yet arbitrary treshold
        end
        timedata_a=nan(200,4); % 1&3=the value of t3 at the points in 2&4 -> the time of the start/endpoint
        m=1; %counter for the datarows
        tt=1;
        while tt<=length(a3)
            if a3(tt)>treshold_a
                timedata_a(m,1)=a3(tt);
                timedata_a(m,2)=tt;
                n=tt;
                while a3(n)>treshold_a
                    n=n+1; %time of the end of the envelope
                    if n>=length(a3)
                        break
                    end
                end
                timedata_a(m,3)=a3(n);
                timedata_a(m,4)=n;
                m=m+1;
                tt=n+1;
                if  tt>=length(a3)
                    break
                end
            end
            tt=tt+1;
        end
        %deletes nans
        for uu=200:-1:1
            if (isnan(timedata_a(uu,:)))
                timedata_a(uu,:)=[];
                
            end
        end
        
        timedata_filter_a=timedata_a;
        timetreshold=mean((timedata_filter_a(:,4)-timedata_filter_a(:,2)))/3; %the third of the mean call length, as long as no cricket stopped short for some reason(which would be weird) should be all ok
        
        %deletes rows made by oscillation of call instead of real call
        for call=size(timedata_filter_a,1):-1:2
            if timedata_filter_a(call,4)-timedata_filter_a(call,2)<timetreshold
                timedata_filter_a(call,:)=[];
            end
        end
        
        
        %% get beginning and ending ofeach call trigger
       if part==1
        treshold_t=max(t3)/3; %0.01; %as of yet arbitrary treshold
       end
        timedata_t=nan(200,4); % 1&3=the value of data3 at the points in 2&4 -> the time of the start/endpoint
        m=1; %counter for the datarows
        tt=1;
        while tt<=length(t3)
            if t3(tt)>treshold_t
                timedata_t(m,1)=t3(tt);
                timedata_t(m,2)=tt;
                n=tt;
                while t3(n)>treshold_t
                    n=n+1; %time of the end of the envelope
                    if n>=length(t3)
                        break
                    end
                end
                timedata_t(m,3)=t3(n);
                timedata_t(m,4)=n;
                m=m+1;
                tt=n+1;
                if  tt>=length(a3)
                    break
                end
            end
            tt=tt+1;
        end
        %deletes nans
        for ii=200:-1:1
            if (isnan(timedata_t(ii,:)))
                timedata_t(ii,:)=[];
                
            end
        end
        
        timedata_filter_t=timedata_t;
        timetreshold=mean((timedata_filter_t(:,4)-timedata_filter_t(:,2)))/3; %the third of the mean call length, as long as no cricket stopped short for some reason(which would be weird) should be all ok
        
        %deletes rows made by oscillation of call instead of real call
        for call=size(timedata_filter_t,1):-1:2
            if timedata_filter_t(call,4)-timedata_filter_t(call,2)<timetreshold
                timedata_filter_t(call,:)=[];
            end
        end
        %% check treshold
        if part==1
            answer_tresh='a';
            
            while answer_tresh=='a'
                subplot(2,1,1)
                hold on
                plot(a3)
               plot(xinput(1,1),0,'mo') %/10 so the plot does not get all squished up

                plot(timedata_filter_a(:,2),timedata_filter_a(:,1),'bx')
                plot(timedata_filter_a(:,4),timedata_filter_a(:,3),'rx')
                title('animal track blue=beginning red=end')
                subplot(2,1,2)
                hold on
                plot(t3)
                plot(xinput(2,1),0,'mo') %/10 so the plot does not get all squished up
                plot(timedata_filter_t(:,2),timedata_filter_t(:,1),'bx')
                plot(timedata_filter_t(:,4),timedata_filter_t(:,3),'rx')
                tresh_q=sprintf('treshold is f->%f and a->%f ist that ok?[Q]==Yes,[A]==No',treshold_a,treshold_t);
                title(tresh_q)
                            set(gcf,'units','centimeters','position',[3 2 30 15])

                waitforbuttonpress;
                answer_tresh = get(gcf,'CurrentCharacter');
                close (gcf)
                if answer_tresh=='a'||answer_tresh~='q'
                    prompt = {sprintf('animal treshold is %f',treshold_a),sprintf('trigger treshold is %f',treshold_t)};
                    dlg_title = 'Type in new treshhold';
                    num_lines = 1;
                    defaultans = {sprintf('%f',treshold_a),sprintf('%f',treshold_t)};
                    ansss = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    treshold_a=str2num(ansss{1});
                    treshold_t=str2num(ansss{2});
                    % get beginning and ending ofeach call animal
                    timedata_a=nan(100,4); % 1&3=the value of t3 at the points in 2&4 -> the time of the start/endpoint
                    m=1; %counter for the datarows
                    tt=1;
                    while tt<=length(a3)
                        if a3(tt)>treshold_a
                            timedata_a(m,1)=a3(tt);
                            timedata_a(m,2)=tt;
                            n=tt;
                            while a3(n)>treshold_a
                                n=n+1; %time of the end of the envelope
                                if n>=length(a3)
                                    break
                                end
                            end
                            timedata_a(m,3)=a3(n);
                            timedata_a(m,4)=n;
                            m=m+1;
                            tt=n+1;
                            if  tt>=length(a3)
                                break
                            end
                        end
                        tt=tt+1;
                    end
                    %deletes nans
                    for uu=100:-1:1
                        if (isnan(timedata_a(uu,:)))
                            timedata_a(uu,:)=[];
                            
                        end
                    end
                    
                    timedata_filter_a=timedata_a;
                    timetreshold=mean((timedata_filter_a(:,4)-timedata_filter_a(:,2)))/3; %the third of the mean call length, as long as no cricket stopped short for some reason(which would be weird) should be all ok
                    
                    %deletes rows made by oscillation of call instead of real call
                    for call=size(timedata_filter_a,1):-1:2
                        if timedata_filter_a(call,4)-timedata_filter_a(call,2)<timetreshold
                            timedata_filter_a(call,:)=[];
                        end
                    end
                    
                    
                    % get beginning and ending ofeach call trigger
                    timedata_t=nan(100,4); % 1&3=the value of data3 at the points in 2&4 -> the time of the start/endpoint
                    m=1; %counter for the datarows
                    tt=1;
                    while tt<=length(t3)
                        if t3(tt)>treshold_t
                            timedata_t(m,1)=t3(tt);
                            timedata_t(m,2)=tt;
                            n=tt;
                            while t3(n)>treshold_t
                                n=n+1; %time of the end of the envelope
                                if n>=length(t3)
                                    break
                                end
                            end
                            timedata_t(m,3)=t3(n);
                            timedata_t(m,4)=n;
                            m=m+1;
                            tt=n+1;
                            if  tt>=length(t3)
                                break
                            end
                        end
                        tt=tt+1;
                    end
                    %deletes nans
                    for ii=100:-1:1
                        if (isnan(timedata_t(ii,:)))
                            timedata_t(ii,:)=[];
                            
                        end
                    end
                    
                    timedata_filter_t=timedata_t;
                    timetreshold=mean((timedata_filter_t(:,4)-timedata_filter_t(:,2)))/3; %the third of the mean call length, as long as no cricket stopped short for some reason(which would be weird) should be all ok
                    
                    %deletes rows made by oscillation of call instead of real call
                    for call=size(timedata_filter_t,1):-1:2
                        if timedata_filter_t(call,4)-timedata_filter_t(call,2)<timetreshold
                            timedata_filter_t(call,:)=[];
                        end
                    end
                end
            end
        end
        
%         if part~=1
%             % just to check
%             subplot(2,1,1)
%             hold on
%             plot(a3)
%             plot(timedata_filter_a(:,2),timedata_filter_a(:,1),'bx')
%             plot(timedata_filter_a(:,4),timedata_filter_a(:,3),'rx')
%             title('animal track blue=beginning red=end just to check')
%             subplot(2,1,2)
%             hold on
%             plot(t3)
%             plot(timedata_filter_t(:,2),timedata_filter_t(:,1),'bx')
%             plot(timedata_filter_t(:,4),timedata_filter_t(:,3),'rx')
%             title('trigger track')
%             set(gcf,'units','centimeters','position',[3 2 30 15])
%             
%             pause(9)
%             close (gcf)
%         end

        %% wrap it up
        timedata_filter_a(:,[2,4])=timedata_filter_a(:,[2,4])+delay;
        timedata_filter_t(:,[2,4])=timedata_filter_t(:,[2,4])+delay;
% for voice_a=1:size(timedata_filter_a,1)  %delete all occurences which might be human voice
%     if timedata_filter_a(voice_a,2)<str2double(cell2mat(ans_vk))*samplerate
%         timedata_filter_a(voice_a,2)=[];
%     end
% end
%  
% for voice_t=1:size(timedata_filter_t,1)
%     if timedata_filter_t(voice_t,2)<str2double(cell2mat(ans_vk))*samplerate
%         timedata_filter_t(voice_t,2)=[];
%     end
% end
        
        tda_all{part,1}=timedata_filter_a;
        tdt_all{part,1}=timedata_filter_t;
        
    end
    
    
    
    timedata_at.tda=tda_all;
    timedata_at.tdt=tdt_all;
    timedata_at.origdata=gg(track).name;
    timedata_at.note='timedata_a=timedata of animaltrack, columns 2&4=time of start/end, coulumns1&3 value at start/end; call_trigger_location-> x and y coordinates of call in first row, of trigger in second, answer_at-> Was theanimal track above`q` or below `a`';
    timedata_at.cutoff=[cutoff_low,cutoff];
    timedata_at.treshold=[treshold_a,treshold_t];
    timedata_at.answer_at=answer_at; 
    timedata_at.call_trigger_location=[xinput,yinput];
    dataname=sprintf('%s_times_filtered_p5',gg(track).name(1:end-4));
    save(dataname,'timedata_at')
end
