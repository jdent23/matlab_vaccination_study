classdef agent
    % AGENT The class definition of an agent
    %   AGENT properties:
    %       Status           0 = susceptible, 1 = infected, 2 = immune, 3 = vaccinated
    %       Speed            max radius agent moves on step
    %       Dir              heading of agent in radians
    %       TimeVacc         the time an agent got vaccinated
    %       XLoc             agent's x coordinate
    %       YLoc             agent's y coordinate
    %       Color            plotting color
    %
    %
    %   For information about object-oriented programming in MATLAB, see <a
    %   href="matlab:
    %   web('https://www.mathworks.com/company/newsletters/articles/introduction-to-object-oriented-programming-in-matlab.html')">this</a>
    %    or <a href="matlab:
    %   web('https://www.mathworks.com/help/matlab/object-oriented-design-with-matlab.html')">this</a> article.
    
    properties
        Status = -1      % 0 = susceptible, 1 = infected, 2 = immune, 3 = vaccinated
        Speed           % max radius agent moves on step
        Dir             % heading of agent in radians
        TimeVacc = -1   % the time an agent got vaccinated
        XLoc            % agent's x coordinate
        YLoc            % agent's y coordinate
        Randomness      % agent's ability to change direction
    end
    
    properties (Dependent)
        Color           % plot color
    end
    
    methods
        function obj = agent
            global arena
            obj.Speed = arena*rand/20;
            obj.Dir = 2*pi*rand;
            obj.XLoc = arena*rand;
            obj.YLoc = arena*rand;
            obj.Randomness = pi/2*rand;
        end
        
        function C = get.Color(current)
            if current.Status == 0
                C = 'b';
            elseif current.Status == 1
                C = 'r';
            elseif current.Status == 2
                C = 'g';
            elseif current.Status == 3
                C = 'y';
            else
                C = 'k';
            end
        end
    end
end

