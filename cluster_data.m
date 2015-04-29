function [c, segTimes] = cluster_data(data, t, mode, varargin)

switch mode
    case 1
        c = kmeans(data, varargin{1});
    case 2
        c = clusterdata(data, 'maxclust', varargin{1});
    case 3
        c = vbgm(data', varargin{1});
    case 4
        gm = fitgmdist(data, varargin{1});
        c = cluster(gm, data);
    case 5
        [~,U,~] = fcm(data, varargin{1}); %5 = number of clusters
        [~,c] = max(U);
        c = transpose(c);
end

last = 1;
segTimes = [];
for i = 2:length(c)
    if c(i) ~= c(last)
        segTimes = [segTimes; t(i)];
    end
    last = i;
end

end