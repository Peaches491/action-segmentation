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
s

% Convert NS to seconds
ns2sec = @(ns_val) max((ns_val - s.min_ns)./(1000000000.0), 0);
dataset = s.ObjManip(1);


%% Get smoothed data
clc;
smooth_cols = @(t, x, varargs) cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x, varargs(1), 'moving')), num2cell(x, 1), 'UniformOutput', false));
args = [50];
t = dataset.pos.t;
x = smooth_cols(dataset.pos.t, dataset.pos.mag, args);
v = smooth_cols(dataset.vel.t, dataset.vel.mag, args);


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




