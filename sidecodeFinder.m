% Converts a string to a license plate with the help of sidecodes
% For example, A0-12-BC becomes AD-12-BC
% Input is {[X] [X] [X]} where there should be dashes in between
function res = sidecodeFinder(plate)

sidecodes = { % True = numeric 
    false true false; % Sidecode 4, idx 1
    false false true; % Sidecode 5, idx 2
    true false false; % Sidecode 6, idx 3
    true false true;  % Sidecode 7, idx 4
    true false true;  % Sidecode 8, idx 5
    false true false;  % Sidecode 9, idx 6
};

similar = {'DTZSB' '01258'};
trustedNumbers = '34679'; % Numbers which don't look like characters
trustedChars = 'FGHJKLMNPRVX'; % Characters which don't look like numbers


% Identify sidecode
sc = 0;
if length(plate{3}) == 1
    if isstrprop(plate{3}, 'digit') % If it's a digit
        sc = 4; % idx 4         % Sidecode 7
    else
        sc = 6; % idx 6         % Sidecode 9
    end;
elseif length(plate{1}) == 1    
    sc = 5; % idx 5             % Sidecode 8
    
    % If there is a trusted number in 1 part or two trusted characters in 2 parts,
    % choose that sidecode
elseif ~isempty(strfind(trustedNumbers, plate{2}(1))) || ~isempty(strfind(trustedNumbers, plate{2}(2))) || ...
       ((~isempty(strfind(trustedChars, plate{1}(1))) || ~isempty(strfind(trustedChars, plate{1}(2)))) && ...
       (~isempty(strfind(trustedChars, plate{3}(1))) || ~isempty(strfind(trustedChars, plate{3}(2)))))
    sc = 1; % idx 1         % Sidecode 4
elseif ~isempty(strfind(trustedNumbers, plate{3}(1))) || ~isempty(strfind(trustedNumbers, plate{3}(2))) || ...
       ((~isempty(strfind(trustedChars, plate{1}(1))) || ~isempty(strfind(trustedChars, plate{1}(2)))) && ...
       (~isempty(strfind(trustedChars, plate{2}(1))) || ~isempty(strfind(trustedChars, plate{2}(2)))))
    sc = 2; % idx 2         % Sidecode 5
elseif ~isempty(strfind(trustedNumbers, plate{1}(1))) || ~isempty(strfind(trustedNumbers, plate{1}(2))) || ...
       ((~isempty(strfind(trustedChars, plate{2}(1))) || ~isempty(strfind(trustedChars, plate{2}(2)))) && ...
       (~isempty(strfind(trustedChars, plate{3}(1))) || ~isempty(strfind(trustedChars, plate{3}(2)))))
    sc = 3; % idx 3         % Sidecode 6
end;

print = [sc plate];

% If it does not fit in any sidecode, return nothing
if sc == 0
    res = '';
    return;
end;

% Convert characters to digits and vice versa
for i=1:3 % For every part of the plate
    isnum = sidecodes{sc, i}(1); % 1 = numeric, 0 = alphabetic
    for j=1:length(plate{i}) % For every character of that part
        idx = strfind(similar{abs(isnum-2)}, plate{i}(j)); % Is empty if not found
        if ~isempty(idx) % if a character is found, set it to a number
            plate{i}(j) = similar{isnum+1}(idx); % Switch the similar character
        end;
    end;
end;

[print plate];

res = [plate{1} '-' plate{2} '-' plate{3}];