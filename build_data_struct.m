function [ s ] = build_data_struct( data_dir, types, start_pct, end_pct )
%BUILD_DATA_STRUCT Summary of this function goes here
%   Detailed explanation goes here

traj = struct('components', [], 'magnitude', [], 'timestamps', []);
traj_pos_vel = struct('pos', struct(traj), ...
    'vel', struct(traj), ...
    'acc', struct(traj));

ns2sec = @(ns_val) max((ns_val - data(1))./(1000000000.0), 0);
t = ns2sec(data(:, 1)); 

s = struct();
s.ObjManip = [];
s.FixManip = [];
s.FixObj = [];
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
    
    new_s.pos.components = x;
    new_s.pos.magnitude = mag(x);
    new_s.pos.timestamps = t;
    
    new_s.vel.components = v;
    new_s.vel.magnitude = mag(v);
    new_s.vel.timestamps = t(1:numel(new_s.vel.magnitude));
    
    new_s.acc.components = a;
    new_s.acc.magnitude = mag(a);
    new_s.acc.timestamps = t(1:numel(new_s.acc.magnitude));
    
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

end

