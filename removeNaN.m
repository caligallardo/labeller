function c = removeNaN(a, j)
% returns matrix where all rows where the element in the jth column is nan
% are removed

[n, m] = size(a);
b = zeros(n, m);
i_b = 1;
for i_a = 1 : n
    if ~isnan(a(i_a, j))
        b(i_b, :) = a(i_a, :);
        i_b = i_b + 1;
    end
end

c = b(1:i_b-1, :);
end