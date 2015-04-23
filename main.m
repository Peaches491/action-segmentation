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
args = [5];
x = smooth_cols(dataset.pos.t, dataset.pos.mag, args);
v = smooth_cols(dataset.vel.t, dataset.vel.mag, args);

zzs = v < 0.05
sum(zzs)
zero_min = min(dataset.vel.t(zzs))
zero_max = max(dataset.vel.t(zzs))

%[idx, C] = kmeans(t(zzs), 2)


%idx = emgm(t(zzs)', 10)'
idx = vbgm(dataset.vel.t(zzs)', 10);

% Matlab 'Clusterdata'
%idx = clusterdata(t(zzs), 'cutoff', 0.8);

% Gaussian Mixture Models
%gm = fitgmdist(t(zzs), 2);
%idx = cluster(gm, t(zzs));

num_clusters = max(idx)


clusters = [];
for i = 1:max(idx)
    clusters = [clusters, (idx == i)];
end 
clusters;

pts = dataset.vel.t(zzs);

c = num2cell(clusters, 1);
y = cellfun(@(x)(pts(logical(x))), c, 'UniformOutput', false);

clf
dots = repmat('-', 1, numel(y) + 1);
dots(1) = '.';
plot_all(dataset.pos.t, {dataset.pos.mag, dataset.vel.mag}, { ... states.Time, ... 
    s.manual.EndTime, y{:}}, dots)

%highlight(x(t_1, 1), x(t_2, 1))

%%

(s.ObjManip(1).pos.comp(2, :) - s.ObjManip(1).pos.comp(1, :)) /...
    s.ObjManip(1).pos.t(2, :) - s.ObjManip(1).pos.t(1, :)




