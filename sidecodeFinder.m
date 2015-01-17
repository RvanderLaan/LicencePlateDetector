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

similar = {'DTZSB' '01258'};    % Similar looking digits and characters
tNum = '34679';                 % Numbers which don't look like characters
tChar = 'FGHJKLMNPRVX';         % Characters which don't look like numbers
allNum = '0123456789';          % All numbers


% Identify sidecode:
% First look for 2 trusted alphabetic characters in any part
% Or for at least one trusted digit in any part
% Or for 2 different digits of any kind in the same part
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
elseif (isTrusted(tChar, plate, 1, 1, 1, 2, 'or') && isTrusted(tChar, plate, 3, 1, 3, 2, 'or')) || ... 
        isTrusted(tNum, plate, 2, 1, 2, 2, 'or') || isTrusted(allNum, plate, 2, 1, 2, 2, 'and')
    sc = 1; % idx 1         % Sidecode 4
elseif (isTrusted(tChar, plate, 1, 1, 1, 2, 'or') && isTrusted(tChar, plate, 2, 1, 2, 2, 'or')) || ...
        isTrusted(tNum, plate, 3, 1, 3, 2, 'or') || isTrusted(allNum, plate, 3, 1, 3, 2, 'and')
    sc = 2; % idx 2         % Sidecode 5
elseif (isTrusted(tChar, plate, 2, 1, 2, 2, 'or') && isTrusted(tChar, plate, 3, 1, 3, 2, 'or'))  || ... 
        isTrusted(tNum, plate, 1, 1, 1, 2, 'or') || isTrusted(allNum, plate, 1, 1, 1, 2, 'and')
    sc = 3; % idx 3         % Sidecode 6
end;

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
        if ~isempty(idx) % If a similar looking character is found
            plate{i}(j) = similar{isnum+1}(idx); % Switch the similar character
        elseif isnum ~= isstrprop(plate{i}(j), 'digit')
            res = ''; % If it can't be converted, there will be a number
            return;   % and alphabetic character, which is always wrong
        end;
    end;
end;

res = [plate{1} '-' plate{2} '-' plate{3}];

% Returns if two characters are part of a template string, depending on the
% option ('and'/'or')
function res = isTrusted(template, plate, i11, i12, i21, i22, option)
res = 0;
if strcmp(option, 'or')
    res = (~isempty(strfind(template, plate{i11}(i12))) || ~isempty(strfind(template, plate{i21}(i22))));
elseif strcmp(option, 'and')
    if plate{i11}(i12) ==  plate{i21}(i22) % can't be the same, should be removed if used for other purposes
        res = false;
        return;
    end;
    res = (~isempty(strfind(template, plate{i11}(i12))) && ~isempty(strfind(template, plate{i21}(i22))));
end;
        