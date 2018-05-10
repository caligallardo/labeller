function s = getEvents(filename, nameForTextFile)

    function dayNum = isDay(timeFromStart) % time in seconds
        dayNum = floor(timeFromStart / (60 * 60 * 24)) + 1;
    end

shiftEnd = 50;
thetaX = 60;
secondsPerDay = 60 * 60 * 24;
period = 30;
f_day = secondsPerDay / period

% get data from .txt file, as arrays
rawDataWithEpoch = load_SUM_labeller_from_txt(filename);
epochTimestamps = rawDataWithEpoch(:, 1);
timeSinceActivation = epochTimestamps - epochTimestamps(1);
tempReadings = rawDataWithEpoch(:, 2);
assignin('base', 'tempReadings', tempReadings);
assignin('base', 'timeSinceActivation', timeSinceActivation);

% interpolate temperature "data" every 30 sec
interpTime = transpose((30 * ceil(timeSinceActivation(1)/period)) : period : (period * floor(timeSinceActivation(end)/30)));
assignin('base', 'interpTime', interpTime);

interpData = interp1q(timeSinceActivation, tempReadings, interpTime);

% get peaks
[interpPks, interpLocs] = findpeaks(interpData(1:end-shiftEnd), ...
    'MinPeakProminence', 6, ...
    'MinPeakHeight', 35, ...
    'MinPeakDistance', 300, ...
    'MinPeakWidth', 10)
assignin('base', 'pks', interpPks);
assignin('base', 'locs', interpLocs);

% % desired time vector: 
% % (midnight on first whole day):(30 seconds):(end of last whole day)
interpTimeSinceMidnight = mod(interpTime + 60 * 60 * 5.5, secondsPerDay); % epoch time began at 5:30am IST
firstMidnightInterpIndex = find(interpTimeSinceMidnight == 0, 1);
lastMidnightInterpIndex = find(interpTimeSinceMidnight == 0, 1, 'last');

time = interpTime(firstMidnightInterpIndex : (lastMidnightInterpIndex-1));
data = interpData(firstMidnightInterpIndex : (lastMidnightInterpIndex-1));

firstEventInRangeInterpIndex = find((interpLocs - firstMidnightInterpIndex)>0, 1);
lastEventInRangeInterpLocIndex = find((interpLocs - lastMidnightInterpIndex)<0, 1, 'last');

assignin('base', 'data', data);
assignin('base', 'time', time);
assignin('base', 'interpTimeSinceMidnight', interpTimeSinceMidnight);
assignin('base', 'firstMidnightInterpIndex', firstMidnightInterpIndex);
assignin('base', 'lastEventInRangeInterpIndex', lastEventInRangeInterpLocIndex);
assignin('base', 'firstEventInRangeInterpIndex', firstEventInRangeInterpIndex);

eventLocations = interpLocs( firstEventInRangeInterpIndex : lastEventInRangeInterpLocIndex ) - firstMidnightInterpIndex + 1
peakValues = interpPks( firstEventInRangeInterpIndex : lastEventInRangeInterpLocIndex );

numDays = (lastMidnightInterpIndex - firstMidnightInterpIndex) / f_day;

% from here, time is now in seconds since the start of the
% first day. indices also measured by start of first day

numEvents = length(eventLocations);
A = horzcat(eventLocations, zeros(numEvents, 2));
s.eventTable = array2table(A, 'VariableNames', {'Peak_Location', 'Start_Time', 'End_Time'});

thetas1 = atan(-difference(interpData, -thetaX)/.1); % divide by .1 for horizontal compression
thetas2 = atan(difference(interpData, thetaX)/.1);
% theta1 - theta2: sharpness (angle) of increase
% mult by pi/2 - theta1 to favor changes that begin relatively flat
interpLightValues = (thetas1+thetas2).*(pi/2-abs(thetas1));
lightValues = interpLightValues(firstMidnightInterpIndex : (lastMidnightInterpIndex-1));

figure()
plot(interpData)
hold on
scatter(interpLocs, interpPks)

dailyEventCounts = zeros(numDays, 1);

for eventNum = 1:numEvents
    peakLoc = eventLocations(eventNum)
    peakValue = peakValues(eventNum);
    dayNum = isDay(peakLoc * period)
    % search within a third of a day before peak
    searchStart = peakLoc - floor(f_day / 3)
    if searchStart < 0
        searchStart = 1;
    end
    % if another event ended more recently than day/3, start search then
    if eventNum ~= 1
        searchStart = max(searchStart, endOfLastEvent)
    end
    
    today = data(f_day * floor(peakLoc/f_day)+1 : f_day * ceil(peakLoc/f_day));
    minDayTemp = min(today);
    maxDayTemp = max(today);
    
    % proportional distance from daily max rel to daily min, squared.
    % higher weight is placed on changes that occur at temps
    % low in relation to daily hi and lo
    relDistFromPeakTemp = ((maxDayTemp - data(searchStart:peakLoc))/(maxDayTemp - minDayTemp)).^2;
    lighting = searchStart + index_of_max(lightValues(searchStart:peakLoc) .* relDistFromPeakTemp);

    % cooling. finding longest region of continuous temp decline before
    % next event
    %isIncreasing = shiftAhead2smooth(peakLoc:end_i) >= 0;

    % end search at lowest point between this event and the next day or
    % event
    if eventNum == numEvents
        m = min(data(peakLoc:end));
        endSearch = find(data(peakLoc:end)-m==0, 1) + peakLoc;
    else
        upperSearchBound = min(eventLocations((eventNum + 1)), (dayNum + 1)*f_day);
        m = min(data(peakLoc:upperSearchBound));
        endSearch = find(data(peakLoc:upperSearchBound)-m==0, 1) + peakLoc;
    end  
    [mPks, mLocs] = findpeaks(data(peakLoc:endSearch), 'MinPeakProminence', .5)
    
    
    interpPkLoc = peakLoc + firstMidnightInterpIndex;
    lookAhead = interpData(interpPkLoc + mLocs) - interpData(interpPkLoc + mLocs + shiftEnd)
    iOM = index_of_max(lookAhead);
    mainPeakDiff = peakValue - interpData(interpPkLoc+shiftEnd)
    if iOM > 0
        if mainPeakDiff > lookAhead(iOM)
            mostProbablePeakInd = 0;
        else
            mostProbablePeakInd = mLocs(iOM);
        end
    else
        mostProbablePeakInd = 0;
    end
        
    eventEnd = peakLoc + mostProbablePeakInd
    endOfLastEvent = eventEnd;
    
    dailyEventCounts(dayNum) = dailyEventCounts(dayNum) + 1;
    
    % readjust for partial day
    peakLoc = peakLoc + firstMidnightInterpIndex;
    lighting= lighting+firstMidnightInterpIndex;
    eventEnd=eventEnd+firstMidnightInterpIndex;
    % add to table
    s.eventTable{eventNum, 'Peak_Location'} = peakLoc;
    s.eventTable{eventNum, 'Start_Time'} = lighting ;
    s.eventTable{eventNum, 'End_Time'} =  eventEnd;
    assignin('base', 'eventNum', eventNum);
end


a = table2array(s.eventTable)
aHeightRaw = size(a, 1);
for row = 1:aHeightRaw
    if a(row, 3) == 0
        a = a(1:row-1, :)
        break
    end
end

n = size(a, 1);

for i = 1:n
    hold on
    plot(a(i,2):a(i,3), interpData(a(i,2):a(i,3)), 'Color', [.5, 0, .5])
    hold on
    scatter(a(i,2), interpData(a(i,2)), 'green', 'Marker', 'x')
    hold on
    scatter(a(i,3), interpData(a(i,3)), 'red', 'Marker', 'x')
end

% mark beginning and end of whole-day time period that was searched
scatter(firstMidnightInterpIndex, interpData(firstMidnightInterpIndex), 'red', 'o');
scatter(lastMidnightInterpIndex, interpData(lastMidnightInterpIndex), 'red', 'o');
%plot(lightValues + 30)
%title(strcat(filename, '1:', num2str(shift1), ', 2:', num2str(shift2), ', smooth:', num2str(smooth)))

[numEvents, c] = size(a);
durations = a(:, 3) - a(:, 2);
sumArray = [numEvents, mean(durations)/2, numDays];

s.summaryTable = array2table(sumArray, 'VariableNames', {'Number_Of_Events', 'Average_Duration_in_Min', 'Number_Of_Days'});

% create text file
if nargin == 2,
    precision = ceil(log(epochTimestamps(1)));
    binArray = horzcat(interpTime + epochTimestamps(1), zeros(length(interpData), 1));
    n = size(a, 1);
    for i = 1 : n
        if a(i, 1) == 0
            break
        end
        binArray(a(i, 2):a(i, 3), 2) = 1;
    end
    dlmwrite(nameForTextFile, binArray, 'precision', precision);
end

end