function h = plot_all(plots, verticals, dots, titles)

title_idx = 1;
largest_range = [realmax, realmax]*-1;
axes_flip = [-1, 1];
handles = [];

for iter = 0:size(plots, 2)-1
    
    y = cell2mat(plots(:, iter+1));
    t = y(:, 1);
    y = y(:, 2:end);
    
    for plot_col = 1:size(y, 2)
        
        [size(plots, 2), size(y, 2)];
        plot_no = iter*size(y, 2) + plot_col;
        
        h = subplot(size(plots, 2), size(y, 2), plot_no);
        handles = [handles, h];
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
        
        plot(t(1:size(y(:, plot_col), 1)), y(:, plot_col), color);
        largest_range = bsxfun(@max, largest_range, xlim.*axes_flip)
        
        if title_idx <= numel(titles)
            title(titles(title_idx))
        end
        title_idx = title_idx + 1;
        
        for vert_set_idx = 1:numel(verticals)
            vert_set = cell2mat(verticals(vert_set_idx));
            for v = 1:numel(vert_set)
                ax = gca;
                ax.ColorOrderIndex = vert_set_idx;
                
                n=25;
                x_vals = ones(1, n)*vert_set(v);
                y_vals = linspace(min(ylim),max(ylim),n);
                
                plot(x_vals, y_vals, dots(vert_set_idx))
            end
        end
    end
end

for i = 1:numel(handles)
   axes(handles(i));
   xlim(largest_range.*axes_flip);
end

end