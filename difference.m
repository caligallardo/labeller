function y =  difference(data, shift)
% returns array where
% y(i) = y(i+10) - y(i)
% amount increase in 10 future

uncut = vertcat(data, zeros(shift, 1)) - vertcat(zeros(shift, 1), data);
y = uncut(shift+1:length(uncut)-shift);

end
