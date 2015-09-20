function rate=getrate2(dis,radius,ismacro)
p=1e2;
a=3;
pmacro=1e4;
noise=1e-9*1e4;
% rate=floor(15./dis);%+
% %rateind=(rate>0);
% %rate=rate+rateind.*rand(size(dis));
rate=zeros(size(dis));
for cell=1:size(dis,1)
    if(ismacro(cell)==0)
        rate(cell,:)=log2(1+p./noise./(dis(cell,:).^a));
    else
        rate(cell,:)=log2(1+pmacro./noise./(dis(cell,:).^a));
    end
end

% steps=[1 2 5.5 11];
% cut=[1 0.5 0.2 0.1];
% rate=steps(1).*(dis<radius*cut(1));
% for i=2:length(steps)
%     rate=rate+ (steps(i)-steps(i-1)).*(dis<radius*cut(i));
% end

end