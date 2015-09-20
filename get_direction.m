function direction=get_direction(lambda, maxx,maxy)
%generate a random direction vector
n = round(lambda*maxx*maxy); %number of nodes
direction = rand(n,1)*360;

end