function status = infect_from_people(p_target,p_source)
%Compute the status between 2 agents
%   Input: p_target, the target agent with status 0 or 3
%          p_source, the agent is infected (status = 1)
%   Output:the new status for target agent

global t immuneTime arena
max_probability = 1;
max_radius = 2.5;
% Get the properties from agents
t_vac = p_target.TimeVacc;
x1 = p_target.XLoc;
y1 = p_target.YLoc;
x2 = p_source.XLoc;
y2 = p_source.YLoc;
% compute the distance
dis = sqrt((arena/2 - abs(arena/2 - abs(x1 - x2)))^2+(arena/2 - abs(arena/2 - abs(y1 - y2)))^2);

p = 0;
if t_vac >=0 && dis <= max_radius
% This calculates the probability of infection for a vaccinated agent.
% How long ago they were vaccinated is given by t_inter.
    t_inter = t-t_vac;
    p = 2*max_probability/(1+exp(dis/max_radius)*exp(t_inter/immuneTime));
elseif dis <= max_radius
% This calculates the probability of infection for susceptible individuals
    p = 2*max_probability/(1+exp(dis/max_radius));
end

k = rand;
if k<p
    status = 1;
else
    status = p_target.Status;
end

end
