clc; clear all;
addpath 'data/'
addpath 'data/mount_tire/'
addpath 'data/remove_tire/'
addpath 'emgm/'
addpath 'vbgm/'
addpath 'imports/'
format long

data_dir = 'data/remove_tire/';
types = import_file_types(strcat(data_dir, '/file_types.csv'));

% Define start and end points
start_pct = 0.0;
end_pct = 0.95;
s = build_data_struct(data_dir, types, start_pct, end_pct);
s;

% Convert NS to seconds
ns2sec = @(ns_val) max((ns_val - s.min_ns_start)./(1000000000.0), 0);

% Resample data to fixed interval
s = resample_data(s, ns2sec(s.max_ns_start), ns2sec(s.min_ns_end), 0.01);


% Select dataset
dataset = s.ObjManip(1);
datasets = [];
for i = 1:numel(s.ObjManip)
    datasets = [datasets, s.ObjManip(i).vel.mag];
end
for i = 1:numel(s.FixManip)
    datasets = [datasets, s.FixManip(i).vel.mag];
end
for i = 1:numel(s.FixObj)
    datasets = [datasets, s.FixObj(i).vel.mag];
end

for i = 1:numel(datasets)
    size(datasets(i).Data)
    %data = [data; datasets(i).Data'];
end


%% Plot Data
clc;
smooth_cols = @(t, x, varargs) cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x, varargs(1), 'moving')), num2cell(x, 1), 'UniformOutput', false));

args = [50];
t = dataset.pos.mag.Time;
x = smooth_cols(t, dataset.pos.mag.Data, args);
v = smooth_cols(t, dataset.vel.mag.Data, args);


plots = [smooth_dataset(dataset.vel.comp, 'moving', 5), ...
    smooth_dataset(dataset.vel.mag, 'moving', 25), ...
    smooth_dataset(dataset.vel.mag, 'moving', 50)];
dots = repmat('-', 1, numel(s.manual.EndTime));
dots(1) = '.';

clf
plot_all(plots, { s.manual.EndTime }, dots, {'Hand->Wheel Position', 'Hand->Wheel Velocity'})


%%
data = [];
smoothed_datasets = [];
for i = 1:numel(datasets)
    ds = smooth_dataset(datasets(i), 'moving', 15);
    data = [data, ds.Data];
    smoothed_datasets = [smoothed_datasets, ds];
end

data = [data, ds.Time];
size(data)
data = data(~any(isnan(data),2),:);

switch 3
    case 1
        c = kmeans(data, 4);
    case 2
        c = clusterdata(data, 'cutoff', 1.15);
    case 3
        c = vbgm(data', min(25, size(data, 1)));
    case 4
        gm = fitgmdist(data, 5);
        c = cluster(gm, data);
    case 5
        [center,U,objFcn] = fcm(data,5); %5 = number of clusters
        [m,c] = max(U);
        c = transpose(c);
end
num_clusters = max(c)

clf;
% combos = combnk(1:size(data, 2), 3);
% combos = sort(combos);
% rows = 3
% 
% for i = 1:size(combos, 1)
%     subplot(rows, round(size(combos, 1)/rows), i)
%     X = data(:, combos(i, :));
%     scatter3(X(:,1),X(:,2),X(:,3),10,c)
%     title(mat2str(combos(i, :)))
% end
% 
% figure();
rows = 2;
for i = 1:numel(smoothed_datasets)
    subplot(rows, round(size(smoothed_datasets, 2)/rows), i);
    hold on;
    scatter(ds.Time(1:numel(c)), smoothed_datasets(i).Data(1:numel(c)), 12, c)
    
    dots = repmat('-', 1, numel(s.manual.EndTime));
    dots(1) = '.';
    
    %plot(ds.Time(1:numel(c)), smoothed_datasets(i).Data(1:numel(c)), '-')
    plot_all(smoothed_datasets(i), { s.manual.EndTime }, dots, {}, false)
    title(smoothed_datasets(i).Name)
end






%% Generate points
slice_idxs = v < 0.05
sum(slice_idxs)
zero_min = min(dataset.vel.t(slice_idxs))
zero_max = max(dataset.vel.t(slice_idxs))


%% Mike Mode
g = zeros(length(v), length(v));
error = 0; 
p1 = 1; p2 = 5;

for p1 = 1:length(v)
    for p2 = p1+1:length(v)
    error = calcError(v, t, p1, p2);

    g(p1, p2) = .5 + error;
    end
end
g = sparse(g);
[dist,path,pred] = graphshortestpath(g, 1, length(v));
slice_idxs = path;

%% Cluster Data
[idx, C] = kmeans(t(slice_idxs), 4)
%idx = emgm(t(slice_idxs)', 10)'
%idx = vbgm(t(slice_idxs)', min(10, numel(slice_idxs)));

% Matlab 'Clusterdata'
%idx = clusterdata(t(slice_idxs), 'cutoff', 0.8);

% Gaussian Mixture Models
%gm = fitgmdist(t(slice_idxs), 2);
%idx = cluster(gm, t(slice_idxs));

num_clusters = max(idx)


%% Plot Clusters
clc;
clusters = [];
for i = 1:max(idx)
    clusters = [clusters, (idx == i)];
end 
clusters;
%sort()
[vals, sort_idx] = sort(sum(clusters, 1), 2);
clusters = clusters(:, sort_idx);

pts = dataset.vel.t(slice_idxs);

c = num2cell(clusters, 1);
y = cellfun(@(x)(pts(logical(x))), c, 'UniformOutput', false);

dots = repmat('-', 1, numel(y) + 1);
dots(1) = '.';


x_2 = smooth_cols(s.FixObj(1).acc.t, s.FixObj(1).acc.mag, 50);
t_2 = s.FixObj(1).acc.t;

plots = {[dataset.pos.t, x], ...
         [dataset.vel.t, v]}; ... , [t_2, x_2]};
clf
plot_all(plots, { ... states.Time, ... 
    s.manual.EndTime, y{:}}, dots, {'Hand->Wheel Position', 'Hand->Wheel Velocity' ,''})

%highlight(x(t_1, 1), x(t_2, 1))

%%

(s.ObjManip(1).pos.comp(2, :) - s.ObjManip(1).pos.comp(1, :)) /...
    s.ObjManip(1).pos.t(2, :) - s.ObjManip(1).pos.t(1, :)




