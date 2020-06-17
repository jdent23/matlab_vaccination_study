classdef app1 < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public) % define UI elements
        UIFigure                       matlab.ui.Figure
        VaccRateEditFieldLabel         matlab.ui.control.Label
        ImmuneSpinnerLabel             matlab.ui.control.Label
        ImmuneSpinner                  matlab.ui.control.Spinner
        AgentsSpinnerLabel             matlab.ui.control.Label
        AgentsSpinner                  matlab.ui.control.Spinner
        StartInfectedSpinnerLabel      matlab.ui.control.Label
        StartInfectedSpinner           matlab.ui.control.Spinner
        VaccRateEditField              matlab.ui.control.NumericEditField
        BeginButton                    matlab.ui.control.Button
        EndTimeSliderLabel             matlab.ui.control.Label
        EndTimeSlider                  matlab.ui.control.Slider
        UIAxes                         matlab.ui.control.UIAxes
        DeadLabel                      matlab.ui.control.Label
        DeadLamp                       matlab.ui.control.Lamp
        SusceptibleLabel               matlab.ui.control.Label
        SusceptibleLamp                matlab.ui.control.Lamp
        InfectedLampLabel              matlab.ui.control.Label
        InfectedLamp                   matlab.ui.control.Lamp
        ImmuneLampLabel                matlab.ui.control.Label
        ImmuneLamp                     matlab.ui.control.Lamp
        VaccinatedLampLabel            matlab.ui.control.Label
        VaccinatedLamp                 matlab.ui.control.Lamp
        TimeGaugeLabel                 matlab.ui.control.Label
        TimeGauge                      matlab.ui.control.NinetyDegreeGauge
        ShowAgentsSwitch               matlab.ui.control.Switch
        DeadNum                        matlab.ui.control.Label
        SusceptibleNum                 matlab.ui.control.Label
        VaccinatedNum                  matlab.ui.control.Label
        ImmuneNum                      matlab.ui.control.Label
        InfectedNum                    matlab.ui.control.Label
    end
    
    methods % these methods define interactivity
        
        % Button pushed function: BeginButton
        function BeginButtonPushed(app, event) % when big button is clicked, begin simulation
            tic
            global numAgents infStart arena endTime t value death_num vaccs_distributed
            app.BeginButton.Enable =            'off'; % disable the UI elements while simulation is running
            app.AgentsSpinner.Enable =          'off';
            app.StartInfectedSpinner.Enable =   'off';
            app.ImmuneSpinner.Enable =          'off';
            app.EndTimeSlider.Enable =          'off';
            app.VaccRateEditField.Enable =      'off';
            app.ShowAgentsSwitch.Enable =       'off';
            death_num=0;
            vaccs_distributed = 0;
            agents=agent.empty; % initialize agents object group
            infec=randperm(numAgents,infStart); % pick the indices of the agents who start infected
            infected_locations = [];
            for i=1:numAgents
                agents(i)=agent; % spawn numAgents in the "agents" instance of an object of the type "agent"
                if ismember(i,infec)
                    agents(i).Status=1; % change the status of the chosen infected agents to infected
                    distance_from_center = normrnd(0, arena / 50);
                    direction_from_center = rand * 2 * pi;
                    agents(i).XLoc = distance_from_center * cos(direction_from_center) + arena / 2;
                    agents(i).YLoc = distance_from_center * sin(direction_from_center) + arena / 2;
                end
                if value
                    plot(app.UIAxes,[agents(i).XLoc],[agents(i).YLoc],'o','MarkerEdgeColor', 'k', 'MarkerSize', 5, 'MarkerFaceColor', agents(i).Color); % plot
                    hold(app.UIAxes, 'on' ); % hold on to these axes to plot more
                end
            end
            drawnow;
            pause(0.001)
            
            history = zeros(endTime, 6);
            t=0; % simulation start time is zero
            
            if value
                h = figure();
            end
            for k=1:endTime
                t=k; % step the time
                app.TimeGauge.Value = t; % move indicator needle
                
                [s, inf, r, v] = get_category_index(agents);
                history(k, :) = [length(s), length(inf), length(r), length(v), death_num, vaccs_distributed];
                if length(s) == 0 && length(inf) == 0 && length(v) == 0
                    history = history([1:1:k], :);
                    break;
                end
                
                hold(app.UIAxes,'off');
                agents = status(agents, infected_locations);
                
                if value
                    hh=figure(h);
                    if k==1
                        movegui(hh,'northeast');
                    end
                    for index = length(agents): -1: 1
                        if agents(index).Status == 1
                            infected_locations(end + 1, :) = [agents(index).XLoc, agents(index).YLoc];
                            plot(agents(index).XLoc, agents(index).YLoc,'o','MarkerEdgeColor',agents(index).Color,'MarkerSize', 5, 'MarkerFaceColor', agents(index).Color);
                            hold on;
                            title("Locations of Infection");
                        end
                    end
                    xlim([0, arena]);
                    ylim([0, arena]);
                    
                    frame = getframe(hh.CurrentAxes);
                    im{k} = frame2im(frame);
                end
                
                for index = length(agents): -1: 1
                    agents(index) = move(agents(index));
                    if value
                        plot(app.UIAxes,[agents(index).XLoc],[agents(index).YLoc],'o','MarkerEdgeColor','k', 'MarkerSize', 5, 'MarkerFaceColor', agents(index).Color);
                        hold(app.UIAxes,'on');
                    end
                end
                if value
                    app.SusceptibleNum.Text =   num2str(history(k,1),'%03.f');
                    app.InfectedNum.Text =      num2str(history(k,2),'%03.f');
                    app.ImmuneNum.Text =        num2str(history(k,3),'%03.f');
                    app.VaccinatedNum.Text =    num2str(history(k,4),'%03.f');
                    app.DeadNum.Text =          num2str(death_num,'%03.f');
                end
                drawnow;
                
                % pause(0.01); % prevent from running faster than interpretible
            end
            
            hist=figure;
            hold on;
            colors = [[0,0,1];[1,0,0];[0,1,0];[0.8980,0.6588,0.3098];[0,0,0]; [1, 0, 1]];
            dimensions = size(history);
            for i = 1: 1: dimensions(2)
                histlines=plot(history(:, i),'Color',colors(i,:));
            end
            title("Populations Over Time");
            xlabel("# of Days");
            ylabel("Population");
            legend({'Susceptible', 'Infectious', 'Immune', 'Vaccinated', 'Dead', 'Vaccinations Distributed'},'Location','best');
            
            if value % this whole loop assembles and writes the animation gif
                filename = 'infectionAni.gif'; % Specify the output file name
                for idx = 1:1:k - 1
                    [A,map] = rgb2ind(im{idx},256);
                    if idx == 1
                        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1/30);
                    else
                        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1/30);
                    end
                end
            end
            
            app.BeginButton.Enable =            'on'; % re-enable the UI elements when done simulating
            app.AgentsSpinner.Enable =          'on';
            app.StartInfectedSpinner.Enable =   'on';
            app.ImmuneSpinner.Enable =          'on';
            app.EndTimeSlider.Enable =          'on';
            app.VaccRateEditField.Enable =      'on';
            app.ShowAgentsSwitch.Enable =       'on';
            toc
        end
        
        % Value changed function: EndTimeSlider
        function EndTimeSliderValueChanged(app, event) % when user changes end time slider
            global endTime
            app.EndTimeSlider.Value=round(app.EndTimeSlider.Value); % round Slider to integer value
            endTime = app.EndTimeSlider.Value; % change value of endTime to what user selects
            app.TimeGauge.Limits(2)=endTime; % update indicator's maximum
        end
        
        % Value changed function: VaccRateEditField
        function VaccRateEditFieldChanged(app, event) % when user changes vaccrate
            global vacc_rate
            vacc_rate = app.VaccRateEditField.Value; % update the value to what the user selected
        end
        
        % Value changed function: AgentsSpinner
        function AgentsSpinnerValueChanged(app, event) % user change total num agents
            global numAgents
            numAgents = app.AgentsSpinner.Value; % change the number of agents to the value the user selected
            app.StartInfectedSpinner.Limits = [0 numAgents-1]; % set uplimit of the infStart spinner to be 1 less than numAgents
            if app.StartInfectedSpinner.Limits(2)>=numAgents % if the numAgents dips below uplimit of infStart spinner
                app.StartInfectedSpinner.Limits(2)=numAgents-1; % reassign uplimit of infStart spinner to one less than numAgents
            end
        end
        
        % Value changed function: ImmuneSpinner
        function ImmuneSpinnerValueChanged(app, event)
            global immuneTime
            immuneTime = app.ImmuneSpinner.Value;
        end
        
        % Value changed function: StartInfectedSpinner
        function StartInfectedSpinnerValueChanged(app, event)
            global infStart
            infStart = app.StartInfectedSpinner.Value; % change value of number infected agents to start with to what the user selects
        end
        
        % Value changed function: ShowAgentsSwitch
        function ShowAgentsSwitchValueChanged(app, event)
            global value
            
            if strcmpi('off', app.ShowAgentsSwitch.Value)
                value = false;
            else
                value = true;
            end
            
        end
        
    end
    
    % App initialization and construction
    methods
        
        function setGlobals(app)
            global numAgents infStart endTime vacc_rate reg_d inf_d value immuneTime death_num vaccs_distributed arena
            endTime = 500;
            infStart = 3;
            numAgents = 100;
            vacc_rate = 0.045;
            reg_d = 0;
            inf_d = 0.05;
            value = true;
            immuneTime = 7;
            death_num = 0;
            vaccs_distributed = 0;
            arena=30;
        end
        
        % Create UIFigure and components
        function createComponents(app)
            
            global numAgents infStart endTime vacc_rate immuneTime arena
            
            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.Resize = 'off';
            
            % Create EndTimeSliderLabel
            app.EndTimeSliderLabel = uilabel(app.UIFigure);
            app.EndTimeSliderLabel.HorizontalAlignment = 'right';
            app.EndTimeSliderLabel.Position = [1 79 56 22];
            app.EndTimeSliderLabel.Text = 'End Time';
            
            % Create EndTimeSlider
            app.EndTimeSlider = uislider(app.UIFigure);
            app.EndTimeSlider.Limits = [25 1000];
            app.EndTimeSlider.ValueChangedFcn = createCallbackFcn(app, @EndTimeSliderValueChanged, true);
            app.EndTimeSlider.Position = [78 88 150 3];
            app.EndTimeSlider.Value = endTime;
            
            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes.XLim = [0 arena];
            app.UIAxes.YLim = [0 arena];
            app.UIAxes.Box = 'on';
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [239 58 385 385];
            
            % Create VaccRateEditFieldLabel
            app.VaccRateEditFieldLabel = uilabel(app.UIFigure);
            app.VaccRateEditFieldLabel.HorizontalAlignment = 'right';
            app.VaccRateEditFieldLabel.Position = [21 262 92 22];
            app.VaccRateEditFieldLabel.Text = 'Vacc Rate';
            
            % Create VaccRateEditField
            app.VaccRateEditField = uieditfield(app.UIFigure, 'numeric');
            app.VaccRateEditField.ValueChangedFcn = createCallbackFcn(app, @VaccRateEditFieldChanged, true);
            app.VaccRateEditField.Limits = [0 1];
            app.VaccRateEditField.Position = [128 262 100 22];
            app.VaccRateEditField.Value = vacc_rate;
            
            % Create BeginButton
            app.BeginButton = uibutton(app.UIFigure, 'push');
            app.BeginButton.ButtonPushedFcn = createCallbackFcn(app, @BeginButtonPushed, true);
            app.BeginButton.BackgroundColor = [0.4706 0.6706 0.1882];
            app.BeginButton.FontSize = 24;
            app.BeginButton.Tooltip = {'Once you have set your variables'; ' click here to begin simulation.'};
            app.BeginButton.Position = [28 143 200 70];
            app.BeginButton.Text = 'Begin';
            
            % Create StartInfectedSpinnerLabel
            app.StartInfectedSpinnerLabel = uilabel(app.UIFigure);
            app.StartInfectedSpinnerLabel.HorizontalAlignment = 'right';
            app.StartInfectedSpinnerLabel.Position = [35 333 78 22];
            app.StartInfectedSpinnerLabel.Text = 'Start Infected';
            
            % Create StartInfectedSpinner
            app.StartInfectedSpinner = uispinner(app.UIFigure);
            app.StartInfectedSpinner.Limits = [0 99];
            app.StartInfectedSpinner.ValueChangedFcn = createCallbackFcn(app, @StartInfectedSpinnerValueChanged, true);
            app.StartInfectedSpinner.Position = [128 333 100 22];
            app.StartInfectedSpinner.Value = infStart;
            
            % Create AgentsSpinnerLabel
            app.AgentsSpinnerLabel = uilabel(app.UIFigure);
            app.AgentsSpinnerLabel.HorizontalAlignment = 'right';
            app.AgentsSpinnerLabel.Position = [70 366 43 22];
            app.AgentsSpinnerLabel.Text = 'Agents';
            
            % Create AgentsSpinner
            app.AgentsSpinner = uispinner(app.UIFigure);
            app.AgentsSpinner.Limits = [2 250];
            app.AgentsSpinner.ValueDisplayFormat = '%g';
            app.AgentsSpinner.ValueChangedFcn = createCallbackFcn(app, @AgentsSpinnerValueChanged, true);
            app.AgentsSpinner.Position = [128 366 100 22];
            app.AgentsSpinner.Value = numAgents;
            
            % Create ImmuneSpinnerLabel
            app.ImmuneSpinnerLabel = uilabel(app.UIFigure);
            app.ImmuneSpinnerLabel.HorizontalAlignment = 'right';
            app.ImmuneSpinnerLabel.Position = [66 297 47 22];
            app.ImmuneSpinnerLabel.Text = 'T_Immune';
            
            % Create ImmuneSpinner
            app.ImmuneSpinner = uispinner(app.UIFigure);
            app.ImmuneSpinner.Limits = [0 Inf];
            app.ImmuneSpinner.ValueDisplayFormat = '%g';
            app.ImmuneSpinner.ValueChangedFcn = createCallbackFcn(app, @ImmuneSpinnerValueChanged, true);
            app.ImmuneSpinner.Position = [128 297 100 22];
            app.ImmuneSpinner.Value = immuneTime;
            
            % Create DeadLabel
            app.DeadLabel = uilabel(app.UIFigure);
            app.DeadLabel.HorizontalAlignment = 'right';
            app.DeadLabel.Position = [4 14 39 22];
            app.DeadLabel.Text = 'Dead:';
            
            % Create DeadLamp
            app.DeadLamp = uilamp(app.UIFigure);
            app.DeadLamp.Position = [58 5 40 40];
            app.DeadLamp.Color = [0.149 0.149 0.149];
            
            % Create ShowAgentsSwitch
            app.ShowAgentsSwitch = uiswitch(app.UIFigure, 'slider');
            app.ShowAgentsSwitch.Items = {'Off', 'Show Agents'};
            app.ShowAgentsSwitch.ValueChangedFcn = createCallbackFcn(app, @ShowAgentsSwitchValueChanged, true);
            app.ShowAgentsSwitch.Position = [105 222 45 20];
            app.ShowAgentsSwitch.Tooltip = {'Turn off for taxing simulations.'};
            app.ShowAgentsSwitch.Value = 'Show Agents';
            
            % Create SusceptibleLabel
            app.SusceptibleLabel = uilabel(app.UIFigure);
            app.SusceptibleLabel.HorizontalAlignment = 'right';
            app.SusceptibleLabel.Position = [117 14 72 22];
            app.SusceptibleLabel.Text = 'Susceptible:';
            
            % Create SusceptibleLamp
            app.SusceptibleLamp = uilamp(app.UIFigure);
            app.SusceptibleLamp.Position = [204 5 40 40];
            app.SusceptibleLamp.Color = [0 0 1];
            
            % Create VaccinatedLampLabel
            app.VaccinatedLampLabel = uilabel(app.UIFigure);
            app.VaccinatedLampLabel.HorizontalAlignment = 'right';
            app.VaccinatedLampLabel.Position = [263 14 68 22];
            app.VaccinatedLampLabel.Text = 'Vaccinated:';
            
            % Create VaccinatedLamp
            app.VaccinatedLamp = uilamp(app.UIFigure);
            app.VaccinatedLamp.Position = [346 5 40 40];
            app.VaccinatedLamp.Color = [1 1 0];
            
            % Create ImmuneLampLabel
            app.ImmuneLampLabel = uilabel(app.UIFigure);
            app.ImmuneLampLabel.HorizontalAlignment = 'right';
            app.ImmuneLampLabel.Position = [405 14 52 22];
            app.ImmuneLampLabel.Text = 'Immune:';
            
            % Create ImmuneLamp
            app.ImmuneLamp = uilamp(app.UIFigure);
            app.ImmuneLamp.Position = [472 5 40 40];
            
            % Create InfectedLampLabel
            app.InfectedLampLabel = uilabel(app.UIFigure);
            app.InfectedLampLabel.HorizontalAlignment = 'right';
            app.InfectedLampLabel.Position = [530 14 52 22];
            app.InfectedLampLabel.Text = 'Infected:';
            
            % Create InfectedLamp
            app.InfectedLamp = uilamp(app.UIFigure);
            app.InfectedLamp.Position = [597 5 40 40];
            app.InfectedLamp.Color = [1 0 0];
            
            % Create DeadNum
            app.DeadNum = uilabel(app.UIFigure);
            app.DeadNum.HorizontalAlignment = 'right';
            app.DeadNum.FontName = 'Courier New';
            app.DeadNum.FontSize = 10;
            app.DeadNum.FontWeight = 'bold';
            app.DeadNum.FontColor = [1 1 1];
            app.DeadNum.Position = [63 14 25 22];
            app.DeadNum.Text = '000';
            
            % Create SusceptibleNum
            app.SusceptibleNum = uilabel(app.UIFigure);
            app.SusceptibleNum.HorizontalAlignment = 'right';
            app.SusceptibleNum.FontName = 'Courier New';
            app.SusceptibleNum.FontSize = 10;
            app.SusceptibleNum.FontWeight = 'bold';
            app.SusceptibleNum.FontColor = [1 1 1];
            app.SusceptibleNum.Position = [209 14 25 22];
            app.SusceptibleNum.Text = '000';
            
            % Create VaccinatedNum
            app.VaccinatedNum = uilabel(app.UIFigure);
            app.VaccinatedNum.HorizontalAlignment = 'right';
            app.VaccinatedNum.FontName = 'Courier New';
            app.VaccinatedNum.FontSize = 10;
            app.VaccinatedNum.FontWeight = 'bold';
            app.VaccinatedNum.Position = [351 14 25 22];
            app.VaccinatedNum.Text = '000';
            
            % Create ImmuneNum
            app.ImmuneNum = uilabel(app.UIFigure);
            app.ImmuneNum.HorizontalAlignment = 'right';
            app.ImmuneNum.FontName = 'Courier New';
            app.ImmuneNum.FontSize = 10;
            app.ImmuneNum.FontWeight = 'bold';
            app.ImmuneNum.Position = [477 14 25 22];
            app.ImmuneNum.Text = '000';
            
            % Create InfectedNum
            app.InfectedNum = uilabel(app.UIFigure);
            app.InfectedNum.HorizontalAlignment = 'right';
            app.InfectedNum.FontName = 'Courier New';
            app.InfectedNum.FontSize = 10;
            app.InfectedNum.FontWeight = 'bold';
            app.InfectedNum.FontColor = [1 1 1];
            app.InfectedNum.Position = [601 14 25 22];
            app.InfectedNum.Text = '000';
            
            % Create TimeGaugeLabel
            app.TimeGaugeLabel = uilabel(app.UIFigure);
            app.TimeGaugeLabel.HorizontalAlignment = 'center';
            app.TimeGaugeLabel.Position = [104.5 451 32 22];
            app.TimeGaugeLabel.Text = 'Time';
            
            % Create TimeGauge
            app.TimeGauge = uigauge(app.UIFigure, 'ninetydegree');
            app.TimeGauge.Limits = [0 endTime];
            app.TimeGauge.Orientation = 'southeast';
            app.TimeGauge.Position = [1 391 90 90];
            app.TimeGauge.Value = 0;
        end
    end
    
    methods (Access = public)
        
        % Construct app
        function app = app1
            
            clearvars -except app1;
            clc;
            close all;
            
            % Create and configure components
            setGlobals(app);
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end