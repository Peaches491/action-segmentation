clc; clear all;
addpath 'data/'
addpath 'data/mount_tire/'
addpath 'data/remove_tire/'
addpath 'emgm/'
addpath 'vbgm/'

addpath 'imports/'

addpath 'change_detection' 
addpath 'change_detection/RULSIF'
format long

data_dir = 'data/remove_tire/'
dir(strcat(data_dir, '*.csv'))

manual = import_manual_segments(strcat(data_dir, 'manual_segment.csv'));
states = import_state_changes(strcat(data_dir, 'states.csv'));
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

speed = smooth(sqrt(v(:,1).^2 + v(:,2).^2 + v(:,3).^2), 50);

%% Change-Point Detection in Time-Series Data by Relative Density Ratio Estimation
%References:
%Liu, S., Yamada, M., Collier, N., Sugiyama, M. Change-point detection in time-series data by relative density-ratio estimation. arXiv 1203.0453 (2012) 
%Yamada, M., Suzuki, T., Kanamori, T., Hachiya, H., Sugiyama, M. Relative density-ratio estimation for robust distribution comparison. In: Advances in Neural Information Processing Systems 24. (2011) 594--602
% alpha = .0;
% 
% n = 50;
% k = 10;
% 
% score1 = change_detection(speed',n,k,alpha);
% score2 = change_detection(speed(:,end:-1:1)',n,k,alpha);
% 
% subplot(2,1,1);
% plot(speed, 'b-', 'linewidth',2);
% %axis([-inf,size(speed,2),-inf,inf])
% title('Original Signal')
% 
% subplot(2,1,2);
% score2 = score2(end:-1:1);
% 
% % 2*n+k-2 is the size of the "buffer zone".
% plot([zeros(1,2*n-2+k),score1 + score2], 'r-', 'linewidth',2);
% %axis([-inf,size(speed,2),-inf,inf])
% title('Change-Point Score')


%% Windowed KS-test 

figure;
plot(t(1:length(speed)),speed);
hold on


points = [];
p1 = 220;
ws = 20;

s = round(max(p1-ws/2, 1));
e = round(min(p1+ws/2, length(speed)));
testSeg = speed(s:e); 

for m = e:1:length(speed)

newe = round(min(m, length(speed)));    
newSeg = speed(s:newe); 
length(newSeg)
[h p] = kstest2(newSeg,testSeg, 'alpha', 1e-2)
if h == 1
    break;
    points = [points newe];
end
end

for n = 1:1:s
news = round(max(s-n, 1));
newSeg = speed(news:e);
[h p] = kstest2(testSeg,newSeg, 'alpha', 1e-2)
if h == 1
    break;
     points = [points news];
end

end

plot([t(s) t(s)],[0 2], 'r');
plot([t(e) t(e)],[0 2], 'r');
plot([t(newe) t(newe)],[0 2], 'b');
plot([t(news) t(news)],[0 2], 'b');

for i = 1:length(points)
    plot([t(points(i)) t(points(i))],[0 2], 'g');
end



