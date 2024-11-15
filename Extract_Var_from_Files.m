function VarCell = Extract_Var_from_Files(regexPattern,VarName)
    % Extract_Var_from_Files
    % This function loads .mat files with a specific naming format from the user-specified folder and its subfolders,
    % and extracts the variable named VarName from each file.
    % The user will select the folder using a file selection dialog.
    % The file naming format is regexPattern, for example "data_XXXX.mat", where XXXX is a number.
    % The corresponding regular expression is regexPattern = 'data_\d{4}\.mat'.
    % Open the file selection dialog for the user to choose a folder
    folderPath = uigetdir('', 'Select the folder containing the required .mat files');
    % Check if the user canceled the selection
    if isequal(folderPath, 0)
        disp('No folder selected, program exits.');
        return;
    end
    % Call the recursive function to traverse folders and subfolders
    VarCell = recursive_extract_Var(folderPath, regexPattern,VarName);
    % Check if the Var variable has been extracted
    if ~isempty(VarCell)
        disp(['Variable ', VarName, ' has been extracted from all qualifying files!']);
    else
        disp(['No files with the correct naming format were found or the files do not contain the ', VarName, ' variable!']);
    end
end
function VarCell = recursive_extract_Var(folderPath, regexPattern,VarName)
    % recursive_extract_Var
    % Recursive function to traverse folders and subfolders, load .mat files with the correct naming format,
    % and extract the variable named "VarName" from each file.
    % Initialize the output cell array
    VarCell = {};
    % Get all files and folders in the specified folder
    items = dir(folderPath);
    % Loop through all items
    for i = 1:length(items)
        % Construct the full path
        fullPath = fullfile(folderPath, items(i).name);
        % Check if it is a file or a folder
        if items(i).isdir
            % If it is a folder, and not '.' or '..', recursively call
            if ~isequal(items(i).name, '.') && ~isequal(items(i).name, '..')
                subVarCell = recursive_extract_Var(fullPath, regexPattern,VarName);
                % Merge the Var variables from the subfolder into the main cell array
                VarCell = [VarCell;subVarCell];
            end
        else
            % If it is a file, check if the file name matches the regular expression
            if regexp(items(i).name, regexPattern)
                % Check if the file contains the Var variable
                variables = load(fullPath);
                variableNames = fieldnames(variables);
                if ismember(VarName, variableNames)
                    % If it contains the Var variable, load the variable
                    VarCell{end+1} = variables.(VarName);
                    % Display the name of the extracted file
                    disp(['Extracted variable ', VarName, ' from file: ' items(i).name]);
                else
                    disp(['File: ' items(i).name ' does not contain the ', VarName, ' variable']);
                end
            end
        end
    end
end