function [lost assignment femtouserno]=ratgame(dis,radius,quota)
disind=(dis<=radius);
dis=dis.*disind+1./(disind)-1;

rate=getrate(dis,radius);

numuser=size(dis,2);
numfemto=size(dis,1);
assignment=zeros(numuser,1);
femtoquota=ones(numfemto,1)*quota;


asscount=1;
old_userfemto=zeros(1,numuser); %旧的assignment'
user_femto=zeros(1,numuser); %assignment'
femtouserno=zeros(numfemto,1); %第一志愿投此BS的用户数
estimatrate=zeros(numfemto,numuser); %用户对每个BS的rate的估计，矩阵，100*500
while(asscount>0)
    asscount=0;
    %user choose the best femto
    
    for u=1:numuser
       userexpect=femtouserno+1; % femto数 * 1，“若我加入后，各个BS的总用户个数是这个~”
       if(user_femto(u)~=0)
              userexpect(user_femto(u))=userexpect(user_femto(u))-1; %如果user已经有BS了，其他BS该加1还加1。即考虑其他BS是否有更优效果
        end

        vaccell=(userexpect<=femtoquota); %不考虑用户已满的BS
        estimatrate(:,u)=rate(:,u)./userexpect.*vaccell; %获得理想中，各个基站 的rate
        [maxval user_femto]=max(estimatrate,[],1); %得出自身想要的BS
        for f=1:numfemto
            femtouserno(f)=sum(user_femto==f);
            if femtouserno(f)>femtoquota(f)
               userid=find(user_femto==f); %连接此BS的所有用户
               user_rates=rate(f,userid);
               [result uindex]=sort(user_rates,2,'descend');
               for i=femtoquota(f)+1:femtouserno(f)
                   user_femto(userid(uindex(i)))=0; %对于前N名之后的，踢出
               end
%                fprintf('femtouserno(%g)=%g,\tfemtoquota(%g)=%g,\tuser_femto(%g)=%g,\tuser %g,BS%g\n',f,femtouserno(f),f,femtoquota(f),u,user_femto(u),u,f);
%                pause(1)
               femtouserno(f)=femtoquota(f);
    %            uindex
    %                       userid=find(user_femto==f)
    %            user_rates=rate(f,userid)
            end        
        end
       
    end
        asscount=sum(abs(user_femto-old_userfemto));
        old_userfemto=user_femto;
%     assignment'
end

%     for f=1:numfemto
%         if femtouserno(f)>femtoquota
%            userid=find(user_femto==f);
%            user_rates=rate(f,userid);
%            [result uindex]=sort(user_rates,2,'descend');
%            for i=femtoquota+1:femtouserno(f)
%                user_femto(userid(uindex(i)))=0;
%            end
% %            uindex
% %                       userid=find(user_femto==f)
% %            user_rates=rate(f,userid)
%         end        
%     end
for i=1:numuser
    if user_femto(i)==0
        continue;
    end
    if(rate(user_femto(i),i)==0)
        user_femto(i)=0;
    end
end
assignment=user_femto';

%lost=sum( min(dis,[],1)>radius );
lost=sum(assignment==0);
end