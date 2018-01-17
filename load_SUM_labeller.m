function [data, period] = load_SUM_labeller(filename, est_period)


loading = waitbar(0, strcat('Loading ', filename));

num = xlsread(filename);
waitbar(.5);

uncut_data = num(:,2); % SUM data is located in second column

for e = 1:length(uncut_data);
    if isnan(uncut_data(e));
        break % stop befor first nan
    end
end

data = uncut_data(1:e-1);

period = get_real_sampling_period(data, est_period);

waitbar(1);
close(loading);
end