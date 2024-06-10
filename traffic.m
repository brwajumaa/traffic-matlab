classdef traffic < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private)
        UIFigure             matlab.ui.Figure
        ImageAxes            matlab.ui.control.UIAxes
        UploadButton         matlab.ui.control.Button
        DetectButton         matlab.ui.control.Button
        ResultLabel          matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: UploadButton
        function uploadImage(app, event)
            [file, path] = uigetfile({'*.jpg;*.png'}, 'Select Image');
            if isequal(file, 0) || isequal(path, 0)
                return; % User canceled the dialog
            end
            imagePath = fullfile(path, file);
            imshow(imagePath, 'Parent', app.ImageAxes);
            app.ResultLabel.Text = '';
        end

        % Button pushed function: DetectButton
        function detectColors(app, event)
            % Get the image from the axes
            img = app.ImageAxes.Children.CData;

            % Perform color detection
            try
                % Convert image to LAB color space
                labImg = rgb2lab(img);

                % Extract color channels
                L = labImg(:,:,1);
                a = labImg(:,:,2);
                b = labImg(:,:,3);

                % Define color thresholds for red, green, and yellow
                redThreshold = L < 60 & a > 30 & b > 10;
                greenThreshold = L > 60 & a < -30 & b > 10;
                yellowThreshold = L > 60 & a < -10 & b < -10;

                % Calculate the number of pixels in each color region
                redCount = sum(redThreshold(:));
                greenCount = sum(greenThreshold(:));
                yellowCount = sum(yellowThreshold(:));

                % Determine the dominant color
                [~, colorIdx] = max([redCount, greenCount, yellowCount]);

                % Display result in pop-up dialog with animation
                if colorIdx == 1
                    app.showResultDialog('RED - STOP', 'red');
                elseif colorIdx == 2
                    app.showResultDialog('GREEN - GO', 'green');
                elseif colorIdx == 3
                    app.showResultDialog('YELLOW - SLOW DOWN', 'yellow');
                else
                    app.showResultDialog('UNKNOWN', 'unknown');
                end
            catch
                app.showResultDialog('Error: Failed to detect colors.', 'error');
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            % Create UIFigure and configure properties
            app.UIFigure = uifigure('Name', 'Traffic Light Recognizer');
            app.UIFigure.Position = [100, 100, 600, 500];
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @fixWindowSize, true);

            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            app.ImageAxes.Position = [25, 250, 550, 200];

            % Create UploadButton
            app.UploadButton = uibutton(app.UIFigure, 'push');
            app.UploadButton.ButtonPushedFcn = createCallbackFcn(app, @uploadImage, true);
            app.UploadButton.Position = [50, 200, 150, 30];
            app.UploadButton.Text = 'Upload Image';

            % Create DetectButton
            app.DetectButton = uibutton(app.UIFigure, 'push');
            app.DetectButton.ButtonPushedFcn = createCallbackFcn(app, @detectColors, true);
            app.DetectButton.Position = [250, 200, 150, 30];
            app.DetectButton.Text = 'Detect Colors';

            % Create ResultLabel
            app.ResultLabel = uilabel(app.UIFigure);
            app.ResultLabel.Position = [50, 150, 500, 30];
            app.ResultLabel.Text = '';
            app.ResultLabel.FontWeight = 'bold';
        end

        % Fix window size to the original specified size
        function fixWindowSize(app, event)
            app.UIFigure.Position(3:4) = [600, 500];
        end
    end

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Display welcome message
            msg = 'Welcome to Traffic Light Recognizer App! Developed By Shano & Manar for "Digital Image Processing".';
            uialert(app.UIFigure, msg, 'Information', 'Icon', 'info');
        end

        % Show result dialog with animation
        function showResultDialog(app, message, color)
            dlg = uiprogressdlg(app.UIFigure, 'Title', 'Color Detection Result', ...
                'Message', 'Detecting colors...', 'Indeterminate', 'on');
            pause(1); % Simulate detection process
            close(dlg);
            if strcmp(color, 'red')
                uialert(app.UIFigure, message, 'Color Detection Result', 'Icon', 'error');
            else
                uialert(app.UIFigure, message, 'Color Detection Result', 'Icon', 'success');
            end
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = traffic
            % Create and configure components
            createComponents(app);

            % Register the app with App Designer
            registerApp(app, app.UIFigure);

            % Execute the startup function
            runStartupFcn(app, @startupFcn);

            if nargout == 0
                clear app;
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure);
        end
    end
end
