%% Parameters

target_variable = "rgdpo";
secondery_variable = "cas";

%% Data

DRC_data_gdp = readtable("GDP, HCI, POPULATION - DRC.csv", ...
    'ReadVariableNames', true);
IC_data_gdp = readtable("GDP, POPULATION - Ivory Coast.csv", ...
    'ReadVariableNames', true);

DRC_data_rents = readtable("Total natural resources rents (% of GDP) - DRC.xlsx", ...
    'ReadVariableNames', true);
IC_data_rents = readtable("Total natural resources rents (% of GDP) - Ivory Coast.xlsx", ...
    'ReadVariableNames', true);

DRC_data_death = readtable("DRC Casualties.xlsx", ...
    'ReadVariableNames', true);
IC_data_death = readtable("Ivory Coast Casualties.xlsx", ...
    'ReadVariableNames', true);

%% Weights

% helper variables
DRC_years = "x" + (1986:2012);
IC_years = "x" + (1992:2019);

DRC_comp_rents = DRC_data_rents{DRC_data_rents.CountryCode ~= "COD", DRC_years} / 100;
IC_comp_rents = IC_data_rents{IC_data_rents.CountryCode ~= "CIV", IC_years} / 100;

DRC_rents = DRC_data_rents{DRC_data_rents.CountryCode == "COD", DRC_years} / 100;
IC_rents = IC_data_rents{IC_data_rents.CountryCode == "CIV", IC_years} / 100;

DRC_comp_deltas = (1 - abs(DRC_comp_rents - DRC_rents)) .^ 2;
IC_comp_deltas = (1 - abs(IC_comp_rents - IC_rents)) .^ 2;

DRC_comp_deltas(isnan(DRC_comp_deltas)) = 0;
IC_comp_deltas(isnan(IC_comp_deltas)) = 0;

DRC_comp_weights = DRC_comp_deltas ./ sum(DRC_comp_deltas);
IC_comp_weights = IC_comp_deltas ./ sum(IC_comp_deltas);

%% Synthetic Data

% extract gdp
DRC_comp_gdp = DRC_data_gdp{DRC_data_gdp.ISOCode ~= "COD" & DRC_data_gdp.VariableCode == target_variable, DRC_years};
DRC_gdp = DRC_data_gdp{DRC_data_gdp.ISOCode == "COD" & DRC_data_gdp.VariableCode == target_variable, DRC_years};

IC_comp_gdp = IC_data_gdp{IC_data_gdp.ISOCode ~= "CIV" & IC_data_gdp.VariableCode == target_variable, IC_years};
IC_gdp = IC_data_gdp{IC_data_gdp.ISOCode == "CIV" & IC_data_gdp.VariableCode == target_variable, IC_years};

% extract population
DRC_comp_pop = DRC_data_gdp{DRC_data_gdp.ISOCode ~= "COD" & DRC_data_gdp.VariableCode == "pop", DRC_years};
DRC_pop = DRC_data_gdp{DRC_data_gdp.ISOCode == "COD" & DRC_data_gdp.VariableCode == "pop", DRC_years};

IC_comp_pop = IC_data_gdp{IC_data_gdp.ISOCode ~= "CIV" & IC_data_gdp.VariableCode == "pop", IC_years};
IC_pop = IC_data_gdp{IC_data_gdp.ISOCode == "CIV" & IC_data_gdp.VariableCode == "pop", IC_years};

% calculate gdp per capita
DRC_comp_gdp_per_mil_capita = DRC_comp_gdp ./ DRC_comp_pop;
DRC_gdp_per_mil_capita = DRC_gdp ./ DRC_pop;

IC_comp_gdp_per_mil_capita = IC_comp_gdp ./ IC_comp_pop;
IC_gdp_per_mil_capita = IC_gdp ./ IC_pop;

% calculate pre-cutoff average
DRC_comp_precutoff_averages = mean(DRC_comp_gdp_per_mil_capita(:, 1:10), 2);
DRC_precutoff_average = mean(DRC_gdp_per_mil_capita(:, 1:10), 2);

IC_comp_precutoff_averages = mean(IC_comp_gdp_per_mil_capita(:, 1:10), 2);
IC_precutoff_average = mean(IC_gdp_per_mil_capita(:, 1:10), 2);

% calculate normalization factors
DRC_norm_factors = DRC_comp_precutoff_averages - DRC_precutoff_average;

IC_norm_factors = IC_comp_precutoff_averages - IC_precutoff_average;

% normalize using pre-cutoff average
DRC_comp_gdp_per_mil_capita_norm = DRC_comp_gdp_per_mil_capita - DRC_norm_factors;

IC_comp_gdp_per_mil_capita_norm = IC_comp_gdp_per_mil_capita - IC_norm_factors;

% calculate synthetic gdp
DRC_syn_gdp_per_mil_capita_norm = sum(DRC_comp_gdp_per_mil_capita_norm .* DRC_comp_weights);

IC_syn_gdp_per_mil_capita_norm = sum(IC_comp_gdp_per_mil_capita_norm .* IC_comp_weights);

%% Comparing To Earlier Research

% Seting Earlier Research Factors
DRC_early_factors = [0.943,0.057]';

IC_early_factors = [0.345,0.013,0.628]';
IC_early_factors = IC_early_factors ./ sum(IC_early_factors);


% Calculate Earlier Research Synthetic gdp
DRC_syn_gdp_per_mil_capita_early_norm = sum(DRC_comp_gdp_per_mil_capita_norm .* DRC_early_factors);

IC_syn_gdp_per_mil_capita_early_norm = sum(IC_comp_gdp_per_mil_capita_norm .* IC_early_factors);


%% Extracting Casualties Data

DRC_death = DRC_data_death{DRC_data_death.ISOCode == "COD" & DRC_data_death.VariableCode == secondery_variable, DRC_years(4:end)};

IC_death = IC_data_death{IC_data_death.ISOCode == "CIV" & IC_data_death.VariableCode == secondery_variable, IC_years};

%% Plot parameters

DRC_years_num = (1986:2012);
IC_years_num = (1992:2019);
xline_label_fontsize = 8;

%% Plot (GDP)

figure

% DRC
subplot(2, 1, 1);
plot(DRC_years_num, DRC_syn_gdp_per_mil_capita_norm)
hold on
plot(DRC_years_num, DRC_syn_gdp_per_mil_capita_early_norm)
hold on
plot(DRC_years_num, DRC_gdp_per_mil_capita)
xln = xline(1994, "-", "Start of Rwandan Genocide");
xln.FontSize = xline_label_fontsize;
xln = xline(1996, "-", "First Congo War");
xln.FontSize = xline_label_fontsize;
xln = xline(1999, "-", "Start of MONUC Mission");
xln.FontSize = xline_label_fontsize;
xln = xline(2003, "-", "Transition Goverment");
xln.FontSize = xline_label_fontsize;
xln = xline(2004, "-", {"Start of UN", "Offensive Operations"});
xln.FontSize = xline_label_fontsize;
xln = xline(2006, "-", "First Agreed Upon Election");
xln.FontSize = xline_label_fontsize;
xln = xline(2010, "-", "End of MONUC Mission");
xln.FontSize = xline_label_fontsize;
legend("Resource based synthetic",'Regression based synthetic' , "Actual", "Location", "northwest")
title ("GDP Per Capita - DRC")
xlabel ("Years")
ylabel ("GDP Per Million Capita (Chained PPP)")
hold on 
x_area = [1999, 2010, 2010, 1999]; 
y_area = [min(DRC_syn_gdp_per_mil_capita_norm)-0.1, min(DRC_syn_gdp_per_mil_capita_norm)-0.1, max(DRC_syn_gdp_per_mil_capita_norm)+0.1, max(DRC_syn_gdp_per_mil_capita_norm)+0.1];
patch(x_area, y_area, [0.8 0.8 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Ivory Coast
subplot(2, 1, 2);
plot(IC_years_num, IC_syn_gdp_per_mil_capita_norm)
hold on
plot(IC_years_num, IC_syn_gdp_per_mil_capita_early_norm)
hold on
plot(IC_years_num, IC_gdp_per_mil_capita)
xln = xline(2002, "-", "Start of Ivorian Civil War");
xln.FontSize = xline_label_fontsize;
xln = xline(2003, "-", {"Signing of Linas-Marcoussis", "Agreement"});
xln.FontSize = xline_label_fontsize;
xln = xline(2004, "-", "Start of UNOCI  Mission");
xln.FontSize = xline_label_fontsize;
xln = xline(2007, "-", {"Signing of Ouagadougou", "Peace Agreement"});
xln.FontSize = xline_label_fontsize;
xln = xline(2011, "-", "Ivorian Election Crisis");
xln.FontSize = xline_label_fontsize;
xln = xline(2015, "-", "Post-Gbagbo Election");
xln.FontSize = xline_label_fontsize;
xln = xline(2017, "-", "End of UNOCI  Mission");
xln.FontSize = xline_label_fontsize;
legend("Resource based synthetic",'Regression based synthetic' , "Actual", "Location", "northwest")
title ("GDP Per Capita - Ivory Coast")
xlabel ("Years")
ylabel ("GDP Per Million Capita (Chained PPP)")
hold on 
x_area = [2004, 2017, 2017, 2004]; 
y_area = [min(IC_syn_gdp_per_mil_capita_norm)-0.1, min(IC_syn_gdp_per_mil_capita_norm)-0.1, max(IC_syn_gdp_per_mil_capita_norm)+0.1, max(IC_syn_gdp_per_mil_capita_norm)+0.1];
patch(x_area, y_area, [0.8 0.8 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

%% export

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 38 20]);
set(gcf, 'PaperSize', [38 20]);
print('gdp.jpg', '-djpeg', '-r300');

%% Plot (Casualties)

figure

% DRC
subplot(2, 1, 1);
plot (DRC_years_num(4:end),DRC_death)
ax = gca; % axes handle
ax.YAxis.Exponent = 0;
title ("Casualties Caused By Violence - DRC")
xlabel ("Years")
ylabel ("Number of Deaths")
xln = xline(1994, "-", "Start of Rwandan Genocide");
xln.FontSize = xline_label_fontsize;
xln = xline(1996, "-", "First Congo War");
xln.FontSize = xline_label_fontsize;
xln = xline(1999, "-", "Start of MONUC Mission");
xln.FontSize = xline_label_fontsize;
xln = xline(2003, "-", "Transition Goverment");
xln.FontSize = xline_label_fontsize;
xln = xline(2004, "-", {"Start of UN", "Offensive Operations"});
xln.FontSize = xline_label_fontsize;
xln = xline(2006, "-", "First Agreed Upon Election");
xln.FontSize = xline_label_fontsize;
xln = xline(2010, "-", "End of MONUC Mission");
xln.FontSize = xline_label_fontsize;
hold on 
x_area = [1999, 2010, 2010, 1999]; 
y_area = [min(DRC_death)-0.1, min(DRC_death)-0.1, max(DRC_death)+0.1, max(DRC_death)+0.1];
patch(x_area, y_area, [0.8 0.8 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Ivory Coast
subplot(2, 1, 2);
plot (IC_years_num,IC_death)
title ("Casualties Caused By Violence - Ivory Coast")
xlabel ("Years")
ylabel ("Number of Deaths")
xln = xline(2002, "-", "Start of Ivorian Civil War");
xln.FontSize = xline_label_fontsize;
xln = xline(2003, "-", {"Signing of Linas-Marcoussis", "Agreement"});
xln.FontSize = xline_label_fontsize;
xln = xline(2004, "-", "Start of UNOCI  Mission");
xln.FontSize = xline_label_fontsize;
xln = xline(2007, "-", {"Signing of Ouagadougou", "Peace Agreement"});
xln.FontSize = xline_label_fontsize;
xln = xline(2011, "-", "Ivorian Election Crisis");
xln.FontSize = xline_label_fontsize;
xln = xline(2015, "-", "Post-Gbagbo Election");
xln.FontSize = xline_label_fontsize;
xln = xline(2017, "-", "End of UNOCI  Mission");
xln.FontSize = xline_label_fontsize;
hold on 
x_area = [2004, 2017, 2017, 2004]; 
y_area = [min(IC_death)-0.1, min(IC_death)-0.1, max(IC_death)+0.1, max(IC_death)+0.1];
patch(x_area, y_area, [0.8 0.8 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none');

%% export

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 38 20]);
set(gcf, 'PaperSize', [38 20]);
print('casualties.jpg', '-djpeg', '-r300');

%% Fit Variables
DRC_syn_fit = DRC_syn_gdp_per_mil_capita_norm(1:10);

DRC_fit = DRC_gdp_per_mil_capita(1:10);

IC_syn_fit = IC_syn_gdp_per_mil_capita_norm(1:10);

IC_fit = IC_gdp_per_mil_capita(1:10);