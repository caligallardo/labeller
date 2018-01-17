function data = load_SUM_labeller_from_txt(filename)
% out puts array
% first col epoch time
% second col temp

loading = waitbar(0, strcat('Loading ', filename));

T = readtable(filename);

tt = T(:, {'Time', 'SUMTemp'});

data = table2array(tt);

waitbar(1);
close(loading);
end