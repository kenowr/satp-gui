%% Script to generate all GUI windows for SATP validation experiment.
% 
% This script will call the sub_ui function to generate each individual
% window for the SATP validation experiment, collect the results obtained
% for each stimulus, and attempt to save the final results into a .mat and
% .csv file. The order of presentation of stimuli is randomised by this
% script.
%
% The final results are stored as a 27-by-11 matrix, with each row
% corresponding to all responses for a single stimulus, and the columns
% corresponding to the following:
%   Column 1 = Serial number of track (integer values in the range [1,27]).
%   Columns 2-9 = Responses to each of the eight (translated) semantic
%                 differential attributes.
%   Column 10 = A boolean value denoting whether the "Play sound" button
%               was pressed at least once for each stimulus. 0 if no, 1 if
%               yes.
%   Column 11 = A floating-point value denoting the number of seconds spent
%               by the participant on that particular set.
% The rows in the matrix are recorded in the order of presentation of
% stimuli to the participant. For example, if the stimuli were (randomly)
% presented in the order 20, 8, 15, 6, ..., then the numbers going down
% column 1 would be exactly 20, 8, 15, 6, ...
%
% To use this script, simply rename all the audio stimuli that you will be
% using for the validation experiment to "track_n.wav", where n is the
% stimulus index, and place them in the "../stimuli" folder. This
% repository already has some sample placeholder tracks in the "../stimuli"
% folder, so you can just run the script as-is to observe how it works.
%
% The script will ask you whether you want to open debug mode when you
% start it up. We advise you to open debug mode only for your own internal
% use; you should not be using debug mode when you use this script to carry
% out the actual validation experiment with participants.
%
% This is because we have included some features in the GUI script to
% prevent accidental (or purposeful) errors made by participants while they
% are completing the questionnaire. The features are:
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
%
% Please note that in debug mode,
%  1) A line of red text will appear on the GUI windows stating that you
%     are in debug mode, as well as the true index of the track that will
%     be played when the "Play sound" button is played.
%  2) Sliders will appear at all times.
%  3) GUI windows can be closed regularly by clicking on the 'X' icon.
% 
% Please feel free to use this script and the associated function sub_ui
% for your respective SATP validation experiments. You should translate all
% text in the GUI windows into the language that you are running the
% validation experiments for, however.
% 
% This script and its associated function sub_ui were written in MATLAB
% R2018b, so as long as your MATLAB version is R2018b or later, there
% should be no issues with running the script. In addition, while the GUI
% elements have been defined to resize according to your screen resolution,
% I originally tested it on a screen resolution of 1920x1080. Hence, if
% there are any display issues, please try setting your screen resolution
% to 1920x1080 and see if they are fixed.
%
% In any case, if you experience any bugs or problems running this script,
% please drop me (Kenneth Ooi) an email at wooi002@e.ntu.edu.sg. You may
% also repurpose the script for any other subjective experiments that you
% may be running, but in that case I would appreciate it if you could
% acknowledge me in any work or publication that results from that.
% Thank you :)

%% Initialisation

n_stimuli = 27; % This is the number of stimuli used for the SATP validation experiments.
results = nan(n_stimuli,11);
rand_mat = randperm(n_stimuli); % A 1x27 vector containing rearrangements of the tracks used for the validation experiment.
stimuli_dir = '../stimuli/'; % You may change this to a different directory if you wish; it should the directory where all the (calibrated) stimuli are stored.

%% Ask user if they want to enter debug mode.

while true
    debug_mode = input('Do you want to enter debug mode? Enter 0 if you do not and 1 if you do: ');
    if debug_mode == 0 || debug_mode == 1
        break
    else
        fprintf('You entered an invalid value. Please enter 0 or 1 only.\n');
    end
end

%% Open GUI windows.

for set_no = 1:n_stimuli % Each stimulus forms a set; we iterate through all of them (randomly) here.
    try
        % Start the timer for the particular set
        tic
        
        % Call sub_ui to get the participant inputs for the present stimulus.
        [sd_1, sd_2, sd_3, sd_4, sd_5, sd_6, sd_7, sd_8, pressed] =... 
            sub_ui(set_no, rand_mat(set_no), [stimuli_dir, 'track_', num2str(rand_mat(set_no)), '.wav'], debug_mode);  % The path to the particular track for the current set is built using the [...] part.

        % Then, store the values obtained for the current set in the results matrix in the corresponding row.
        results(set_no,:) = [rand_mat(set_no), sd_1, sd_2, sd_3, sd_4, sd_5, sd_6, sd_7, sd_8, pressed, toc];
    catch
        continue
    end
end

%% Save the results matrix as both a .mat and a .csv file 
% We iteratively append '_new' to the filenames 'results.mat' and
% 'results.csv' if they already exist to prevent overwriting existing
% files. The same number of '_new' will be appended to both .mat and .csv
% files saved in the same session. 

base_filename = 'results';

while isfile([base_filename '.mat']) || isfile([base_filename '.csv'])
    base_filename = [base_filename '_new'];
end

save([base_filename '.mat'],'results');
csvwrite([base_filename '.csv'],results);

%% Show status screen after experiment is complete.

if ~all(results(:,end)) || any(any(isnan(results))) % not all "Play sound" buttons pressed || any NaNs left in the results matrix
    figure;
    uicontrol('Style','text',...
              'FontSize',20,...
              'Position',[40 155 500 100],...
              'String','Results saved but have errors - Please inform facilitator.');
else
    figure;
    uicontrol('Style','text',...
              'FontSize',20,...
              'Position',[40 155 500 100],...
              'String','Experiment ended successfully - Please inform facilitator.');
end