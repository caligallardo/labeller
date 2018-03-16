function plotDecr(data, minutesShift, varargin)

shift = minutesShift * 2;
diffd = vertcat(data, zeros(shift, 1)) - vertcat(zeros(shift, 1), data);
shifted = diffd(shift+1:length(data)-shift);

figure()
plot((data-min(data))/2)
hold on
plot(shifted)
hold on
plot((shifted > 0)*2)

legend('data', strcat('shifted', num2str(shift)), 'shifted>0')

[n, m] = size(varargin);
if n == 1
    title(varargin{1})
end    

end