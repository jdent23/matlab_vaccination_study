close all;
clc;
clear;

data = xlsread('vaccination_versus_death.xlsx');
vacc_rates = data(:, 1);
deaths = data(:, 2:end);

vacc_dims = size(vacc_rates);
death_dims = size(deaths);

flat_death = [];
flat_vacc = [];
for group = 1: 1: death_dims(2)
    flat_death = [flat_death; deaths(:, group)];
    flat_vacc = [flat_vacc; vacc_rates];
end

scatter(flat_vacc, flat_death);

fit = polyfit(flat_vacc, flat_death, 6);
vals = polyval(fit, vacc_rates);
hold on;
plot(vacc_rates, vals,'--r')

title('Death Tolls from Vaccination Rates');
xlabel('Vaccination Rate');
ylabel('Death Toll');