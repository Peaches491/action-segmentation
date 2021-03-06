clc; clear all;
addpath 'data/'
addpath 'data/mount_tire/'
addpath 'data/remove_tire/'
addpath 'emgm/'
addpath 'vbgm/'

addpath 'imports/'

addpath 'change_detection' 
addpath 'change_detection/RULSIF'

format long

data_dir = 'data/remove_tire/';

types = import_file_types(strcat(data_dir, '/file_types.csv'));

% Define start and end points
start_pct = 0.0;
end_pct = 0.95;

data = build_data_struct(data_dir, types, start_pct, end_pct);
data


% Convert NS to seconds
ns2sec = @(ns_val) max((ns_val - data.min_ns)./(1000000000.0), 0);


dataset = data.ObjManip(1);
speed = smooth(dataset.vel.mag, 50);
%speed = smooth(sqrt(v(:,1).^2 + v(:,2).^2 + v(:,3).^2), 50);

t = dataset.vel.t;


%% Change-Point Detection in Time-Series Data by Relative Density Ratio Estimation
%References:
%Liu, S., Yamada, M., Collier, N., Sugiyama, M. Change-point detection in time-series data by relative density-ratio estimation. arXiv 1203.0453 (2012) 
%Yamada, M., Suzuki, T., Kanamori, T., Hachiya, H., Sugiyama, M. Relative density-ratio estimation for robust distribution comparison. In: Advances in Neural Information Processing Systems 24. (2011) 594--602
% alpha = .0;
% 
% n = 50;
% k = 10;
% 
% score1 = change_detection(speed',n,k,alpha);
% score2 = change_detection(speed(:,end:-1:1)',n,k,alpha);
% 
% subplot(2,1,1);
% plot(speed, 'b-', 'linewidth',2);
% %axis([-inf,size(speed,2),-inf,inf])
% title('Original Signal')
% 
% subplot(2,1,2);
% score2 = score2(end:-1:1);
% 
% % 2*n+k-2 is the size of the "buffer zone".
% plot([zeros(1,2*n-2+k),score1 + score2], 'r-', 'linewidth',2);
% %axis([-inf,size(speed,2),-inf,inf])
% title('Change-Point Score')


%% Windowed KS-test 

 figure;
 plot(t(1:length(speed)),speed);
 hold on
% 
% 
% points = [];
% p1 = 220;
% ws = 20;
% 
% s = round(max(p1-ws/2, 1));
% e = round(min(p1+ws/2, length(speed)));
% testSeg = speed(s:e); 
% 
% for m = e:1:length(speed)
% 
% newe = round(min(m, length(speed)));    
% newSeg = speed(s:newe); 
% length(newSeg)
% [h p] = kstest2(newSeg,testSeg, 'alpha', 1e-2)
% if h == 1
%     break;
%     points = [points newe];
% end
% end
% 
% for n = 1:1:s
% news = round(max(s-n, 1));
% newSeg = speed(news:e);
% [h p] = kstest2(testSeg,newSeg, 'alpha', 1e-2)
% if h == 1
%     break;
%      points = [points news];
% end
% 
% end
% 
% plot([t(s) t(s)],[0 2], 'r');
% plot([t(e) t(e)],[0 2], 'r');
% plot([t(newe) t(newe)],[0 2], 'b');
% plot([t(news) t(news)],[0 2], 'b');
% 
% for i = 1:length(points)
%     plot([t(points(i)) t(points(i))],[0 2], 'g');
% end

%%

% p1 = 55;
% s = round(max(p1-5, 1));
% e = round(min(p1+5, length(speed)));
% lastSeg = speed(s:e)./norm(speed(s:e));
% 
% for ws = 6:5:100;
%  
%  s = round(max(p1-ws, 1));
%  e = round(min(p1+ws, length(speed)));
%  newSeg = speed(s:e)./norm(speed(s:e));
%  
%  [h p] = kstest2(lastSeg,newSeg, 'alpha', 1e-10)
%  
%  if h == 1
%      break
%  end
%      
%  lastSeg = newSeg;
% end
%  
%  plot([t(s) t(s)],[0 2], 'r');
%  plot([t(e) t(e)],[0 2], 'r');
%  plot([t(p1) t(p1)],[0 2], 'b');

 %% Near Zero 
%  d = .03
%  w = 3
%  points = [];
%  for i = 1:length(speed)
%     s = round(max(i-w, 1));
%     e = round(min(i+w, length(speed)));
%     s1 = mean(speed(s:i)) < d;
%     s2 = mean(speed(i:e)) < d;
%     [s1 s2 i]
%     if xor(s1, s2)
%     display('here')
%     points = [points i]
%     end
%     
%      
%  end
%  
%  for i = 1:length(points)
%     plot([t(points(i)) t(points(i))],[0 2], 'r');
%  end
 
 %% Segmentation
 g = zeros(length(speed), length(speed));
 error = 0; 
 p1 = 1; p2 = 5;
 
 for p1 = 1:length(speed)
     for p2 = p1+1:length(speed)
     error = calcError(speed, t, p1, p2);
 
     g(p1, p2) = .5 + error;
     end
 end
 g = sparse(g);
 [dist,path,pred] = graphshortestpath(g, 1, length(speed))
 
  for i = 1:length(path)
     plot([t(path(i)) t(path(i))],[0 2], 'r');
  end
 
 
