function result=jainsfair(data)
n=length(data);
result=sum(data)^2/n/sum(data.^2);
end