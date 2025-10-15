% filepath: @ss_zzy/display.m
function display(sys, varargin)
% DISPLAY  ss_zzy 对象的自定义显示方法

    show_details_mode = nargin > 1 && ischar(varargin{1}) && strcmp(varargin{1}, 'details');

    if show_details_mode
        % 详细显示模式
        num_states = size(sys.A, 1);
        num_inputs = size(sys.B, 2);
        num_outputs = size(sys.C, 1);
        
        fprintf('           A: [ %dx%d double ]\n', num_states, num_states);
        fprintf('           B: [ %dx%d double ]\n', num_states, num_inputs);
        fprintf('           C: [ %dx%d double ]\n', num_outputs, num_states);
        fprintf('           D: [ %dx%d double ]\n', num_outputs, num_inputs);
        fprintf('           E: []\n');
        fprintf('\n');
        fprintf('    StateName: { %dx1 cell }\n', num_states);
        fprintf('    InputName: { %dx1 cell }\n', num_inputs);
        fprintf('   OutputName: { %dx1 cell }\n', num_outputs);
        fprintf('\n');
        fprintf('   InternalDelay: [ %dx1 double ]\n', num_states);
        fprintf('      InputDelay: [ %dx1 double ]\n', num_inputs);
        fprintf('     OutputDelay: [ %dx1 double ]\n', num_outputs);
        fprintf('\n');
        fprintf('              Ts: %g\n', sys.Ts);
        fprintf('        TimeUnit: ''%s''\n', sys.TimeUnit);
        fprintf('\n');
        
    else
        % 默认显示模式
        var_name = inputname(1);
        if isempty(var_name), var_name = 'ans'; end
        fprintf('\n%s =\n', var_name);

        fprintf('\n  A =\n');
        local_print_matrix(sys.A, 'x', 'x');

        fprintf('\n  B =\n');
        local_print_matrix(sys.B, 'x', 'u');

        fprintf('\n  C =\n');
        local_print_matrix(sys.C, 'y', 'x');

        fprintf('\n  D =\n');
        local_print_matrix(sys.D, 'y', 'u');

        if sys.Ts == 0
            fprintf('\n连续时间状态空间模型 (ss_zzy)。\n');
        else
            fprintf('\n离散时间状态空间模型 (ss_zzy, Ts = %g)。\n', sys.Ts);
        end
        
        details_command = sprintf('display(%s, ''details'')', var_name);
        details_link = sprintf('<a href="matlab:%s">模型属性</a>', details_command);
        fprintf('%s\n\n', details_link);
    end
end

function local_print_matrix(M, row_prefix, col_prefix)
    if isempty(M) || all(size(M) == 0)
        fprintf('     []\n');
        return;
    end

    [rows, cols] = size(M);
    
    % 打印列标签
    col_labels = '';
    for j = 1:cols
        col_labels = [col_labels, sprintf('%8s%d', col_prefix, j)];
    end
    fprintf('       %s\n', col_labels);

    % 打印每一行
    for i = 1:rows
        fprintf('    %s%d ', row_prefix, i);
        for j = 1:cols
            fprintf('%10.4g', M(i, j));
        end
        fprintf('\n');
    end
end