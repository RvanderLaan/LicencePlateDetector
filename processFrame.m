% Process: Search yellow objects, crop the largest object out of the
% original image and try to read characters
function res = processFrame(frame, charImgs)

frameRed = frame(:, :, 1);
frameGreen = frame(:, :, 2);
frameBlue = frame(:, :, 3);

% Lines from graphs
plate = frameRed < 1.33 * frameGreen + 50 & frameRed > frameGreen - 30 ...
    & frameBlue < 2 * frameRed / 3 ...
    & frameBlue < 2 * frameGreen / 3 + 10 ...
    & frameGreen > 2 * frameRed / 3 ...
    & (frameRed + frameGreen + frameBlue) > 60; % No dark colors

% Close image
plate = imopen(plate, ones(5));
plate = imclose(plate, ones(10));

% Find index of largest object in labeled image
[L, num] = bwlabel(plate);
stats = regionprops(L, 'Area', 'BoundingBox');
areas = [stats.Area];
[~, sortArIdx] = sort(areas, 'Descend');
bboxes = [stats.BoundingBox];
bbox = [];

% Find the largest object with rectangular bounding box
for i = 1:num
    maxSizeIdx = sortArIdx(i);
    bbox = round(bboxes(maxSizeIdx*4 - 3: maxSizeIdx*4));   % Get bbox of that object
    if bbox(3) > 2 * bbox(4) && bbox(3) < 5 * bbox(4)       % Check if proportions of plate
        break;        % Then it's probably the license plate, so stop the loop
    end;
end;

% If no bbox is found, return nothing
if (isempty(bbox))
    res = '';
    return;
end;

% Show isolated plate with full image (in gray) with red rectangle
% imshow(frameRed .* uint8(plate) + frameRed / 3);
% rectangle('Position', bbox, 'EdgeColor', 'red');

% Get red channel of cropped image
plate = frameRed(bbox(2) + 1:bbox(2) + bbox(4) - 1, bbox(1) + 1:bbox(1) + bbox(3) - 1);

% Create binary image by thresholding with a little lower than the mean value
plate = plate ~= 0 & plate < mean(mean(plate)) * 0.9;

res = '';
% If the image isn't empty, try to read it
if ~isempty(plate)
    res = ocr_fast(plate, charImgs);
        % Show text box
%         Iname = insertObjectAnnotation(frame, 'rectangle', bbox, res);
end;