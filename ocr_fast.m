function res = ocr_fast(img, charImgs)
    
    % Label seperate objects (the characters)
    % For every object (max 6)
        % For every template character
            % Find correlation
        % The character corresponds to the highest correlation
    %

% Label the image
[L, num] = bwlabel(img);

characters = '0123456789BDFGHJKLNMPRSTVXYZ';

charIds = '';
for i=1:num % For every object 
    obj = L == i; % Get object
    % Get the cropping parameters
    [nonZeroRows, nonZeroColumns] = find(obj);
    topRow = min(nonZeroRows(:));
    bottomRow = max(nonZeroRows(:));
    leftColumn = min(nonZeroColumns(:));
    rightColumn = max(nonZeroColumns(:));
    
    % Crop object
    obj = obj(topRow:bottomRow, leftColumn:rightColumn);
    
    % If the object wider than its height, it's probably a character
    if size(obj, 1) > size(obj, 2)
        % Find the max correlation with a character 
        maxCorr = 0;
        maxId = 0;
        for j = 0:length(characters)-1;    % For every character
            % Resize
            char = charImgs.get(j);
            char = imresize(char, [(bottomRow-topRow+1), (rightColumn-leftColumn+1)], 'nearest');

            corr = corr2(obj, char); % Find correlation
            if corr > maxCorr
                maxCorr = corr;
                maxId = j;
            end;
        end;
        % Return the recognized characters
        charIds = [charIds characters(maxId+1)];
    end;
end;
res = charIds;