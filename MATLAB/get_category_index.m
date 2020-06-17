function [susceptible, infected, immune, vaccinated] = get_category_index(people)
    susceptible = [];
    infected = [];
    immune = [];
    vaccinated = [];
    for index = 1: 1: length(people)
        if people(index).Status == 0 || people(index).Status == -1
            susceptible(length(susceptible) + 1) = index;
        elseif people(index).Status == 1
            infected(length(infected) + 1) = index;
        elseif people(index).Status == 2
            immune(length(immune) + 1) = index;
        elseif people(index).Status == 3
            vaccinated(length(vaccinated) + 1) = index;
        end
    end
end