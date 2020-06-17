function [person] = move(person)
% Pass in an agent object
% Passes out an agent object
% Requires a global arena to have been declared and set

% Calculates the next position of an agent given their previous location
% and direction. Also sets their status from vaccinated to immune after 7
% turns have passed, or ticks forward the time since vaccination otherwise.
    global arena;
    person.Dir = mod(person.Dir + normrnd(0, person.Randomness), 2*pi); % Determines new direction
    person.XLoc = mod(person.XLoc + cos(person.Dir) * person.Speed*rand, arena);% Find next x and y locations
    person.YLoc = mod(person.YLoc + sin(person.Dir) * person.Speed*rand, arena);
end