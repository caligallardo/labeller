function index = max_index(A)
current_max = - inf;
for i = 1:length(A);
    if A(i) > current_max;
        current_max = A(i);
        index = i;
    end
end

end
