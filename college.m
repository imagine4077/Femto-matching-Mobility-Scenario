function [lost assignment femtoquota]=college(dis,radius,quota)
disind=(dis<=radius);
dis=dis.*disind+1000.*(1-disind);
numuser=size(dis,2);
numfemto=size(dis,1);
assignment=zeros(numuser,1);
femtoquota=ones(numfemto,1)*quota;


asscount=1;

while(asscount>0)
    asscount=0;
    %user choose the best femto
    [minval user_femto]=min(dis,[],1);
    fmask=(minval<radius);
    user_femto=user_femto.*fmask;
    for f=1:numfemto
        if(femtoquota(f)==0)
            continue;
        end
        fusers=find(user_femto==f);
        [fval frank]=sort(minval(fusers));
        for u=1:min([femtoquota(f) length(frank)])
            if(femtoquota(f)==0)
                continue;
            end
            assignment(fusers(frank(u)))=f;
            dis(:,fusers(frank(u)))=1000;
            femtoquota(f)=femtoquota(f)-1;
            asscount=asscount+1;
        end
    end
    for u=1:numuser
        if(user_femto(u)~=0)
          dis(user_femto(u),u)=1000;
        end
    end
%     assignment'
end


%lost=sum( min(dis,[],1)>radius );
lost=sum(assignment==0);
end