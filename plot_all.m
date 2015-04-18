function h = plot_all(t, plots, verticals)

size(plots, 2);

for iter = 0:size(plots, 2)-1
    z = iter+1;
    y = cell2mat(plots(:, iter+1));
    size(y, 2);
    for plot_col = 1:size(y, 2)
        plot_no = iter*3 + plot_col;
        subplot(size(plots, 2), size(y, 2), plot_no);
        color = 'r';
        switch plot_col
            case 1
                color = 'r';
            case 2 
                color = 'g';
            case 3
                color = 'b';
        end
        
        hold on
        plot(t(1:size(y, 1)), smooth(t(1:size(y, 1)), y(:, plot_col)), color)
        %plot(t(1:size(y, 1)), y(:, plot_col), color);
        
        for vert_set_idx = 1:numel(verticals)
            vert_set = cell2mat(verticals(vert_set_idx));
            for v = 1:numel(vert_set)
                ax = gca;
                ax.ColorOrderIndex = vert_set_idx;
                plot([vert_set(v), vert_set(v)], ylim)
            end
        end
    end
end

end