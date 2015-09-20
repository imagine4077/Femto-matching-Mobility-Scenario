function [X Y direct]=random_direction(userx,usery,direction,speed,fieldsize,radius)
%四个输入均为向量【n * 1】，其中n 为用户个数
%函数输入：userx，usery输入为当前user的位置。
%direction为角度向量，描述user移动的角度，取值域为[0,360)
%speed为速度，速度为0则为静止
% fprintf('userx,length %g \n',length(userx))
% fprintf('userx,length %g \n',length(speed))
X=userx+speed.*cosd(direction);
Y=usery+speed.*sind(direction);
direct=direction;

for i=1:1:length(X)
%   if X(i)>=(fieldsize/2-radius) 
   if X(i)>=fieldsize/2 
       X(i) = fieldsize/2;
       if direct(i)>180
           direct(i) = 540 - direct(i);
       else direct(i)<=180
           direct(i) = 180 - direct(i);
       end
%   elseif X(i)<= -(fieldsize/2-radius)
   elseif X(i)<= -fieldsize/2
       X(i) = -fieldsize/2;
       if direct(i)>180
           direct(i) = 540 - direct(i);
       else direct(i)<=180
           direct(i) = 180 - direct(i);
       end
   end
   
   if Y(i)>=fieldsize/2
       Y(i) = fieldsize/2;
       direct(i) = 360 - direct(i);
   elseif Y(i)<= -fieldsize/2
       Y(i) = -fieldsize/2;
       direct(i) = 360 - direct(i);
   end
end



end