function s = resample_data( s, rng_min, rng_max, rng_pd )
%RESAMPLE_DATA Summary of this function goes here
%   Detailed explanation goes here

resample_range = rng_min+0.0001:rng_pd:rng_max-0.0001;

for i = 1:numel(s.data)
    s.data(i).pos.comp
    s.data(i).pos.comp = s.data(i).pos.comp.resample(resample_range);
    s.data(i).pos.mag = s.data(i).pos.mag.resample(resample_range);
    s.data(i).vel.comp = s.data(i).vel.comp.resample(resample_range);
    s.data(i).vel.mag = s.data(i).vel.mag.resample(resample_range);
    s.data(i).acc.comp = s.data(i).acc.comp.resample(resample_range);
    s.data(i).acc.mag = s.data(i).acc.mag.resample(resample_range);
end

for i = 1:numel(s.data)
    s.data(i).pos.mag.data = s.data(i).pos.mag.data/max(abs(s.data(i).pos.mag.data));
    s.data(i).vel.mag.data = s.data(i).vel.mag.data/max(abs(s.data(i).vel.mag.data));
    s.data(i).acc.mag.data = s.data(i).acc.mag.data/max(abs(s.data(i).acc.mag.data));
    
    for j = 1:3
        s.data(i).pos.comp.data(j) = s.data(i).pos.comp.data(j)/max(abs(s.data(i).pos.comp.data(j)));
        s.data(i).vel.comp.data(j) = s.data(i).vel.comp.data(j)/max(abs(s.data(i).vel.comp.data(j)));
        s.data(i).acc.comp.data(j) = s.data(i).acc.comp.data(j)/max(abs(s.data(i).acc.comp.data(j)));
    end
end
end



