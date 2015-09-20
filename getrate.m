function rate=getrate(dis,radius)
p=1e4;
a=2;
% rate=floor(15./dis);%+
% %rateind=(rate>0);
% %rate=rate+rateind.*rand(size(dis));
rate=log(1+p./(dis.^a+0.1));
%rate=log(1+p./((dis.^a)*0.1));

% steps=[1 2 5.5 11];
% cut=[1 0.5 0.2 0.1];
% rate=steps(1).*(dis<radius*cut(1));
% for i=2:length(steps)
%     rate=rate+ (steps(i)-steps(i-1)).*(dis<radius*cut(i));
% end

end