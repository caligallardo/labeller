function [beginning, ending] = getLongestZeroRegion(data)
% data should be a column vector
    oneLocs = find(data);
    oneLocsAdj = vertcat(0, oneLocs, (length(data)+1));
    sizesOfGaps = diff(oneLocsAdj);
    largestGapEnd_ithGap = index_of_max(sizesOfGaps);
    beginning = oneLocsAdj(largestGapEnd_ithGap)+1;
    ending = oneLocsAdj(largestGapEnd_ithGap+1)-1;
end