function [ error ] = calcError(y,t, p1, p2)
 error = 0;
 a = [y(p1) t(p1)];
 b = [y(p2) t(p2)];
  
 for i = p1+1:p2-1
     x = [y(i) t(i)];
     
     d = distToLine(a,b,x);
     error = error + d;
 end


end

