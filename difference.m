function y =  difference(data, shift, varargin)
% returns array where
% y(i) = y(i+10) - y(i)
% amount increase in 10 future
% last shift values are 0

% uncut = vertcat(data, zeros(shift, 1)) - vertcat(zeros(shift, 1), data);
%     y = uncut(shift+1:length(uncut)-shift);
%     y = vertcat(y, zeros(shift, 1));

n= length(data);
absShift = abs(shift);
diffs = data(absShift+1:n) - data(1:n-absShift);

if shift >= 0
    y = vertcat(diffs, zeros(absShift, 1));
else
    y = vertcat(zeros(absShift, 1), diffs);
end


end
