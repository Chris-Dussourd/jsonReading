%Check if item1 contains item2 (if item2 is a string or character array)
%Check if item1 equals item2 (if item2 is a number)
%Returns true if it does contain or is equal
function match = check_if_contains(item1,item2)
if class(item1)=="double"
    match=false; %If item1 is a number return false (don't compare to IDs)
elseif class(item2)=="char" || class(item2)=="string"
    %Check if item 1 contains item 2
    match=contains(item1,item2,'IgnoreCase',true);
elseif class(item2)=="double"
    %If user typed in a number, we should also check as if it is a character. Check if contains
    match=contains(item1,num2str(item2),'IgnoreCase',true);
else
    match=false;
end

