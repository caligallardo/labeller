function data = load_SUM_labeller_from_txt(filename)
% out puts array
% first col epoch time
% second col temp

loading = waitbar(0, strcat('Loading ', filename));

T = readtable(filename);

tt = T(:, {'Time', 'SUMTemp'});

data_with_nan = table2array(tt);
data = removeNaN(data_with_nan, 2);

close(loading);
end