function res = ocr_fast(img, charImgs)
    
    % Label seperate objects (the characters)
    % For every object 
        % For every template character
            % Find correlation
        % The character corresponds to the highest correlation
    
    % Speeding up:
    % Check if correlation with characters of previous license plate are
    % high, then you won't have to loop over every char every time
    % Cmobo with previuos point: Store which characters are similar and
    % only check those
    % Maybe something with GPU
    % 
    
    % Rotating:
    % Compare the height of first and last character objects in image
    % Compare that height with the full image height and decide if it
    % should be rotated
    
characters ='0123456789BDFGHJKLMNPRSTVXZ';
similar =   'D Z  S8 B 80      NMRP5     '; % Characters which look similar

res = ''; % For storing the recognized characters

% Label the image
[L, num] = bwlabel(img);

% Calculate bounding boxes
stats = regionprops(L, 'BoundingBox');
bboxes = [stats.BoundingBox];

for i=1:num % For every object 
    obj = L == i; % Get object

    % Crop object
    bbox = round(bboxes(i*4 - 3: i*4));
    obj = obj(bbox(2):bbox(2) + bbox(4) - 1, bbox(1):bbox(1) + bbox(3) - 1);

    % If the object wider than its height and at least 1/3 as high as the image, it's probably a character
    if sum(obj(:)) > 8 && size(obj, 1) > size(img, 1)/3 && size(obj, 1) > size(obj, 2)
        % Find the max correlation for a character 
        maxCorr = -1;
        maxId = 0;
        for j = 1:length(characters);    % For every character
            % Resize
            char = charImgs{j};
            char = imresize(char, [bbox(4), bbox(3)]);
            
            corr = corr2(obj, char); % Find correlation
            
            if corr > maxCorr
                maxCorr = corr;
                maxId = j;
            end;
        end;
        % Return the recognized characters
        if maxId ~= 0
            res = [res characters(maxId)];
        else
            res = [res '?'];
        end;
        
    % If a small object is wider than its height, it could be a dash
    elseif sum(obj(:)) > 3 && size(obj, 2) > 1 && size(obj, 2) < size(img, 2) / 6 && size(obj, 2) > size(obj, 1)
        % If there could be a dash there in the string, add it
        if ~strcmp(res, '') && length(res) < 8 && res(length(res)) ~= '-'
            res = [res '-'];
        end;
    end;
end;