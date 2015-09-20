% %% the discount of femto-matching can be change at Line 15 of the file 'auctionmatch_mobi.m'
LOOP = 1000;
for L=1:LOOP
    fprintf('+++++++++  LOOP %g +++++++++\n',L);
clear;
college_data = [];
matching_data = [];
RAT_data = [];
x = [];

poly = 9; %多项式拟合中，多项式的次数
numloop=300;
weight = 1; %暂未用到
% in_threshold = 4.0; %rate大于in_threshold方可接入
in_threshold = 3.8161;
out_threshold = 3.8161; %rate小于out_threshold时踢出。距离为15的rate 3.8161
f2uratio = 6;


fieldsize=100;
flambda=0.004;
% flambda=0.014; %%%%%%%%%%%%%%%%%%%%%%%%%%% 用于调试
ulambda=f2uratio * flambda;

[userx_o usery_o]=twodpoisson(ulambda,fieldsize,fieldsize);
[femtox femtoy]=twodpoisson(flambda,fieldsize,fieldsize);
% femtox
% femtoy
% pause(600)
direction_o = get_direction(ulambda,fieldsize,fieldsize);
speed = get_speed(ulambda,fieldsize,fieldsize);

for r=5:15
% for r=15:15  %%%%%%%%%%%%%%%%%%%%%%%%%% 用于调试

% %以下用于观察动态，可删除
% fprintf('+++++++++++++++++++++++++++++\n demostrate which algorithm? \n');
% fprintf('1.Femto-Matching\n2.College\n3.RAT game\nPlease input your choice:');
% choice = input('');
% switch choice
%     case 1
%         fprintf('Femto-Matching:\n')
%     case 2
%         fprintf('College:\n')
%     case 3
%         fprintf('RAT Game:\n')
% end
% %以上用于观察动态，可删除

x = [x; 10*r];
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
chains_match = 0;
chains_college = 0;
chains_RAT = 0;
cascade_match = 0;
cascade_college = 0;
cascade_RAT = 0;
new_comer_match = 0;
new_comer_college = 0;
new_comer_RAT = 0;



%%%%%%%%%%%%%%%%%%%%%%%
flambda = 0.001 + flambda;
ulambda = 0.005 + ulambda;
radius=15;
fieldsize=100;
[femtox_tmp femtoy_tmp]=twodpoisson(0.001,fieldsize,fieldsize);
[userx_tmp usery_tmp]=twodpoisson(0.001*f2uratio,fieldsize,fieldsize);

dir_tmp = get_direction(0.001*f2uratio,fieldsize,fieldsize);
speed_tmp = get_speed(0.001*f2uratio,fieldsize,fieldsize);
% [userx usery]=twodpoisson(ulambda,fieldsize,fieldsize);
userx_o = [userx_o;userx_tmp];
usery_o = [usery_o;usery_tmp];
userx = userx_o;
usery = usery_o;
femtox = [femtox ; femtox_tmp];
femtoy = [femtoy ; femtoy_tmp];
direction_o = [direction_o;dir_tmp];
direction = direction_o;
speed = [speed;speed_tmp ];
fprintf('femtocell个数：%g\n',length(femtox));
% fprintf('用户个数：%g\n',length(userx));
% 
% fprintf('speed个数：%g\n',length(speed));
% fprintf('direction个数：%g\n',length(direction));
% fprintf('移动用户比例：%g \n', 1-length(find(speed==0))/length(userx) );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% 首次 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numfemto=length(femtox);
numuser=length(userx);

femtoxy=[femtox femtoy];
macroxy=[0 0];
userxy=[userx usery];
dis=pdist2(femtoxy, userxy);

dismacro=pdist2(macroxy,userxy);
olddis=dis; %
%assign to nearest cell
[val ind]=min(dis, [],1);  %返回每列最小值，val存放每列最小值，ind存放其所在行数
%find the number of users that assigned to a given cell
counts= cat(2,counts,arrayfun( @(x)sum(ind==x), unique(ind)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
[losttemp matchcost2 matchassign price reserve bid]=auctionmatch(dis,radius,f2uratio,1);
lostmatch=lostmatch+losttemp;
[matchrate matchcost]=getcost(matchassign,dis,radius);
ratematch=ratematch+mean(matchrate);
fairmatch=fairmatch+jainsfair(matchrate);


%%%%%%%%%%%%%%%%%%%%%%%%
[losttemp colassign coll_femtoquota]=college(dis,radius,f2uratio);
lostcol=lostcol+losttemp;
[colrate colcost]=getcost(colassign,dis,radius);
ratecol=ratecol+mean(colrate);
faircol=faircol+jainsfair(colrate);

%%%%%%%%%%%%%%%%%%%%%%%%
[losttemp colassign2 rat_femtouserno]=ratgame(dis,radius,f2uratio);
%[losttemp matchcost2 colassign2]=auctionmatch(dis,radius,f2uratio,1);

lostrat=lostrat+losttemp;
[ratrate ratcost]=getcost(colassign2,dis,radius);
raterat=raterat+mean(ratrate);
fairrat=fairrat+jainsfair(ratrate);
lostabs=lostabs+sum( min(dis,[],1)>radius );

%college对比RAT
% un = sum(colassign ~= colassign2)
% un/length(userx)
% 
% input('college对比RAT')
% continue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%   首次出图   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clf
% hold on
% count=0;
% for i=1:numuser
% %      if(matchassign(i)~=0)%femtomatching的动画
% %          count=count+1;
% %         line([userx(i),femtox(matchassign(i))],[usery(i),femtoy(matchassign(i))],[0 0],'Color','g','LineWidth',2);  
% %       end
% %     if(colassign(i)~=0)  %college的动画
% %          count=count+1;
% %         line([userx(i),femtox(colassign(i))],[usery(i),femtoy(colassign(i))],[0 0],'Color','g','LineWidth',2); 
% %     end
%     if(colassign2(i)~=0)  %RAT的动画
%          count=count+1;
%         line([userx(i),femtox(colassign2(i))],[usery(i),femtoy(colassign2(i))],[0 0],'Color','g','LineWidth',2); 
%     end
% end
% 
% % %以下用于观察动态，可删除
% % switch choice
% %     case 1
% %         for i=1:numuser
% %              if(matchassign(i)~=0)%femtomatching的动画
% %                  count=count+1;
% %                 line([userx(i),femtox(matchassign(i))],[usery(i),femtoy(matchassign(i))],[0 0],'Color','g','LineWidth',2);  
% %              end
% %         end
% %     case 2
% %         for i=1:numuser
% %              if(matchassign(i)~=0)%femtomatching的动画
% %                  count=count+1;
% %                 line([userx(i),femtox(colassign(i))],[usery(i),femtoy(colassign(i))],[0 0],'Color','g','LineWidth',2);  
% %              end
% %         end
% %     case 3
% %         for i=1:numuser
% %              if(matchassign(i)~=0)%femtomatching的动画
% %                  count=count+1;
% %                 line([userx(i),femtox(colassign2(i))],[usery(i),femtoy(colassign2(i))],[0 0],'Color','g','LineWidth',2);  
% %              end
% %         end
% % end
% % %以上用于观察动态，可删除
% 
% h2=voronoi(femtox,femtoy);
% % axis([-(fieldsize/2-radius) (fieldsize/2-radius) -(fieldsize/2-radius) (fieldsize/2-radius)]);
% 
% hold on
% hh1=plot(userx,usery,'r.');
% set(hh1,'EraseMode','Xor','MarkerSize',15);%设置擦除模式
% % scatter(userx,usery,3,'r','filled')
% 
% % direction = get_direction(ulambda,fieldsize,fieldsize);
% % speed = get_speed(ulambda,fieldsize,fieldsize);
% 
% pause(5)
%%%%%%%%%%%%%%% above used for plot moving-point picture %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rand_tmp = ceil( rand(3,1)*numloop );                               %用于测试，确认无错误即可删除
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%以下进入移动过程%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:numloop
%     fprintf('============================================ ROUND %g ============================================\n',i)
    
    drawnow;   
    [userx usery direction]=random_direction(userx,usery,direction,speed,fieldsize,radius);

    femtoxy=[femtox femtoy];
    userxy=[userx usery];
    dis=pdist2(femtoxy, userxy); %dis矩阵，行对应每个femtocell，列对应每个用户

    dismacro=pdist2(macroxy,userxy);
    olddis=dis;
    %assign to nearest cell
    [val ind]=min(dis, [],1);  %返回每列最小值，val存放每列最小值，ind存放其所在行数
    %find the number of users that assigned to a given cell
    counts= cat(2,counts,arrayfun( @(x)sum(ind==x), unique(ind)));
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
% [losttemp matchcost2 matchassign price reserve bid cascade_chains cascade]=auctionmatch_mobi_planA(dis,radius,f2uratio,speed,matchassign,price,reserve,weight,in_threshold,out_threshold,bid);
[losttemp matchcost2 matchassign price reserve cascade chains_tmp new_comer_tmp]=auctionmatch_mobi(dis,radius,f2uratio,speed,matchassign,price,reserve,weight,in_threshold,out_threshold);
lostmatch=lostmatch+losttemp;
[matchrate matchcost]=getcost(matchassign,dis,radius);
ratematch=ratematch+mean(matchrate);
fairmatch=fairmatch+jainsfair(matchrate); 
cascade_match = cascade_match + cascade ;
chains_match = chains_match + chains_tmp;
new_comer_match = new_comer_match + new_comer_tmp;
% if sum(i == rand_tmp) & chains_tmp ~= 0 %i == rand_tmp(1)                              %用于测试，确认无错误即可删除
%     input('matching-check！press Enter to continue');                     %用于测试，确认无错误即可删除
% end                                              %用于测试，确认无错误即可删除
%%%%%%%%%%%%%%%%%%%%%%%%
[losttemp colassign coll_femtoquota cascade chains_tmp new_comer_tmp]=college_mobi(dis,radius,f2uratio,colassign,in_threshold,out_threshold,coll_femtoquota,speed);
lostcol=lostcol+losttemp;
[colrate colcost]=getcost(colassign,dis,radius);
ratecol=ratecol+mean(colrate);
faircol=faircol+jainsfair(colrate);
cascade_college = cascade_college + cascade ;
chains_college = chains_college + chains_tmp;
new_comer_college = new_comer_college + new_comer_tmp;
% if i == rand_tmp(2)                              %用于测试，确认无错误即可删除
%     input('college-check！press Enter to continue');                      %用于测试，确认无错误即可删除
% end                                              %用于测试，确认无错误即可删除
%%%%%%%%%%%%%%%%%%%%%%%%
[losttemp colassign2 rat_femtouserno cascade chains_tmp new_comer_tmp]=ratgame_mobi(dis,radius,f2uratio,colassign2,in_threshold,out_threshold,rat_femtouserno,speed);
%[losttemp matchcost2 colassign2]=auctionmatch(dis,radius,f2uratio,1);

lostrat=lostrat+losttemp;
[ratrate ratcost]=getcost(colassign2,dis,radius);
raterat=raterat+mean(ratrate);
fairrat=fairrat+jainsfair(ratrate);
cascade_RAT = cascade_RAT + cascade ;
chains_RAT = chains_RAT + chains_tmp;
new_comer_RAT = new_comer_RAT + new_comer_tmp;
% if i == rand_tmp(3)                              %用于测试，确认无错误即可删除
%     input('RAT-check！press Enter to continue');                          %用于测试，确认无错误即可删除
% end                                              %用于测试，确认无错误即可删除

lostabs=lostabs+sum( min(dis,[],1)>radius );
%%%%%%%%%%%%%%%%%%%%%%%% plot moving-point picture %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clf
% hold on
% %%%%%%%%%Femto-Matching
% count=0;
% for i=1:numuser
% %      if(matchassign(i)~=0)%femtomatching的动画
% %          count=count+1;
% %         line([userx(i),femtox(matchassign(i))],[usery(i),femtoy(matchassign(i))],[0 0],'Color','g','LineWidth',2);  
% %       end
% %     if(colassign(i)~=0)  %college的动画
% %          count=count+1;
% %         line([userx(i),femtox(colassign(i))],[usery(i),femtoy(colassign(i))],[0 0],'Color','g','LineWidth',2); 
% %     end
%     if(colassign2(i)~=0)  %RAT的动画
%          count=count+1;
%         line([userx(i),femtox(colassign2(i))],[usery(i),femtoy(colassign2(i))],[0 0],'Color','g','LineWidth',2); 
%     end
% end
% 
% % %以下用于观察动态，可删除
% % switch choice
% %     case 1
% %         for i=1:numuser
% %              if(matchassign(i)~=0)%femtomatching的动画
% %                  count=count+1;
% %                 line([userx(i),femtox(matchassign(i))],[usery(i),femtoy(matchassign(i))],[0 0],'Color','g','LineWidth',2);  
% %              end
% %         end
% %     case 2
% %         for i=1:numuser
% %              if(matchassign(i)~=0)%femtomatching的动画
% %                  count=count+1;
% %                 line([userx(i),femtox(colassign(i))],[usery(i),femtoy(colassign(i))],[0 0],'Color','g','LineWidth',2);  
% %              end
% %         end
% %     case 3
% %         for i=1:numuser
% %              if(matchassign(i)~=0)%femtomatching的动画
% %                  count=count+1;
% %                 line([userx(i),femtox(colassign2(i))],[usery(i),femtoy(colassign2(i))],[0 0],'Color','g','LineWidth',2);  
% %              end
% %         end
% % end
% % %以上用于观察动态，可删除
% 
% h2=voronoi(femtox,femtoy);
% % axis([-(fieldsize/2-radius) (fieldsize/2-radius) -(fieldsize/2-radius) (fieldsize/2-radius)]);
% % scatter(userx,usery,3,'r','filled')
% % % set(hh2,'XData',userx,'YData',usery);
% % %%%%%%%%%%%%%%%%%%%%%%%%
% % 
% hh1=plot(userx,usery,'r.');
% set(hh1,'XData',userx,'YData',usery);
% % pause(1)
%%%%%%%%%%%%%%% above used for plot moving-point picture %%%%%%%%%%%%%
end

%%%%%%%% print the result of every femto-density loop
% countind=(counts>f2uratio);
% fprintf('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\nloop:%g,numfemto:%g\n',numloop,numfemto);
% fprintf('vorinoi lost %g\n',sum(countind.*(counts-f2uratio))/sum(counts));
% fprintf('colledge lost %g, rate %g,fair %g,average_cascade %g\n',lostcol/sum(counts),ratecol/numloop,faircol/numloop,cascade_college/numloop);
% fprintf('match lost %g, rate %g,fair %g,average_cascade %g\n',lostmatch/sum(counts),ratematch/numloop,fairmatch/numloop,cascade_match/chains_match); %cascade_match/cascade_chains_match
% fprintf('RAT lost %g, rate %g,fair %g,average_cascade %g\n',lostrat/sum(counts),raterat/numloop,fairrat/numloop,cascade_RAT/numloop);
% fprintf('absolute lost %g \n',lostabs/sum(counts));
% sqrt(lostabs/sum(counts))
%%%%%%%% end of printing the result of every femto-density loop

college_data = [college_data;lostcol/sum(counts),ratecol/numloop,faircol/numloop,cascade_college/numloop,cascade_college/chains_college,cascade_college/new_comer_college];
matching_data = [matching_data;lostmatch/sum(counts),ratematch/numloop,fairmatch/numloop,cascade_match/numloop,cascade_match/chains_match,cascade_match/new_comer_match];
RAT_data = [RAT_data;lostrat/sum(counts),raterat/numloop,fairrat/numloop,cascade_RAT/numloop,cascade_RAT/chains_RAT,cascade_RAT/new_comer_RAT];

end
% college_data %lost(1),rate(2),fairness(3),average_cascade_per_loop(4),average_cascade_per_chain(5),average_cascade_per_comer(6)
% matching_data
% RAT_data
% x =[50,60,70,80,90,100,110,120,130,140,150];
%%%%%%%%%%%%%% figure of lost
% for p = 1:6
%     if p ==1
%         figure('NumberTitle', 'off', 'Name', 'LOST')
%         hold on
%     else
%         if p==2
%         figure('NumberTitle', 'off', 'Name', 'RATE')
%         hold on
%         else
%             if p==3
%                 figure('NumberTitle', 'off', 'Name', 'Fairness')
%                 hold on
%             else
%                 if p==4
%                     figure('NumberTitle', 'off', 'Name', 'average_cascade_per_loop')
%                     hold on
%                 else
%                     if p ==5
%                         figure('NumberTitle', 'off', 'Name', 'average_cascade_per_chain')
%                         hold on
%                     else
%                         figure('NumberTitle', 'off', 'Name', 'average_cascade_per_comer')
%                         hold on
%                     end
%                 end
%             end
%         end
%     end
%     college_y = college_data(:,p);
%     matching_y = matching_data(:,p);
%     RAT_y = RAT_data(:,p);
% 
% 
%     plot(x,college_y,'-o',x,matching_y,'-p',x,RAT_y,'-d'); %,xx,yy3,xx,yy1,xx,yy2);  % 绘图，原始数据+拟合曲线 +++
%     legend('college','matching','RAT');
% end
college_data %lost(1),rate(2),fairness(3),average_cascade_per_loop(4),average_cascade_per_chain(5),average_cascade_per_comer(6)
matching_data
RAT_data

fid = fopen('discount1.0','at+');
[col_row , col_col] = size(college_data);
for row = 1:col_row
    for col = 1:col_col-1
        fprintf(fid,'%g,\t',college_data(row,col));
    end
    fprintf(fid,'%g\n',college_data(row,col_col));
end

[fem_row , fem_col] = size(matching_data);
for row = 1:fem_row
    for col = 1:fem_col-1
        fprintf(fid,'%g,\t',matching_data(row,col));
    end
    fprintf(fid,'%g\n',matching_data(row,fem_col));
end

[rat_row , rat_col] = size(RAT_data);
for row = 1:rat_row
    for col = 1:rat_col-1
        fprintf(fid,'%g,\t',RAT_data(row,col));
    end
    fprintf(fid,'%g\n',RAT_data(row,rat_col));
end
fprintf(fid,'\n');
fclose(fid);

end