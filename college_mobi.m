function [lost assignment femtoquota cascade chains candidate_num]=college_mobi(dis,radius,quota,assign_topo,in_thre,out_thre,o_femtoquota,speed) %dis,( femto * user )
disind=(dis<=radius);
dis=dis.*disind+1000.*(1-disind);
numuser=size(dis,2);
numfemto=size(dis,1); %size的参数，1是行数，2是列数

assignment=assign_topo;
old_assignment = assignment; %记录用于记录前一iteration的拓扑。两次拓扑不变，则college收敛
femtoquota=o_femtoquota; %记录基站剩余可挂载数

epsilon=1e-5;
in_threshold = in_thre; %rate大于in_threshold方可接入
out_threshold = out_thre; %rate小于out_threshold时踢出。距离为15的rate 3.8161
chains = 0;
cascade = 0;

rate=getrate(dis,radius)+epsilon; % 每个用户的 r 100*500

[max_rate f_id] = max(rate);
moved_point = []; %用于存储移动了的用户，的编号(以及无连接用户，的编号)
for i=1:numuser
   if speed(i) ~= 0
       if assignment( i ) == 0
           moved_point = [moved_point i];
           continue
       end
       if rate( assignment( i ) , i ) > out_threshold %排除不需要handoff的(尚未达到踢出要求的阈值)
           continue
       else %需要handoff的
           femtoquota(assignment( i )) = femtoquota(assignment( i )) + 1 ;
           assignment( i ) = 0;
           if max_rate(i) > in_threshold
               moved_point = [moved_point i];
           end
       end
   else %if speed=0 but assigned no BS
       if assign_topo(i) == 0 
           moved_point = [moved_point i];
       end
   end
end
old_moved_p = moved_point;
old_femtoquota = quota - femtoquota; %初始状态下，各个BS服务用户的个数。用于计算后面的chains

asscount=1;
iteration = 0;
while(asscount>0)
    asscount=0;
    iteration = iteration +1;
    %user choose the best femto
    [minval user_femto]=min(dis,[],1); %minval 最小距离；user_femto 每个user想连的基站ID
    fmask=(minval<radius);
    user_femto=user_femto.*fmask; %获得第一志愿
    
    new_in = [];
    push_out = [];
    for i = 1:length(moved_point)
       wanted_BS = user_femto( moved_point(i) );  %此 待处理用户 的第一志愿
       
%%%%%%%%%%%%%%%排除无基站覆盖的用户
       if wanted_BS == 0
              continue
       end
%%%%%%%%%%%%%%%%%%%%%%%

       if femtoquota( wanted_BS ) ~= 0 %有空余挂载位
           assignment( moved_point(i) ) = wanted_BS;
           femtoquota(wanted_BS)=femtoquota(wanted_BS)-1;
           push_out = [push_out i];
       else     %无空余挂载位
           fusers=find( assignment == wanted_BS );
           [fval , frank]=sort(minval(fusers));
           max_dis_user_id = fusers(frank( quota ) );
           
           if dis( wanted_BS,max_dis_user_id ) < minval( moved_point(i) ) %第一志愿不满足
               dis(wanted_BS,moved_point(i))=inf;
               asscount = asscount + 1;
               continue
           else %第一志愿满足，即大于原前quota的第quota名
               assignment( moved_point(i) ) = assignment( max_dis_user_id );
               assignment( max_dis_user_id ) = 0;
               push_out = [push_out i];
               new_in = [new_in max_dis_user_id];
           end
       end
    end
    moved_point(push_out) = [];
    moved_point = [moved_point new_in];
    
    asscount = asscount + sum(abs(assignment - old_assignment));
    old_assignment = assignment;

end

lost=sum(assignment==0);


candidate = setdiff( old_moved_p,moved_point );
candidate_num = length(candidate);
% candidate
chains = 0;
for ii=1:length(candidate)
    BS_tmp = assignment(candidate(ii));
    if old_femtoquota(BS_tmp) >= quota
        chains = chains +1;
    else
        old_femtoquota(BS_tmp) = old_femtoquota(BS_tmp) +1;
    end
end

cascade = length(setdiff(find((assignment~=assign_topo)==1),old_moved_p ));

end
