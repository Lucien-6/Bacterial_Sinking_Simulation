function VarCell = Extract_Var_from_Files(regexPattern,VarName)
    % extract_Var_from_mat_files
    % 该函数从用户指定的文件夹及其子文件夹中加载符合特定命名形式的.mat文件，
    % 并提取每个文件中命名为VarName的变量。
    % 用户将通过文件选择对话框选择文件夹。
    % 文件命名形式为regexPattern, 例如"data_XXXX.mat"，其中XXXX为数字。
    % 相应的正则化表达式为regexPattern = 'data_\d{4}\.mat'。

    % 打开文件选择对话框，让用户选择文件夹
    folderPath = uigetdir('', '选择包含所需.mat文件的文件夹');
    
    % 检查用户是否取消了选择
    if isequal(folderPath, 0)
        disp('未选择文件夹，程序退出。');
        return;
    end
    
    % 调用递归函数遍历文件夹和子文件夹
    VarCell = recursive_extract_Var(folderPath, regexPattern,VarName);
    
    % 检查是否提取了Var变量
    if ~isempty(VarCell)
        disp(['所有符合条件的文件中的',VarName,'变量已提取!']);
    else
        disp(['没有找到符合命名形式的文件或文件中不包含',VarName,'变量!']);
    end
    
end

function VarCell = recursive_extract_Var(folderPath, regexPattern,VarName)
    % recursive_extract_Var
    % 递归函数，用于遍历文件夹和子文件夹，加载符合命名形式的.mat文件，
    % 并提取每个文件中命名为"VarName"的变量。
    
    % 初始化输出细胞数组
    VarCell = {};
    
    % 获取指定文件夹下的所有文件和文件夹
    items = dir(folderPath);
    
    % 遍历所有项
    for i = 1:length(items)
        % 构建完整的路径
        fullPath = fullfile(folderPath, items(i).name);
        
        % 检查是文件还是文件夹
        if items(i).isdir
            % 如果是文件夹，且不是'.'或'..'，递归调用
            if ~isequal(items(i).name, '.') && ~isequal(items(i).name, '..')
                subVarCell = recursive_extract_Var(fullPath, regexPattern,VarName);
                % 将子文件夹中的Var变量合并到主细胞数组
                VarCell = [VarCell;subVarCell];
            end
        else
            % 如果是文件，检查文件名是否符合正则表达式
            if regexp(items(i).name, regexPattern)
                % 检查文件是否包含Var变量
                variables = load(fullPath);
                variableNames = fieldnames(variables);
                if ismember(VarName, variableNames)
                    % 如果包含Var变量，加载该变量
                    VarCell{end+1} = variables.(VarName);
                    
                    % 显示提取的文件名
                    disp(['提取文件：' items(i).name '中的',VarName,'变量']);
                else
                    disp(['文件：' items(i).name '不包含',VarName,'变量']);
                end
            end
        end
    end
end
