function convertForSUMsarizer(filename, newFilename)

data = load_SUM_labeller_from_txt(filename);
t = data(:, 1);

time = datetime(t + 60 * 60 * 5.5, 'convertfrom', 'posixtime', 'Format', 'yyyy-MM-dd hh:mm:ss');

%T = table(time, data(:, 2), 'VariableNames', {'Time', 'Temperature'});
time=cellstr(time);
temps = num2cell(data(:, 2), 4);

assignin('base', 'time', time)
assignin('base', 'temps', temps)

C = horzcat(cellstr(time), temps)

assignin('base', 'time', time)
assignin('base', 'data', data)
assignin('base', 'C', C)


fileID = fopen(newFilename,'w');
formatSpec = '%s, %f\n';
[nrows,ncols] = size(C);
for row = 1:nrows
    fprintf(fileID,formatSpec,C{row,:});
end
fclose(fileID);
end