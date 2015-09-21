function [lost cost assignment price reserve cascade chains candidate_num]=auctionmatch_mobi(dis,radius,f2uratio,speed,assign_topo,o_price,o_reserve,w,in_thre,out_thre )
%assig是一个列向量，表示每个用户连接的基站，lost是未建立连接的用户个数；assign_topo是现有拓扑，即前一轮得到的assignment,reserve是各个VBS的连接情况

%proportional match
in_threshold = in_thre; %rate大于in_threshold方可接入
out_threshold = out_thre; %rate小于out_threshold时踢出。距离为15的rate 3.8161
maxiter=1e4;
numuser=size(dis,2); %size(A,n)如果在size函数的输入参数中再添加一项n，并用1或2为n赋值，则 size将返回矩阵的行数或列数。其中r=size(A,1)该语句返回的时矩阵A的行数， c=size(A,2) 该语句返回的时矩阵A的列数。
numfemto=size(dis,1); 
epsilon=1e-5;
disind=(dis<=radius); %disind是个大小和dis一样的矩阵，dis小于等于radius的位置，disind的对应位置为1
handoff = 0;
kick_out = 0;
cascade = 0;
discount = 1;

dis=dis.*disind + 1./(disind) - 1; %"."表示元素群运算。参见<基本语法>P4
rate=getrate(dis,radius)+epsilon; % 每个用户的 r 100*500
lograte=log2(rate)-log2(epsilon);%-w*log2((f2uratio-1)^(f2uratio-1)/f2uratio^f2uratio);

cost=0;
lost=0;
change=1;
iteration=0;
assignment = assign_topo;
price=o_price; % numfemto * f2uratio
reserve = o_reserve; %各VBS的连接情况,numfemto * f2uratio

%搜集需要切换的用户
[max_rate f_id] = max(rate);
moved_point = []; %用于存储移动了的用户，的编号(以及无连接用户，的编号)
for i=1:numuser
   if speed(i) ~= 0
       if assignment( i ) == 0
           moved_point = [moved_point i];
           continue
       end
       if rate( assignment( i ) , i ) > out_threshold %排除不需要切换的(尚未达到踢出要求的阈值)
           continue
       else %需要处理的移动用户。踢出 或 handoff
           [ tmp_row , tmp_col ] = find( reserve == i );
           reserve( tmp_row , tmp_col ) = 0;
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
old_reserve = reserve;

%对于已有人离开的VBS价格清零
price( find(reserve==0) ) = 0; %对于无连接的VBS，价格清零
for fem = 1: numfemto
    if length(find( price(fem,:) == 0 )) ~= 0
        vbs_id = find( price(fem,:) == 0 );
        for j = 1:length(vbs_id)
            i = f2uratio-length(vbs_id)+j;
            price(fem,vbs_id(j))=-w*log2(( i-1)^(i-1)/i^i);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf('Femtomatching:待处理的移动用户：\n')
% moved_point( find( speed(moved_point) ~= 0 ) )
% fprintf('\nFemtomatching:待处理的无连接用户:\n')
% moved_point( find( assign_topo(moved_point) == 0 ))
% for i=1:length(moved_point)
%    if assign_topo(moved_point(i)) == 0
%            fprintf('  %g  ',moved_point(i)) 
%    end
% end
% fprintf('\nFemtomatching:进入拍卖过程：\n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while(change==1)
    if length(moved_point) == 0
        break;
    end
    [curprice priceid] = min( price , [] , 2 );

    
    change=0;
    iteration=iteration+1;
    
    cost(iteration)=sum(assignment~=0);     %变量加括号，表示取数值下标对应的元素???????????????????????????
    %sum(curprice)
    if iteration>maxiter
        break;
    end
    

    %user submit requests
    requestbs=zeros(length(moved_point),1);
    bid=zeros(length(moved_point),1);
    for i=1:length(moved_point)
        margin=lograte(:,moved_point(i))-curprice;
        if assign_topo(moved_point(i)) ~= 0  %若之前有连接，则在原连接基站享受打折
            margin( assign_topo(moved_point(i)) )=lograte( assign_topo(moved_point(i)) ,moved_point(i)) - discount*curprice( assign_topo(moved_point(i)) );
        end
        [ maxmargin requestbs(i)]=max(margin);
        if(maxmargin<=0)
            requestbs(i)=0;
            continue;
        end
        margin(requestbs(i))=-inf;
    

        [secondmargin id ]=max(margin);
        bid(i)=maxmargin-secondmargin ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 此处对bid有调整
        if(bid(i)<=1e-2)
              bid(i)=0.5;%rand(1,1);
        end
        if(bid(i)<0)
            bid(i)=0;
            requestbs(i)=0;
        end
    end

    win_list = [];
    for i=1:numfemto
        requestid=find(requestbs==i);
        if(isempty(requestid));
            continue;
        end
        [maxbid uid]=max(bid(requestid));
        winuser=moved_point(requestid(uid)); %winuser指向user的实际ID

        if(maxbid==0)
            maxbid=1;
        end
        
        assignment(winuser)=i;
        win_list = [win_list winuser];
        if(reserve(i,priceid(i))~=0) %assigned
            assignment(reserve(i,priceid(i)))=0;
            moved_point = [moved_point reserve(i,priceid(i))];
        end
        
        reserve(i,priceid(i))= winuser ;
       if maxbid < 0.3
           maxbid = 0.5;
       end
       price(i,priceid(i))=price(i,priceid(i))+maxbid;
       [curprice(i) , priceid(i)]=min(price(i,:));%give the smallest price

        change=1;
    end
    for i=1:length(win_list)
        moved_point( find( moved_point == win_list(i) ) ) = [];
    end
end

lost=length(find(assignment==0));

candidate = setdiff( old_moved_p,moved_point );
candidate_num = length(candidate);

%new femto_quota
association_stat = (old_reserve ~= 0); %求起始时各VBS的连接状态
femto_quota = sum(association_stat , 2); %求candidate最终连接的基站在起始状态时连接的用户个数
chains = 0; %记录这样的用户个数：原本无连接（或移动出radius），现在通过踢走别人而获得连接
for ii=1:length(candidate)
    BS_tmp = assignment(candidate(ii));
    if femto_quota(BS_tmp) >= f2uratio
        chains = chains +1;
    else                                                                                              %%% 用于debug %%%
        femto_quota(BS_tmp) = femto_quota(BS_tmp) +1;
    end
end

cascade = length(setdiff(find((assignment~=assign_topo)==1),old_moved_p ));

if (cascade ~=0 & chains == 0)                                                                                   %%% 用于debug %%%
    chains = 1;                                                                                     %%% 用于debug %%%
end                                                                                              %%% 用于debug %%%

end
