function avg = non0avg( A )

[m,n] = size(A);
avg = 0;
count = 0;
for i = 1:m
    for j = 1:n
        if (A(i,j)~=0)&& isfinite(A(i,j))
            avg = avg + A(i,j);
            count = count + 1;
        end
    end
end

avg = avg/count;

end

