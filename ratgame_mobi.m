function [lost assignment femtouserno cascade chains candidate_num]=ratgame_mobi(dis,radius,quota,assign_topo,in_thre,out_thre,o_femtouserno,speed)
disind=(dis<=radius);
dis=dis.*disind+1./(disind)-1;

rate=getrate(dis,radius);

numuser=size(dis,2);
numfemto=size(dis,1);
assignment=assign_topo;
femtoquota=ones(numfemto,1)*quota; %每个femto剩余挂载数

assistant = 0;                                                    %%% 用于debug ，可删除%%%
asscount=1;
femtouserno = o_femtouserno; %各个BS现有用户个数

in_threshold = in_thre; %rate大于in_threshold方可接入
out_threshold = out_thre; %rate小于out_threshold时踢出。距离为15的rate 3.8161
chains = 0;
kick_out = 0;
cascade = 0;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  查找待处理用户  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[max_rate f_id] = max(rate);
moved_point = []; %用于存储移动了的用户，的编号(以及无连接用户，的编号)
for i=1:numuser
%    fprintf('speed(%g)=%g',i,speed(i))
   if speed(i) ~= 0
       if assignment( i ) == 0
           moved_point = [moved_point i];
           continue
       end
       if rate( assignment( i ) , i ) > out_threshold %排除不需要handoff的(尚未达到踢出要求的阈值)
           continue
       else %需要handoff的
           femtouserno(assignment( i )) = femtouserno(assignment( i )) - 1 ;
           assignment( i ) = 0;
           moved_point = [moved_point i];
       end
   else
       if assign_topo(i) == 0 
           moved_point = [moved_point i];
       end
   end
end
old_moved_p = moved_point;
old_femtoquota = femtouserno;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:numfemto
    if femtouserno(j) ~= length(find(assignment==j))
        femtouserno(j) = length(find(assignment==j));
    end
    
end

old_assignment = assignment;
%% %%%%%%%%%%%%%%%%%%% 查找完毕 ， 下面进入匹配  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iteration = 0;
while(asscount>0)
%     moved_point
    asscount=0;
    iteration = iteration +1;
    rate=getrate(dis,radius);
    %user choose the best femto
    new_in = [];
    push_out = [];
    for u=1:length(moved_point)
       userexpect=femtouserno+1; % 向量，femto数 * 1，连接至此BS的用户个数。“若我加入后，各个BS的总用户个数是这个~” 
       this_user = moved_point(u);
       if(assignment( this_user )~=0)
              userexpect(assignment( this_user ))=userexpect(assignment( this_user ))-1; %如果user已经有BS了，其他BS该加1还加1。即考虑其他BS是否有更优效果
        end

       if sum( dis(:,this_user)<=radius ) == 0 %无基站可连，则pass
           continue
       end
       
        estimatrate=rate(:,this_user)./userexpect; %.*vaccell; %获得理想中，各个基站 的rate
        [maxval wanted_BS]=max(estimatrate);%得出自身想要的BS
        
        if maxval==0 | dis(wanted_BS,this_user)>radius
            continue
        end
        if wanted_BS == assignment(this_user)
            continue
        else
            if assignment(this_user)~= 0 %如果此用户已有连接，且expected BS不是原连接的BS
                femtouserno(assignment( this_user )) = femtouserno(assignment( this_user )) - 1 ;
                assignment(this_user) = 0;
            end
        end

        if femtouserno( wanted_BS )<quota  %if the wanted BS is avalible with no need to kick anyone out
            if assignment(this_user)~= 0 %对于本来已有基站，又选择更优基站的用户
                femtouserno(assignment( this_user )) = femtouserno(assignment( this_user )) - 1 ;
                assignment(this_user) = 0;
            end
            assignment( this_user ) = wanted_BS;
            femtouserno( wanted_BS ) = femtouserno( wanted_BS ) +1;
            push_out = [push_out u];
        
        else %if the wanted_BS is full occupied
            users_connected_thisBS=find( assignment == wanted_BS );
            rate_of_those_connected_user = rate(wanted_BS,users_connected_thisBS);
            [fval frank]=sort( rate_of_those_connected_user );

            if fval(quota) < rate(wanted_BS,this_user)
                uid_kicked = users_connected_thisBS( frank(quota) ); %the ID of the kicked user
                if assignment(this_user)~= 0 %对于本来已有基站，又选择更优基站的用户
                    femtouserno(assignment( this_user )) = femtouserno(assignment( this_user )) - 1 ;
                    assignment(this_user) = 0;
                end
                assignment( uid_kicked ) = 0;
                new_in = [new_in uid_kicked];
                assignment( this_user ) = wanted_BS;
                push_out = [push_out u]; %prepare to push this user out of the 'moved_point' set
            else %不满足第一志愿，下一轮转第二志愿
                dis(wanted_BS,this_user)=inf;
                asscount = asscount + 1;
                continue;
            end
        end
    end
    
    moved_point = [moved_point new_in];
    asscount = asscount + sum(abs(assignment-old_assignment));
    old_assignment=assignment;
end
moved_point = setdiff(moved_point,find(assignment~=0));

lost=sum(assignment==0);

candidate = setdiff( old_moved_p,moved_point );
candidate_num = length(candidate);
% candidate
chains = 0;
for ii=1:length(candidate)
    BS_tmp = assignment(candidate(ii));
    if old_femtoquota(BS_tmp) >= quota
        chains = chains +1;
    else                                                                                              %%% 用于debug %%%
        old_femtoquota(BS_tmp) = old_femtoquota(BS_tmp) +1;
    end
end

cascade = length(setdiff(find((assignment~=assign_topo)==1),old_moved_p ));



end
