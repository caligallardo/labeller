function index = index_of_max(A)
if isempty(A)
    index = 0;
    return
else
    current_max = A(1);
    index = 1;
end
    
for i = 1:length(A);
    if A(i) > current_max;
        current_max = A(i);
        index = i;
    end
end

end
