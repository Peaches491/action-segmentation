function [ s ] = build_data_struct( data_dir, types, start_pct, end_pct )
%BUILD_DATA_STRUCT Summary of this function goes here
%   Detailed explanation goes here

traj = struct('comp', [], 'mag', [], 't', []);
traj_pos_vel = struct('pos', struct(traj), ...
    'vel', struct(traj), ...
    'acc', struct(traj));

min_t = realmax('double');
max_t = 0;

s = struct();
s.ObjManip = [];
s.FixManip = [];
s.FixObj = [];

s.manual = import_manual_segments(strcat(data_dir, 'manual_segment.csv'));
s.states = import_state_changes(strcat(data_dir, 'states.csv'));

for i = 1:size(types)
    data = csvread(strcat(data_dir, cell2mat(types(i, :).FileName)), 1, 0);
    t = data(:, 1); 
    st_idx = int32(size(t,1)*start_pct) + 1;
    end_idx = int32(size(t,1)*end_pct);
    t = t(st_idx:end_idx);
    
    min_t = min(min_t, min(t));
    max_t = max(max_t, max(t));
end

ns2sec = @(ns_val) (ns_val - min_t)./(1000000000.0);

for i = 1:size(types)
    new_s = struct(traj_pos_vel);
    
    data = csvread(strcat(data_dir, cell2mat(types(i, :).FileName)), 1, 0);
    t = ns2sec(data(:, 1));
    st_idx = int32(size(t,1)*start_pct) + 1;
    end_idx = int32(size(t,1)*end_pct);
    t = t(st_idx:end_idx);
    x = data(st_idx:end_idx, 2:end);
    
    dx = x(2:end, :) - x(1:end-1, :);
    dt = t(2:end) - t(1:end-1);
    v = bsxfun (@rdivide, dx, dt);
    
    ddx = dx(2:end, :) - dx(1:end-1, :);
    a = bsxfun (@rdivide, ddx, dt(1:end-1));
    
    mag = @(v)(sqrt(v(:, 1).^2 + v(:, 2).^2 + v(:, 3).^2));
    
    new_s.pos.comp = x;
    new_s.pos.mag = mag(x);
    new_s.pos.t = t;
    
    new_s.vel.comp = v;
    new_s.vel.mag = mag(v);
    new_s.vel.t = t(1:numel(new_s.vel.mag));
    
    new_s.acc.comp = a;
    new_s.acc.mag = mag(a);
    new_s.acc.t = t(1:numel(new_s.acc.mag));
    
    if  strcmp(types(i, :).FromClass, 'Object') && ...
        strcmp(types(i, :).ToClass, 'Manipulator')
        s.ObjManip = [s.ObjManip, new_s];
    elseif strcmp(types(i, :).FromClass, 'Fixture') && ...
            strcmp(types(i, :).ToClass, 'Manipulator')
        s.FixManip = [s.FixManip, new_s];
    elseif strcmp(types(i, :).FromClass, 'Fixture') && ...
            strcmp(types(i, :).ToClass, 'Object')
        s.FixObj = [s.FixObj, new_s];
    end
end


% for i = 1:size(s.FixManip)
%     s.FixManip(i).pos.t = ns2sec(s.FixManip(i).pos.t);
%     s.FixManip(i).vel.t = ns2sec(s.FixManip(i).vel.t);
%     s.FixManip(i).acc.t = ns2sec(s.FixManip(i).acc.t);
% end
% 
% for i = 1:size(s.FixObj)
%     s.FixObj(i).pos.t = ns2sec(s.FixObj(i).pos.t);
%     s.FixObj(i).vel.t = ns2sec(s.FixObj(i).vel.t);
%     s.FixObj(i).acc.t = ns2sec(s.FixObj(i).acc.t);
% end
% 
% for i = 1:size(s.ObjManip)
%     s.ObjManip(i).pos.t = ns2sec(s.ObjManip(i).pos.t);
%     s.ObjManip(i).vel.t = ns2sec(s.ObjManip(i).vel.t);
%     s.ObjManip(i).acc.t = ns2sec(s.ObjManip(i).acc.t);
% end

s.min_ns = min_t;
s.max_ns = max_t;

% Replace all zero t withj beginning of file
s.manual.StartTime(s.manual.StartTime==0) = data(st_idx, 1);
s.states.Time(s.states.Time==0) = data(st_idx, 1);

% Replace all negative t with the end of the file
s.manual.EndTime(s.manual.EndTime<0) = data(end_idx, 1);
s.states.Time(s.states.Time<0) = data(end_idx, 1);

% Convert times for manual segmentations and state transitions
s.manual.StartTime = ns2sec(s.manual.StartTime);
s.manual.EndTime = ns2sec(s.manual.EndTime);
s.states.Time = ns2sec(s.states.Time);

end



