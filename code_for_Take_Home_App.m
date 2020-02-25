classdef Chris_Dussourd_Take_Home < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        file_directory_label  matlab.ui.control.Label
        user_value_label      matlab.ui.control.Label
        file_directory_edit   matlab.ui.control.EditField
        user_value_edit       matlab.ui.control.EditField
        StartButton           matlab.ui.control.Button
        StartButton_Label     matlab.ui.control.Label
        Display_Results       matlab.ui.control.TextArea
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            %Clear the text output (if it already has text)
            app.Display_Results.Value='';
            found_items=check_json(app.file_directory_edit.Value,app.user_value_edit.Value);
            %Print out the items found in the json format. Add next lines and tabs to character array
            n=0; %Number of '{' or '[' (need to add more tabs to match json format output)
            i=1;
            while i<=length(found_items)
                if found_items(i)=='{' || found_items(i)=='['
                    n=n+1; %Found another '{' or '['. Use blanks to add a tab.
                    found_items=[found_items(1:i) '\n' blanks(5*n) found_items(i+1:end)];
                    i=i+2+5*n; % Update i with the new values added to found_items
                end
                if found_items(i)=='}' || found_items(i)==']'
                    n=n-1; %Take out the blank spaces (unindent by one tab)
                    found_items=[found_items(1:i-1) '\n' blanks(5*n) found_items(i:end)];
                    i=i+2+5*n;
                end
                if found_items(i)==','
                    %Add a line space
                    found_items=[found_items(1:i) '\n' blanks(5*n) found_items(i+1:end)];
                    i=i+2+5*n; % Update i with the new values added to found_items
                end
                i=i+1;
            end
            app.Display_Results.Value=sprintf(found_items);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create file_directory_label
            app.file_directory_label = uilabel(app.UIFigure);
            app.file_directory_label.Position = [30 436 416 22];
            app.file_directory_label.Text = 'Enter in the directory of the json file (if blank you can browse to it''s location):';

            % Create user_value_label
            app.user_value_label = uilabel(app.UIFigure);
            app.user_value_label.Position = [30 365 382 22];
            app.user_value_label.Text = 'Please enter a character, word, or phrase to search for in the json file:';

            % Create file_directory_edit
            app.file_directory_edit = uieditfield(app.UIFigure, 'text');
            app.file_directory_edit.Position = [30 403 404 22];

            % Create user_value_edit
            app.user_value_edit = uieditfield(app.UIFigure, 'text');
            app.user_value_edit.Position = [30 331 404 22];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [30 271 100 22];
            app.StartButton.Text = 'Start';

            % Create StartButton_Label
            app.StartButton_Label = uilabel(app.UIFigure);
            app.StartButton_Label.Position = [30 292 136 28];
            app.StartButton_Label.Text = 'Push button to run code:';

            % Create Display_Results
            app.Display_Results = uitextarea(app.UIFigure);
            app.Display_Results.Editable = 'off';
            app.Display_Results.Position = [30 1 611 243];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Chris_Dussourd_Take_Home

            % Create UIFigure and components
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