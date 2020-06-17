function People_new = status(People, infected_locations)
%Update the people's status after moving
%   Input: people
%   Output: people with new status
global vacc_rate reg_d inf_d death_num t immuneTime vaccs_distributed
target = [];
source = [];
num = length(People);
for i = 1:num
    if People(i).Status == -1
        People(i).Status = 0;
    end
    
    if People(i).Status == 0 && rand <= vacc_rate
        People(i).Status = 3;
        People(i).TimeVacc = t;
        vaccs_distributed = vaccs_distributed + 1;
    end
    
    if (People(i).Status ~=1) && (People(i).Status ~=-2)
        p1 = rand;
        if p1<reg_d
            People(i).Status = -2;
            death_num = death_num + 1;
        else
            if People(i).Status ==0 || People(i).Status==3
                target(length(target)+1)=i;
            end
        end
    else
        p2 = rand;
        if p2<inf_d
            People(i).Status = -2;
            death_num = death_num + 1;
        else
            source(length(source)+1)=i;
        end
    end
    
    if (People(i).Status == 3) && (t - People(i).TimeVacc >= immuneTime)
        People(i).Status = 2;
    end
end

for i = 1:length(target)
    for j = 1:length(source)
        People(target(i)).Status = infect_from_people(People(target(i)),People(source(j)));
    end
end

% Uncomment the section below for Problem #2
for i = length(target): -1: 1
    if People(target(i)).Status == 1
        target(i) = [];
    else
        dimensions = size(infected_locations);
        for j = 1: 1: dimensions(1)
            People(target(i)).Status = infect_from_location(People(target(i)), infected_locations(j, :));
        end
    end
end

for i =length(People):-1:1
    if People(i).Status == -2
    People(i)=[];
    end
end

People_new = People;
end
