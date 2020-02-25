%Checks to see if user_val is contained in items in a json file selected by a user.
%    file_directory - opens this directory to allow user to select a json file
%    user_val - a character/word/phrase supplied by user to check through the items in the json file
%    returns: found_items - a cell array of the items that contains the user_val
function found_items = check_json(file_directory,user_val)

%If user value is missing. Log a message asking user to enter a value.
if isempty(user_val)
    found_items='Please enter a value to search for. You did not enter anything.';
else
    %Open a browser to have a user select the file to parse 
    if ~isempty(file_directory) %If file directory is supplied
        [file,path]=uigetfile([file_directory '\*.json'],'Select a json file to run');
    else
        [file, path] = uigetfile('*.json','Select a json file to run');
    end
    if isequal(file,0) %User selected cancel
        found_items='A file was not selected. Please try again.';
    elseif ~strcmp(file(end-3:end),"json")
        found_items='Please select a .json file. You selected a different file type';
    else
        json_fileID=fopen([path '\' file]);
        json_str=char(fread(json_fileID,inf)');

        %Abstract the JSON-formatted text string
        json_info = jsondecode(json_str);

        %Convert character to number if user enters a number
        if ~isnan(str2double(user_val))
            user_val=str2double(user_val);
        end

        matches=0; %Number of matches found. Initialize to zero.
        item_found=[]; %Initialize item found array
        total_items=length(json_info.items); %Store the count of the items
        item_count=1;
        cat_to_itemnum=[];
        %Loop over the list of items in the json file
        while item_count<=length(json_info.items)
            item = json_info.items{item_count};
            match=false; %default to no match (user entered value is not found)
            %Check if we already found a match for this item
            if item_count<=length(cat_to_itemnum) && ~isempty(find(item_found==cat_to_itemnum(item_count),1))
                match=0; %Already found a match, don't loop over subcategory
            elseif ~isstruct(item) %Check if item is not a structure
                %Check if item is a match
                match=check_if_contains(item,user_val);
            else
                %Convert structure to cell array and loop over values
                values_temp=struct2cell(item);
                values=reshape(values_temp,[size(values_temp,1)*size(values_temp,2) 1]); %reshape matrix into a vector
                key=1;
                while (key<=length(values) && ~match)
                    %Check if the key value pair is not a structure
                    if ~isstruct(values{key})
                        %It's not a structure, so check if it contains user value
                        match=check_if_contains(values{key},user_val);
                    else
                        %It's a structure. Add it to the items array with an indicator to which item it originally came from
                        previous_length=length(json_info.items);
                        json_info.items{previous_length+1}=values{key};
                        %Store the actual item number. If there is a match in the subcategory, save the original item number as a match (not the subcategory)
                        if item_count<=total_items
                            cat_to_itemnum(previous_length+1)=item_count;
                        else
                            cat_to_itemnum(previous_length+1)=cat_to_itemnum(item_count);
                        end
                    end
                    key=key+1;
                end
            end
            %If a match was found, save the index in the items structure
            if match 
                matches=matches+1;
                if item_count<=total_items
                    item_found(matches)=item_count;
                else
                    item_found(matches)=cat_to_itemnum(item_count);
                end
            end
            item_count=item_count+1;
        end

        %Return the struct with the found items
        if ~isempty(item_found)
            for j=1:length(item_found) %Convert to a struct that can be json encoded
                temp_struct.items{j}=json_info.items{item_found(j)};
            end
            found_items=jsonencode(temp_struct);
        else
            %No items were found.
            found_items='No items matched. Please try again.';
        end
    end
end