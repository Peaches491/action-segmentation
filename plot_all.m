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
        plot(t(1:size(y, 1)), y(:, plot_col), color)
        %plot(t(1:size(y, 1)), y(:, plot_col), color);
        
        for vert_set_idx = 1:numel(verticals)
            vert_set = cell2mat(verticals(vert_set_idx));
            for v = 1:numel(vert_set)
                ax = gca;
                ax.ColorOrderIndex = vert_set_idx;
                
                n=25;
                x_vals = ones(1, n)*vert_set(v);
                y_vals = linspace(min(ylim),max(ylim),n);
                
                if vert_set_idx == 1
                    plot(x_vals, y_vals, '.')
                else
                    plot(x_vals, y_vals)
                end
            end
        end
    end
end

end