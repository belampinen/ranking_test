function m = ranks2m(r)
%
rj        = mean(r);                % Average rank/region
rjm       = repmat(rj, [size(r,1) 1]); 
%
rd        = (r - rjm);              % Deviation from average
m         = sum(rd(:).^2);          % metric

end