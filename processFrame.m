function res = processFrame(frame)

frameRed = frame(:, :, 1);
frameGreen = frame(:, :, 2);
frameBlue = frame(:, :, 3);

% Treshholding red and green
temp = (frameRed < (1.37*frameGreen + 55)) & (frameRed > (frameGreen + -30));
% Treshholding red and blue
temp = temp & frameRed > 0.9*frameBlue - 40;
% Treshholding blue and green
temp = temp & frameGreen > 0.95*frameBlue & frameGreen < 3.75*frameBlue;

% Tresholding minimum lines (no dark values)
temp = temp & frameRed > -2*frameGreen + 100 & frameRed < 5*frameBlue + 150;
% Thresholding minimum values
temp = temp & frameRed > 25 & frameGreen > 25 & frameBlue > 25;

% No blue areas
temp = temp & frameBlue < frameRed & frameBlue < frameGreen;
% No red areas
temp = temp & frameRed < (frameGreen + frameBlue);

imagesc(temp);

if sum(temp(:)) > 3000
    res = 1;
else
    res = 0;
end;

