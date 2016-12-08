function [data, period] = load_SUM_labeller(filename, est_period)


loading = waitbar(0, strcat('Loading ', filename));
num = xlsread(filename);
waitbar(.5);

uncut_data = num(:,2); % SUM data is located in second column

for e = 1:length(uncut_data);
    if isnan(uncut_data(e));
        break
    end
end

data = uncut_data(1:e-1);

num_samples = length(data);
y = fft(data);
z = abs(y);
z = z(1: round(num_samples/2) - 1);
expected = round(num_samples * est_period / 60 /24); % expected number of days in the dataset (based on 5 min estimation)
range = round(expected * .25); % consider possible day lengths within 25% of the estimated
% get main signal (max on the fft) whose frequency is nearish to an
% estimated day
real_days_in_dataset = max_index(z(expected - range : expected + range)) + (expected - range);
samples_per_day = num_samples / real_days_in_dataset;
samples_per_min = samples_per_day / (60 * 24);

period = 1 / samples_per_min;
waitbar(1);
close(loading);
end