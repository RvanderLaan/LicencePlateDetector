function res = ocr_fast(img, charImgs)
    
    % Summary:
    % Label seperate objects (the characters)
    % For every object 
        % For every template character
            % Find correlation
        % The character corresponds to the highest correlation
    
    % Improvements
    %   Check if correlation with characters of previous license plate are
    %   high, then you won't have to loop over every char every time
    %   Store which characters are similar and check those first
    %   Maybe something with GPU
    % Rotating:
    %   Compare the height of first and last character objects in image
    %   Compare that height with the full image height and decide if it
    %   should be rotated
    
    % Corrections:
    % R sometimes becomes F
    % B sometimes becomes H
    % N & M
    
characters = '0123456789BDFGHJKLMNPRSTVXZ';

res = ''; % For storing the recognized characters

% Label the image
[L, num] = bwlabel(img);

% Calculate bounding boxes
stats = regionprops(L, 'BoundingBox');
bboxes = [stats.BoundingBox];

% For storing the bboxes of the characters only, used to find the dashes
charBboxes = {};   

for i=1:num % For every object 
    obj = L == i; % Get object

    % Crop object
    bbox = round(bboxes(i*4 - 3: i*4));
    obj = obj(bbox(2):bbox(2) + bbox(4) - 1, bbox(1):bbox(1) + bbox(3) - 1);

    % If the object wider than its height and at least 1/3 as high as the image, it's probably a character
    if sum(obj(:)) > 8 && size(obj, 1) > size(img, 1)/3 && size(obj, 1) > size(obj, 2) && bbox(2) + bbox(4) > size(obj, 1)/2
        % Add the bbox to charBboxes
        charBboxes{length(charBboxes)+1} = bbox;
        
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
            char = characters(maxId);
            res = [res char];
        end;
    end;
end;

if length(charBboxes) == 6
    % Find where the dashes are with the bboxes of the characters
    % Find the two largest horizontal gaps between characters 
    distances = [];
    for i=1:(length(charBboxes)-1)
        bbox = charBboxes{i};
        bbox2 = charBboxes{i+1};

        leftX = bbox(1) + bbox(3);
        rightX = bbox2(1);
        distances(i) = rightX - leftX;
    end;
    
    [~, idx] = sort(distances, 'Descend');
    
    % Sort first and second highest indeces, else you get something like
    % '63HK--HKHD'
    if idx(1) > idx(2)
        temp = idx(1);
        idx(1) = idx(2);
        idx(2) = temp;
    end;
    
    % Return nothing if layout is wrong
    if idx(2) - idx(1) < 2 || (idx(1) == 1 && idx(2) == 5)
        res = '';
        return;
    end;

    % Put through the stringToLicensePlate function to make use of
    % sidecodes
    res = sidecodeFinder({[res(1:idx(1))] [res(idx(1)+1:idx(2))] [res(idx(2)+1:end)]});
else
    res = '';
end;