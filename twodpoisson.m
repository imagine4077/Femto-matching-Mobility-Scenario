function [X Y]=twodpoisson(lambda, maxx,maxy)
%genreates a random 2D possion with given lambda

n=round(lambda*maxx*maxy); %number of nodes
X=rand(n,1)*maxx-maxx/2;
Y=rand(n,1)*maxy-maxy/2;
end