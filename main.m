clc; clear all;
addpath 'data/'
addpath 'data/mount_tire/'
addpath 'data/remove_tire/'

format long
data = csvread('data/remove_tire/world-wheel_LF.csv', 1, 0);
t = (data(:, 1) - data(1))./(1000000000);

start_pct = 0.0;

st_idx = int32(size(t,1)*start_pct) + 1
%st_idx = 1
t = t(st_idx:end);
x = data(st_idx:end, 2:end);

dx = x(2:end, :) - x(1:end-1, :);
dt = t(2:end) - t(1:end-1);
v = bsxfun (@rdivide, dx, dt);

ddx = dx(2:end, :) - dx(1:end-1, :);
a = bsxfun (@rdivide, ddx, dt(1:end-1));

clf
plot_all(t, {x, v, a})


%highlight(x(t_1, 1), x(t_2, 1))
