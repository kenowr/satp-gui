%% Function to generate a single GUI window for SATP validation experiment
%
% Please run this function in the main script main.m.
%
% Input arguments:
%   set_no : integer in range [1,27]
%       The question set number (integers from 1-27).
%   track_no : integer in range [1,27]
%       The track number that is played when the "Play sound" button is
%       pressed (integers from 1-27). Note that this is different from
%       set_no, because (for example) if the participant is presented with
%       track 15 as the first stimulus, this would correspond to track_no =
%       15 and set_no = 1.
%   track_name : string
%       The name of the file used for track_no.
%   debug_mode : boolean
%       If true, displays debug mode status messages on the GUI, displays
%       sliders always, and allows GUI windows to be closed when the 'X'
%       button is clicked. If false, displays sliders only after the
%       stimulus is heard in full at least once, and disallows GUI windows
%       to be closed when the 'X' button is clicked. Use false when running
%       the actual experiment for participants.
%
% Output arguments:
%   sd_x : integer in range [0,100]
%       The rating on the x-th SD scale of 0 to 100 as chosen by the
%       participant.
%   pressed : boolean
%       True if the "Play sound" button has been pressed at least once for
%       the current set, false otherwise.
%
% Extra notes on debug vs non-debug mode:
% In non-debug mode,
%  1) Participant may not submit their answers unless (A) the "Play sound"
%     button has been clicked on at least once (i.e. they have listened to
%     the track at least once), and (B) all the sliders have been clicked
%     on at least once (i.e. they have answered all the questions). If
%     either of the two conditions is not fulfilled, clicking on the
%     "Submit answers" button does nothing.
%  2) "Stop sound" button does not work when a stimulus is being played
%     for the first time. This is to ensure that the participants have
%     listened to the track in full at least once.
%  3) Sliders will not appear until the stimulus has finished playing for
%     the first time.
%  4) GUI windows cannot be closed by clicking on the 'X' icon (the entire
%     sequence of stimuli must be completed or the MATLAB process must be
%     forcibly closed (e.g. by Ctrl+Alt+Del) to close them).
% However, in debug mode,
%  1) A line of red text will appear on the GUI windows stating that you
%     are in debug mode, as well as the true index of the track that will
%     be played when the "Play sound" button is played.
%  2) Sliders will appear at all times.
%  3) GUI windows can be closed regularly by clicking on the 'X' icon.
% 
% Please feel free to use this function and its associated script main.m
% for your respective SATP validation experiments. You should translate all
% text in the GUI windows into the language that you are running the
% validation experiments for, however.
% 
% This function and its associated script main.m were written in MATLAB
% R2018b, so as long as your MATLAB version is R2018b or later, there
% should be no issues with running the script. In addition, while the GUI
% elements have been defined to resize according to your screen resolution,
% I originally tested it on a screen resolution of 1920x1080. Hence, if
% there are any display issues, please try setting your screen resolution
% to 1920x1080 and see if they are fixed.
%
% In any case, if you experience any bugs or problems running this code,
% please drop me (Kenneth Ooi) an email at wooi002@e.ntu.edu.sg. You may
% also repurpose the function for any other subjective experiments that you
% may be running, but in that case I would appreciate it if you could
% acknowledge me in any work or publication that results from that.
% Thank you :)

function [sd_1, sd_2, sd_3, sd_4, sd_5, sd_6, sd_7, sd_8, pressed] =... 
    sub_ui(set_no, track_no, track_name, debug_mode)

%% Initialise global variables for output

    sd_1 = NaN;   sd_2 = NaN;  sd_3 = NaN;  sd_4 = NaN;  
    sd_5 = NaN;   sd_6 = NaN;  sd_7 = NaN;  sd_8 = NaN;
    
    pressed = false; % By default, "Play sound" button has not been pressed when the GUI window is created initially.
    
%% Declare audio player object.

    [y,Fs] = audioread(track_name); % Read the track (.wav file) from track_name.
    player = audioplayer(y, Fs);
    set(player, 'StopFcn', @stop_function_player); % Defines callback function to run when playback is complete.

%% Create GUI as dialog box.

if debug_mode
    CloseRequestFcnOption = 'closereq';
    VisibleOptions = 'on';
else
    CloseRequestFcnOption = ''; % Prevents dialog box from being closed by user.
    VisibleOptions = 'off'; % Shows sliders only after track is played at least once.
end

UI = dialog('Units','normalized',...
            'Position',[0.05 0.05 0.9 0.9],... % If you wish to resize the dialog, change the last two elements of this vector.
            'Name','SATP Validation Experiment',...
            'DefaultUIControlFontSize', 14,...
            'CloseRequestFcn',CloseRequestFcnOption);
        
%% Create other GUI elements

defaultParams = struct('Parent',UI,'Units','normalized','FontUnits','normalized'); % Define a structure of the default parameter values that we will feed to all uicontrol objects.

text_set_no = uicontrol(defaultParams, 'Style','text', 'FontSize',0.8, 'FontWeight','bold',...
                        'Position',[0 0.94 1.0000 0.05],...
                        'String',['Set ', num2str(set_no), '/27']); % This is the set number counter at the top centre of the window.

instructions = uicontrol(defaultParams, 'Style','text', 'FontSize',0.07, 'Position',[0.05,0.59,0.9,0.35], 'String',...
               {'Press "Play sound" to hear the present sound environment. After listening to the track at least once, sliders will appear for you to answer the',...
                'questions below. Please answer only after you have listened to the track at least once. Please click or drag all sliders at least once such that',...
                'the values match your desired rating on a scale of 0 to 100. You may listen to the track for as many times as necessary to answer the questions.',...
                'Please note that the "Stop sound" button will only work after you have listened to the track at least once.'}); % This is the instruction text.

pb_play = uicontrol(defaultParams, 'FontSize',0.38,...
                    'Position',[0.18 0.71 0.20 0.07],...
                    'String','Play sound',...
                    'Callback',@play_sound); % Play button (the callback function play_sound is at the end of this function's definition)
     
pb_stop = uicontrol(defaultParams, 'FontSize',0.38,...
                    'Position',[0.40 0.71 0.20 0.07],...
                    'String','Stop sound',...
                    'Callback',@stop_sound); % Stop button (the callback function stop_sound is at the end of this function's definition)
                
pb_submit = uicontrol(defaultParams, 'FontSize',0.38,...
                      'Position',[0.62 0.71 0.20 0.07],...
                      'String','Submit answers',...
                      'Callback',@submit); % Submit button (the callback function submit is at the end of this function's definition)
                
text_line_2 = uicontrol(defaultParams, 'Style','text', 'FontSize', 0.62, 'Position',[0.05 0.64 0.9 0.04],'String',...
                        'For each of the 8 scales below, to what extent do you agree or disagree that the present surrounding sound environment is...');


% Semantic differential scale 1
sliderPosition1 = [0.18 0.56 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_1T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition1 + [0 0.04 0 0],...
                      'String','(1) ...pleasant?');
text_sd_1L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition1 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_1R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition1 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_1 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition1, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_1);
slider_val_1 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition1 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.'); 

% Semantic differential scale 2
sliderPosition2 = [0.18 0.40 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_2T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition2 + [0 0.04 0 0],...
                      'String','(2) ...chaotic?');
text_sd_2L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition2 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_2R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition2 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_2 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition2, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_2);
slider_val_2 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition2 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.');
                  
% Semantic differential scale 3
sliderPosition3 = [0.18 0.24 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_3T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition3 + [0 0.04 0 0],...
                      'String','(3) ...vibrant?');
text_sd_3L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition3 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_3R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition3 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_3 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition3, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_3);
slider_val_3 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition3 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.'); 

% Semantic differential scale 4
sliderPosition4 = [0.18 0.08 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_4T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition4 + [0 0.04 0 0],...
                      'String','(4) ...uneventful?');
text_sd_4L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition4 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_4R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition4 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_4 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition4, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_4);
slider_val_4 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition4 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.'); 
                  
% Semantic differential scale 5
sliderPosition5 = [0.64 0.56 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_5T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition5 + [0 0.04 0 0],...
                      'String','(5) ...calm?');
text_sd_5L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition5 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_5R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition5 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_5 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition5, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_5);
slider_val_5 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition5 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.');  
                  
% Semantic differential scale 6
sliderPosition6 = [0.64 0.40 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_6T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition6 + [0 0.04 0 0],...
                      'String','(6) ...annoying?');
text_sd_6L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition6 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_6R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition6 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_6 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition6, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_6);
slider_val_6 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition6 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.');  

% Semantic differential scale 7
sliderPosition7 = [0.64 0.24 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_7T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition7 + [0 0.04 0 0],...
                      'String','(7) ...eventful?');
text_sd_7L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition7 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_7R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition7 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_7 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition7, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_7);
slider_val_7 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition7 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.');     
                  
% Semantic differential scale 8
sliderPosition8 = [0.64 0.08 0.18 0.04]; % Define the slider's position here; everything else is relative to it.

text_sd_8T = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62,...
                      'Position',sliderPosition8 + [0 0.04 0 0],...
                      'String','(8) ...monotonous?');
text_sd_8L = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition8 + [-0.16 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly disagree');
text_sd_8R = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position',sliderPosition8 + [0.15 -0.003 0 0],...
                      'Visible',VisibleOptions,'String','Strongly agree'); 
slider_8 = uicontrol(defaultParams, 'Style','slider', 'Position',sliderPosition8, 'Value',0.5,...
                     'Visible',VisibleOptions, 'Callback',@answer_8);
slider_val_8 = uicontrol(defaultParams, 'Style','text', 'FontSize',0.62, 'Position', sliderPosition8 + [0 -0.05 0 0],...
                         'ForegroundColor',[1 1 1], 'BackgroundColor', [0 0 0],'Visible',VisibleOptions,...
                         'String','Please click on the slider.');    

%% Create debugging element for debug mode

if debug_mode
    debugging_text = uicontrol(defaultParams,'Style','text', 'FontSize',0.7, 'ForegroundColor', 'red',...
                               'Position', [0.02 0.95 0.4 0.04],...
                               'String', ['In debug mode! Actual track no = ', num2str(track_no)]);
end

error_text = uicontrol(defaultParams,'Style','text', 'FontSize',0.5, 'ForegroundColor', 'red',...
                       'Position', [0.6 0.95 0.45 0.04],...
                       'String', '');

%% Wait for figure to be closed

uiwait(UI); %IMPORTANT: This line allows outputs to appear only AFTER the GUI window is closed.

%% Callback functions
    % Note that ~ ignores input arguments in a function definition.
    
    function stop_sound(~,~)
        % Stop player if the "Play sound" button has been pressed at least once.
        if pressed && isplaying(player)
            stop(player);
        elseif ~pressed && isplaying(player)
            error_text.String = 'Please listen to the entire track first!';
        end
    end
    
    function play_sound(source,~) % Plays sound.
        % Stop player if the "Play sound" button has been pressed at least once (this prevents layering of the same sound multiple times when play(player) is called later).
        if pressed && isplaying(player)
            stop(player);
        end
        
        source.BackgroundColor = 'green'; % Button changes to green colour during playback.
        play(player);
    end


    function answer_1(source,~) % Accepts user input for SD scale 1 value.
        sd_1 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_1.String = num2str(sd_1); % Display the current slider value in the associated text box.
    end
    function answer_2(source,~) % Accepts user input for SD scale 2 value.
        sd_2 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_2.String = num2str(sd_2); % Display the current slider value in the associated text box.
    end
    function answer_3(source,~) % Accepts user input for SD scale 3 value.
        sd_3 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_3.String = num2str(sd_3); % Display the current slider value in the associated text box.
    end
    function answer_4(source,~) % Accepts user input for SD scale 4 value.
        sd_4 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_4.String = num2str(sd_4); % Display the current slider value in the associated text box.
    end
    function answer_5(source,~) % Accepts user input for SD scale 5 value.
        sd_5 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_5.String = num2str(sd_5); % Display the current slider value in the associated text box.
    end
    function answer_6(source,~) % Accepts user input for SD scale 6 value.
        sd_6 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_6.String = num2str(sd_6); % Display the current slider value in the associated text box.
    end
    function answer_7(source,~) % Accepts user input for SD scale 7 value.
        sd_7 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_7.String = num2str(sd_7); % Display the current slider value in the associated text box.
    end
    function answer_8(source,~) % Accepts user input for SD scale 8 value.
        sd_8 = round(source.Value*100); % By default, MATLAB sliders record floating-point values in the interval [0,1]. We convert this to an integer value in [0,100] here.
        slider_val_8.String = num2str(sd_8); % Display the current slider value in the associated text box.
    end


    function submit(~,~) % Closes window after user presses 'Submit' button. But only if all inputs are valid and all questions are answered. Otherwise window is not closed.
        if ~pressed
            error_text.String = 'Error: Please click on the "Play sound" button to listen to the track first!';
        elseif isnan(sd_1) || isnan(sd_2) || isnan(sd_3) || isnan(sd_4) || isnan(sd_5) || isnan(sd_6) || isnan(sd_7) || isnan(sd_8)
            error_text.String = 'Error: Please answer all questions before submitting your answers!';
        else % In this case, all outputs are fine.
            if isplaying(player) % Close the player if it's still playing.
                stop(player)
            end
            delete(gcf); % Close the dialog window.
        end
    end


    function stop_function_player(~, ~) % After player finishes playing, "Play sound" button is considered to have been pressed.
        pressed = true; % Hence we set pressed to true here.
        pb_play.BackgroundColor = [240/255,240/255,240/255]; % Make the matrix go back to grey colour. Matrix is RGB in range 0 to 1 inclusive.
        
        % Display sliders for participant to respond.
        slider_1.Visible = 'on'; text_sd_1L.Visible = 'on'; text_sd_1R.Visible = 'on'; slider_val_1.Visible = 'on';
        slider_2.Visible = 'on'; text_sd_2L.Visible = 'on'; text_sd_2R.Visible = 'on'; slider_val_2.Visible = 'on';
        slider_3.Visible = 'on'; text_sd_3L.Visible = 'on'; text_sd_3R.Visible = 'on'; slider_val_3.Visible = 'on';
        slider_4.Visible = 'on'; text_sd_4L.Visible = 'on'; text_sd_4R.Visible = 'on'; slider_val_4.Visible = 'on';
        slider_5.Visible = 'on'; text_sd_5L.Visible = 'on'; text_sd_5R.Visible = 'on'; slider_val_5.Visible = 'on';
        slider_6.Visible = 'on'; text_sd_6L.Visible = 'on'; text_sd_6R.Visible = 'on'; slider_val_6.Visible = 'on';
        slider_7.Visible = 'on'; text_sd_7L.Visible = 'on'; text_sd_7R.Visible = 'on'; slider_val_7.Visible = 'on';
        slider_8.Visible = 'on'; text_sd_8L.Visible = 'on'; text_sd_8R.Visible = 'on'; slider_val_8.Visible = 'on';
    end
end