numloop=1;




counts=[];
lostcol=0;
lostrat=0;
lostmatch=0;
lostpf=0;
lostabs=0;
ratecol=0;
raterat=0;
ratematch=0;
faircol=0;
fairmatch=0;
fairrat=0;

for loops=1:numloop
flambda=0.01;
ulambda=0.05;
radius=15;
f2uratio=ceil(ulambda/flambda)+1;
fieldsize=100;
[femtox femtoy]=twodpoisson(flambda,fieldsize,fieldsize);
[userx usery]=twodpoisson(ulambda,fieldsize,fieldsize);


numfemto=length(femtox);
numuser=length(userx);

femtoxy=[femtox femtoy];
macroxy=[0 0];
userxy=[userx usery];
dis=pdist2(femtoxy, userxy);    %生成用户到femtocell的距离矩阵。行对应femtocell，列对应user
                                %【D = pdist2(X,Y)，这里 X 是 mx-by-n 维矩阵，Y 是 my-by-n 维矩阵，生成 mx-by-my 维距离矩阵 D。】
%warping
% tempdis=pdist2(femtoxy, userxy+[ones(numuser,1)*fieldsize zeros(numuser,1)]);
% dis=min(cat(3,dis,tempdis),[],3);
% tempdis=pdist2(femtoxy, userxy+[ones(numuser,1)*fieldsize*-1 zeros(numuser,1)]);
% dis=min(cat(3,dis,tempdis),[],3);
% tempdis=pdist2(femtoxy, userxy+[zeros(numuser,1) ones(numuser,1)*fieldsize*-1 ]);
% dis=min(cat(3,dis,tempdis),[],3);
% tempdis=pdist2(femtoxy, userxy+[zeros(numuser,1) ones(numuser,1)*fieldsize*-1 ]);
% dis=min(cat(3,dis,tempdis),[],3);



dismacro=pdist2(macroxy,userxy);
olddis=dis;
%assign to nearest cell
[val ind]=min(dis, [],1);  %返回每列最小值，val存放每列最小值，ind存放其所在行数
%find the number of users that assigned to a given cell
counts= cat(2,counts,arrayfun( @(x)sum(ind==x), unique(ind)));

% %%test for auctionmatch3
% aplist=zeros(numuser,20);
% aprate=zeros(numuser,20);
% apnum=zeros(numuser,1);
% for i=1:numuser
%     for j=1:numfemto
%         if(dis(j,i)>radius)
%             continue;
%         end
%         apnum(i)=apnum(i)+1;
%         aplist(i,apnum(i))=j;
%         aprate(i,apnum(i))=log2(getrate(dis(j,i),radius)+1e-5)-log2(1e-5);
%         
%     end
% end
% 
% [losttemp matchcost2 matchassign]=auctionmatch3(aplist,aprate,apnum,f2uratio);
% 
% %%end of test
[losttemp matchcost2 matchassign]=auctionmatch(dis,radius,f2uratio,1);
lostmatch=lostmatch+losttemp;
[matchrate matchcost]=getcost(matchassign,dis,radius);
ratematch=ratematch+mean(matchrate);
fairmatch=fairmatch+jainsfair(matchrate);   %jainsfair???????????????????????

% % %%test for college3
% aplist=zeros(numuser,20);
% aprate=zeros(numuser,20);
% apnum=zeros(numuser,1);
% for i=1:numuser
%     for j=1:numfemto
%         if(dis(j,i)>radius)
%             continue;
%         end
%         apnum(i)=apnum(i)+1;
%         aplist(i,apnum(i))=j;
%         aprate(i,apnum(i))=log2(getrate(dis(j,i),radius)+1e-5)-log2(1e-5);
%         
%     end
% end
% % 
%  [losttemp colassign]=college3(aplist,aprate,apnum,f2uratio);
[losttemp colassign]=college(dis,radius,f2uratio);
%[losttemp colassign]=college2(dis,radius,f2uratio);
lostcol=lostcol+losttemp;
[colrate colcost]=getcost(colassign,dis,radius);
ratecol=ratecol+mean(colrate);
faircol=faircol+jainsfair(colrate);

[losttemp colassign2]=ratgame(dis,radius,f2uratio);
%[losttemp matchcost2 colassign2]=auctionmatch(dis,radius,f2uratio,1);

lostrat=lostrat+losttemp;
[ratrate ratcost]=getcost(colassign2,dis,radius);
raterat=raterat+mean(ratrate);
fairrat=fairrat+jainsfair(ratrate);
% [colrate colcost]=getcost(colassign2,dis);
% %[losttemp matchassign]=mymatch(dis,radius,f2uratio);
% %[losttemp matchcost matchassign]=pfmatch(dis,radius,f2uratio,0);
% [losttemp matchcost2 matchassign]=auctionmatch(dis,radius,f2uratio,1);
% lostmatch=lostmatch+losttemp;
% [matchrate matchcost]=getcost(matchassign,dis);
% [losttemp pfcost pfassign]=pfmatch(dis,radius,f2uratio,1);
% % [losttemp pfcost pfassign]=pfmatch2(dis,radius,f2uratio, dismacro , f2uratio*1);
% lostpf=lostpf+losttemp;
% %[pfrate pfcost2]=getcost(pfassign,dis);
% [pfrate pfcost2]=getcost(pfassign,cat(1,dis,dismacro));
lostabs=lostabs+sum( min(dis,[],1)>radius );
% colcost
% pfcost2
% matchcost
% 
% sum(abs(pfassign-matchassign))
% clear dis




end
countind=(counts>f2uratio);
fprintf('vorinoi lost %g\n',sum(countind.*(counts-f2uratio))/sum(counts));
fprintf('colledge lost %g rate %g,fair %g\n',lostcol/sum(counts),ratecol/numloop,faircol/numloop);
fprintf('match lost %g rate %g,fair %g\n',lostmatch/sum(counts),ratematch/numloop,fairmatch/numloop);
fprintf('RAT lost %g rate %g,fair %g\n',lostrat/sum(counts),raterat/numloop,fairrat/numloop);
fprintf('absolute lost %g \n',lostabs/sum(counts));
sqrt(lostabs/sum(counts))

clf

hold on

for i=1:numuser
    if(colassign2(i)~=0)
        line([userx(i),femtox(colassign2(i))],[usery(i),femtoy(colassign2(i))],[0 0],'Color','r','LineWidth',2);       
    end

end
h1=voronoi(femtox,femtoy);
axis([-(fieldsize/2-radius) (fieldsize/2-radius) -(fieldsize/2-radius) (fieldsize/2-radius)]);
%axis([0 500 0 500]);
% scatter(femtox,femtoy,5,'b');
scatter(userx,usery,3,'r','filled')

figure
hold on

count=0;
for i=1:numuser
     if(matchassign(i)~=0)
         count=count+1;
        line([userx(i),femtox(matchassign(i))],[usery(i),femtoy(matchassign(i))],[0 0],'Color','g','LineWidth',2);       
    end
end
h2=voronoi(femtox,femtoy);
axis([-(fieldsize/2-radius) (fieldsize/2-radius) -(fieldsize/2-radius) (fieldsize/2-radius)]);
%axis([0 500 0 500]);
% scatter(femtox,femtoy,10,'r');
scatter(userx,usery,3,'r','filled')
% 
% 
% matchload=arrayfun( @(x)sum(matchassign==x), unique(matchassign))'
% figure
% 
% hold on
% 
% count=0;
% for i=1:numuser
%      if(pfassign(i)~=0)
%         count=count+1;
%         if(pfassign(i)<=numfemto)
%             line([userx(i),femtox(pfassign(i))],[usery(i),femtoy(pfassign(i))],[0 0],'Color','k','LineWidth',1);       
%         else
%             line([userx(i),0],[usery(i),0],[0 0],'Color','y','LineWidth',1);
%         end
%     end
% end
% voronoi(femtox,femtoy)
% axis([-(fieldsize/2-radius) (fieldsize/2-radius) -(fieldsize/2-radius) (fieldsize/2-radius)]);
% % scatter(femtox,femtoy,5,'b');
% scatter(userx,usery,3,'r','filled')
% pfload=arrayfun( @(x)sum(pfassign==x), unique(pfassign))'
