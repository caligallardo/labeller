function [data, num_days] = load_SUM(filename, log_rate)

num = xlsread(filename);
%log_rate = 10; %min

uncut_data = num(:,2); % SUM data is located in second column

for e = 1:length(uncut_data);
    if isnan(uncut_data(e));
        break
    end
end

data = uncut_data(1:e-1);

num_days = length(data) / ((60 / log_rate) * 24);
end