function s = resample_data( s, rng_min, rng_max, rng_pd )
%RESAMPLE_DATA Summary of this function goes here
%   Detailed explanation goes here

resample_range = rng_min+0.0001:rng_pd:rng_max-0.0001;

for i = 1:numel(s.ObjManip)
    s.ObjManip(i).pos.comp = s.ObjManip(i).pos.comp.resample(resample_range);
    s.ObjManip(i).pos.mag = s.ObjManip(i).pos.mag.resample(resample_range);
    s.ObjManip(i).vel.comp = s.ObjManip(i).vel.comp.resample(resample_range);
    s.ObjManip(i).vel.mag = s.ObjManip(i).vel.mag.resample(resample_range);
    s.ObjManip(i).acc.comp = s.ObjManip(i).acc.comp.resample(resample_range);
    s.ObjManip(i).acc.mag = s.ObjManip(i).acc.mag.resample(resample_range);
end
for i = 1:numel(s.FixManip)
    s.FixManip(i).pos.comp = s.FixManip(i).pos.comp.resample(resample_range);
    s.FixManip(i).pos.mag = s.FixManip(i).pos.mag.resample(resample_range);
    s.FixManip(i).vel.comp = s.FixManip(i).vel.comp.resample(resample_range);
    s.FixManip(i).vel.mag = s.FixManip(i).vel.mag.resample(resample_range);
    s.FixManip(i).acc.comp = s.FixManip(i).acc.comp.resample(resample_range);
    s.FixManip(i).acc.mag = s.FixManip(i).acc.mag.resample(resample_range);
end
for i = 1:numel(s.FixObj)
    s.FixObj(i).pos.comp = s.FixObj(i).pos.comp.resample(resample_range);
    s.FixObj(i).pos.mag = s.FixObj(i).pos.mag.resample(resample_range);
    s.FixObj(i).vel.comp = s.FixObj(i).vel.comp.resample(resample_range);
    s.FixObj(i).vel.mag = s.FixObj(i).vel.mag.resample(resample_range);
    s.FixObj(i).acc.comp = s.FixObj(i).acc.comp.resample(resample_range);
    s.FixObj(i).acc.mag = s.FixObj(i).acc.mag.resample(resample_range);
    
end

end

