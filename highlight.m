function [ h ] = highlight( t_1, t_2 )
%HIGHLIGHT Summary of this function goes here
%   Detailed explanation goes here

y_lim = get(gca,'ylim')

X = [t_1, t_2, t_2, t_1];
Y = [y_lim(1), y_lim(1), y_lim(2), y_lim(2)];

h = patch(X, Y, 'r');
set(h, 'FaceAlpha', 0.2);
set(h, 'EdgeColor', 'none');

end

