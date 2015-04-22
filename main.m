clc; clear all;
addpath 'data/'
addpath 'data/mount_tire/'
addpath 'data/remove_tire/'
addpath 'emgm/'
addpath 'vbgm/'

format long

data_dir = 'data/remove_tire/'
dir(strcat(data_dir, '*.csv'))

manual = import_manual_segments(strcat(data_dir, 'manual_segment.csv'));
states = importfile(strcat(data_dir, '/states.csv'));
data = csvread(strcat(data_dir, 'wheel_LF-hand_L.csv'), 1, 0);

% Convert NS to seconds
ns2sec = @(ns_val) max((ns_val - data(1))./(1000000000.0), 0);
t = ns2sec(data(:, 1)); 

% Define start and end points
start_pct = 0.05;
end_pct = 0.90;

st_idx = int32(size(t,1)*start_pct) + 1;
end_idx = int32(size(t,1)*end_pct);
t = t(st_idx:end_idx);
x = data(st_idx:end_idx, 2:end);


% Replace all zero timestamps withj beginning of file
manual.StartTime(manual.StartTime==0) = data(st_idx, 1);
states.Time(states.Time==0) = data(st_idx, 1);
% Replace all negative timestamps with the end of the file
manual.EndTime(manual.EndTime<0) = data(end_idx, 1);
states.Time(states.Time<0) = data(end_idx, 1);

dx = x(2:end, :) - x(1:end-1, :);
dt = t(2:end) - t(1:end-1);
v = bsxfun (@rdivide, dx, dt);

ddx = dx(2:end, :) - dx(1:end-1, :);
a = bsxfun (@rdivide, ddx, dt(1:end-1));


smooth_cols = @(x, varargs) cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x, varargs(1), 'moving')), num2cell(x, 1), 'UniformOutput', false));
args = [5];
x = smooth_cols(x, args);
v = smooth_cols(v, args);

zzs = sqrt(v(:, 1).^2 + v(:, 2).^2 + v(:, 3).^2) < 0.01;
sum(zzs)
zero_min = min(t(zzs))
zero_max = max(t(zzs))

%[idx, C] = kmeans(t(zzs), 2)

%%
%idx = emgm(t(zzs)', 10)'
idx = vbgm(t(zzs)', 10);

% Matlab 'Clusterdata'
%idx = clusterdata(t(zzs), 'cutoff', 0.8);

% Gaussian Mixture Models
%gm = fitgmdist(t(zzs), 2);
%idx = cluster(gm, t(zzs));

num_clusters = max(idx)

%%
clusters = [];
for i = 1:max(idx)
    clusters = [clusters, (idx == i)];
end 
clusters

pts = t(zzs);

c = num2cell(clusters, 1)
y = cellfun(@(x)(pts(logical(x))), c, 'UniformOutput', false)

clf
dots = repmat('-', 1, numel(y) + 1);
dots(1) = '.'
plot_all(t, {x, v, a}, { ... ns2sec(states.Time), ... 
    ns2sec(manual.EndTime), y{:}}, dots)

%highlight(x(t_1, 1), x(t_2, 1))
