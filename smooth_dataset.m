function [ ds ] = smooth_dataset( ds, varargin )

t = ds.Time;
x = ds.Data;

if nargin > 3
    new_x = cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x, varargin{3}, varargin{2})), num2cell(x, 1), 'UniformOutput', false));
elseif nargin > 2
    new_x = cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x, varargin{2}, 'moving')), num2cell(x, 1), 'UniformOutput', false));
else
    new_x = cell2mat(cellfun(@(x)(smooth(t(1:numel(x)), x)), num2cell(x, 1), 'UniformOutput', false));
end

ds.Data = new_x;

end

