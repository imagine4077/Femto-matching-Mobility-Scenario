function [rate cost]=getcost(assign,dis,radius)
cellid=unique(assign);
numuser=size(assign,1);
usersum=arrayfun( @(x)sum(assign==x), cellid); %a vector that every row records the number of user who connect to this BS
cost=0;
rate=zeros(numuser,1);
for i=1:numuser
    cell=assign(i);
    ind=find( (cellid==cell),1);
    if(cell~=0)
        if(cell==size(dis,1))
           rate(i)=getrate2(dis(cell,i),radius,1)/usersum(ind); %每个用户获得的rate
        else
           rate(i)=getrate2(dis(cell,i),radius,0)/usersum(ind);
        end
        cost=cost+log(rate(i)/usersum(ind));
    else
        rate(i)=getrate2(dis(end,i),radius,1)/usersum(ind);
        cost=cost+log(rate(i)/usersum(ind));
    end
end
end
