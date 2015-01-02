% Process: Search yellow objects, crop the largest object out of the
% original image and try to read characters
function res = processFrame(frame)

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
plate = imclose(plate, ones(8));

% Find index of largest object in labeled image
[L, num] = bwlabel(plate);
maxSizeIdx = 0;
maxSize = 0;
for i=1:num
    obj = (L == i);
    size = sum(obj(:));
    if size > maxSize
        maxSizeIdx = i;
        maxSize = size;
    end;
end;

% Multiply the largest object with the original image
plate = rgb2gray(frame) .* uint8(L == maxSizeIdx);

% Get the cropping parameters
[nonZeroRows, nonZeroColumns] = find(plate);
topRow = min(nonZeroRows(:));
bottomRow = max(nonZeroRows(:));
leftColumn = min(nonZeroColumns(:));
rightColumn = max(nonZeroColumns(:));

% Extract a cropped image from the original image
edgeSize = 5; % Remove this amount of pixels of the border
plate = plate(topRow+edgeSize:bottomRow-edgeSize, leftColumn+edgeSize:rightColumn-edgeSize);

% Create binary image by thresholding with a little lower than the mean value
plate = plate ~= 0 & plate < mean(mean(plate)) * 0.9;

% Show isolated plate
% imshow(plate);

res = '';
% If the image isn't empty, try to read it
if ~isempty(plate)
    % Read characters which are present on Dutch license plates
    result = ocr(plate, 'CharacterSet', '-0123456789BDFGHJKLNMPRSTVXYZ');

    % Sort the character confidences
    [sortedConf, sortedIndex] = sort(result.CharacterConfidences, 'descend');

    % If there are at least 6 characters recognized, return them
    if (length(sortedIndex) >= 6)
        res = strtrim(result.Text(:)');
    end;
end;