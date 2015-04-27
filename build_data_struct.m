function [ s ] = build_data_struct( data_dir, types, start_pct, end_pct)
%BUILD_DATA_STRUCT Summary of this function goes here
%   Detailed explanation goes here

traj = struct('comp', timeseries, 'mag', timeseries);
traj_pos_vel = struct('pos', struct(traj), ...
                      'vel', struct(traj), ...
                      'acc', struct(traj));

min_t_start = realmax('double');
max_t_start = 0;

min_t_end = realmax('double');
max_t_end = 0;

s = struct('data', [], 'manual', [], 'states', []);

s.manual = import_manual_segments(strcat(data_dir, 'manual_segment.csv'));
s.states = import_state_changes(strcat(data_dir, 'states.csv'));
s.group = import_group_segments(strcat(data_dir, 'group_segment.csv'));

for i = 1:size(types)
    data = csvread(strcat(data_dir, cell2mat(types(i, :).FileName)), 1, 0);
    t = data(:, 1); 
    st_idx = int32(size(t,1)*start_pct) + 1;
    end_idx = int32(size(t,1)*end_pct);
    t = t(st_idx:end_idx);
    
    
    min_t_start = min(min_t_start, min(t));
    max_t_start = max(max_t_start, min(t));
    
    min_t_end = min(min_t_end, max(t));
    max_t_end = max(max_t_end, max(t));
end

ns2sec = @(ns_val) (ns_val - max_t_start)./(1000000000.0);

for i = 1:size(types)
    new_s = struct(traj_pos_vel);
    
    data = csvread(strcat(data_dir, cell2mat(types(i, :).FileName)), 1, 0);
    t = ns2sec(data(:, 1));
    st_idx = int32(size(t,1)*start_pct) + 1;
    end_idx = int32(size(t,1)*end_pct);
    t = t(st_idx:end_idx);
    
    
    mag = @(v)(sqrt(v(:, 1).^2 + v(:, 2).^2 + v(:, 3).^2));
    
    x_comp = data(st_idx:end_idx, 2:end);
    x_mag = mag(x_comp);
    
    dt = t(2:end) - t(1:end-1);
    dx_comp = x_comp(2:end, :) - x_comp(1:end-1, :);
    dx_mag = x_mag(2:end, :) - x_mag(1:end-1, :);
    v_comp = bsxfun (@rdivide, dx_comp, dt);
    v_mag = bsxfun (@rdivide, dx_mag, dt);
    
    ddx_comp = dx_comp(2:end, :) - dx_comp(1:end-1, :);
    ddx_mag = dx_comp(2:end, :) - dx_comp(1:end-1, :);
    a_comp = bsxfun (@rdivide, ddx_comp, dt(1:end-1));
    a_mag = bsxfun (@rdivide, ddx_mag, dt(1:end-1));
    
    
    ts_name = strcat(types(i, :).FromClass, ':', types(i, :).FromName, ' -> ', ...
        types(i, :).ToClass, ':', types(i, :).ToName);
    ts_name = strrep(ts_name, '_', '\_');
    
    new_s.pos.comp = timeseries(x_comp, t);
    new_s.pos.mag = timeseries(x_mag, t);
    new_s.pos.comp.Name = ts_name;
    new_s.pos.mag.Name = ts_name;
    
    new_s.vel.comp = timeseries(v_comp, t(1:size(v_comp, 1)));
    new_s.vel.mag = timeseries(v_mag, t(1:size(v_mag, 1)));
    new_s.vel.comp.Name = ts_name;
    new_s.vel.mag.Name = ts_name;
    
    new_s.acc.comp = timeseries(a_comp, t(1:size(a_comp, 1)));
    new_s.acc.mag = timeseries(a_mag, t(1:size(a_mag, 1)));
    new_s.acc.comp.Name = ts_name;
    new_s.acc.mag.Name = ts_name;
	
    s.data = [s.data, new_s];
%     if  strcmp(types(i, :).FromClass, 'Object') && ...
%         strcmp(types(i, :).ToClass, 'Manipulator')
%         s.ObjManip = [s.ObjManip, new_s];
%     elseif strcmp(types(i, :).FromClass, 'Fixture') && ...
%             strcmp(types(i, :).ToClass, 'Manipulator')
%         s.FixManip = [s.FixManip, new_s];
%     elseif strcmp(types(i, :).FromClass, 'Fixture') && ...
%             strcmp(types(i, :).ToClass, 'Object')
%         s.FixObj = [s.FixObj, new_s];
%     end
end

s.min_ns_start = min_t_start;
s.max_ns_start = max_t_start;

s.min_ns_end = min_t_end;
s.max_ns_end = max_t_end;

% Replace all zero t withj beginning of file
s.manual.StartTime(s.manual.StartTime==0) = data(st_idx, 1);
s.states.Time(s.states.Time==0) = data(st_idx, 1);
for col = 1:3
    for row = 1:size(s.group, 1)
        if s.group{row, col} == 0
            s.group{row, col} = data(st_idx, 1);
        end
        if s.group{row, col} < 0
            s.group{row, col} = data(end_idx, 1);
        end
        s.group{row, col} = ns2sec(s.group{row, col});
    end
end


% Replace all negative t with the end of the file
s.manual.EndTime(s.manual.EndTime<0) = data(end_idx, 1);
s.states.Time(s.states.Time<0) = data(end_idx, 1);


% Convert times for manual segmentations and state transitions
s.manual.StartTime = ns2sec(s.manual.StartTime);
s.manual.EndTime = ns2sec(s.manual.EndTime);
s.states.Time = ns2sec(s.states.Time);

s.group.average = sum(s.group{:, 1:3}, 2)/3.0;
s.group.std_dev = std(s.group{:, 1:3}, 0, 2);

end



