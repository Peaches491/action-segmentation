clc;
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
s.data(1).pos.comp

% Convert NS to seconds
ns2sec = @(ns_val) max((ns_val - s.max_ns_start)./(1000000000.0), 0);
smooth_cols = @(t, x, varargs) cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x, varargs(1), 'moving')), num2cell(x, 1), 'UniformOutput', false));

% Resample data to fixed interval
s = resample_data(s, ns2sec(s.max_ns_start), ns2sec(s.min_ns_end), 0.01);


% Select dataset
dataset = s.data(1);
datasets = [];
for i = 1:numel(s.data)
    datasets = [datasets, s.data(i).pos.mag];
    datasets = [datasets, s.data(i).vel.mag];
    %datasets = [datasets, s.data(i).acc.mag];
end
filename = 'remove_test_pos_vel_t.csv'

data = [];
smoothed_datasets = [];
for i = 1:numel(datasets)
    ds = smooth_dataset(datasets(i), 'moving', 25);
    data = [data, ds.Data];
    smoothed_datasets = [smoothed_datasets, ds];
end

data = [data, ds.Time];

data = data(~any(isnan(data),2),:);
t = dataset.pos.mag.Time;

max_k = 10;
num_reps = 20;
num_modes = 5;
%errs = [];
errs = struct('Mode', [], 'Param', [], 'Iter', [], 'Avg_Dist', [], 'Num_Cuts_Err', []);
errs_idx = 1;
for mode = 1:num_modes
    mode_str = '';
    switch mode
        case 1
            mode_str = 'kmeans';
        case 2
            mode_str = 'clusterdata';
        case 3
            mode_str = 'vbgm';
        case 4
            mode_str = 'gm';
        case 5
            mode_str = 'fuzzy_kmeans';
    end
    for iter = 2:max_k
        for rep = 1:num_reps
            if mode ~= 2
                param = iter;
            else 
                param = iter;
                %param = (iter+max_k*mode)/(2*num_modes*max_k);
            end
            try
                [c, segTimes] = cluster_data(data, t, mode, param);
            catch 
                rep = rep-1;
                continue
            end
            num_cuts = numel(segTimes);

            totErr = 0;
            for i = 1:length(segTimes)
                totErr = totErr + min(abs(segTimes(i) - s.manual.EndTime));
            end
            avgErr = totErr/length(segTimes);
            errs(errs_idx) = struct('Mode', mode_str, ...
                                    'Param', param, ...
                                    'Iter', rep, ...
                                    'Avg_Dist', avgErr, ...
                                    'Num_Cuts_Err', num_cuts - size(s.manual.EndTime, 1));
            errs(errs_idx)
            errs_idx = errs_idx + 1;
        end
    end
end

struct2csv(errs, filename)

%%
clf;

%x = 1:size(errs, 1);
%plotyy(x,errs(:, 1),x,errs(:, 2:3),'bar')
%bar(errs(:, 1))

T2 = struct2table(errs');
T2.Properties.VariableNames = {'Mode', 'Param', 'Iter', 'Avg_Dist' 'Num_Cuts_Err'}
T2

%%
tree = linkage(data,'average');
dendrogram(tree, 0,'Reorder',1:size(errs, 1))


%%
clc
T3 = table('VariableNames', {'Avg_Dist' 'Num_Cuts_Err'}')
T3 = [T3; cell2table({0, 0}, 'VariableNames', T3.Properties.RowNames)]



%%
[c, segTimes] = cluster_data(data, t, 3, 6);

num_cuts = numel(segTimes);

totErr = 0;
for i = 1:length(segTimes)
    totErr = totErr + min(abs(segTimes(i) - s.manual.EndTime));
end
avgErr = totErr/length(segTimes)

clf;
rows = 3;
for i = 1:numel(smoothed_datasets)
    subplot(rows, round(size(smoothed_datasets, 2)/rows), i);
    hold on;
    scatter(ds.Time(1:numel(c)), smoothed_datasets(i).Data(1:numel(c)), 12, c)
    
    dots = repmat('-', 1, numel(s.manual.EndTime));
    dots(1) = '.';
    
    %plot(ds.Time(1:numel(c)), smoothed_datasets(i).Data(1:numel(c)), '-')
    plot_all(smoothed_datasets(i), {s.group.average, segTimes }, dots, {}, false)
    title(smoothed_datasets(i).Name)
end

num_cuts = numel(segTimes);

totErr = 0;
for i = 1:length(segTimes)
    totErr = totErr + min(abs(segTimes(i) - s.manual.EndTime));
end
avgErr = totErr/length(segTimes)



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
plot_all(plots, {s.manual.EndTime }, dots, {'Hand->Wheel Position', 'Hand->Wheel Velocity'});



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




