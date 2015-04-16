clc; clear all; close all;
addpath 'data/'
addpath 'data/mount_tire/'
addpath 'data/remove_tire/'

format long
x = csvread('data/remove_tire/world-wheel_LF.csv', 1, 0);
%x = csvread('data/remove_tire/world-wheel_LF.csv', 700, 0);
%x = x(1:800, :)

hold on
plot(x(:, 1), x(:, 2), 'r');
plot(x(:, 1), x(:, 3), 'g');
plot(x(:, 1), x(:, 4), 'b');

t_1 = 300;
t_2 = 320;
highlight(x(t_1, 1), x(t_2, 1))