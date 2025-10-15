% filepath: @tf_zzy/display.m
function display(sys, varargin)
% DISPLAY  tf_zzy 对象的自定义显示方法

    % --- 1. 判断显示模式 ---
    show_details_mode = nargin > 1 && ischar(varargin{1}) && strcmp(varargin{1}, 'details');

    if show_details_mode
        % --- 模式 A: 显示完整的详细属性列表 ---
        fprintf('  tf_zzy object: %d outputs, %d inputs\n\n', 1, 1);
        fprintf('           Numerator: { %dx1 cell }\n', 1);
        fprintf('         Denominator: { %dx1 cell }\n', 1);
        fprintf('\n');
        
        % 正确显示采样时间
        if sys.Ts == 0
            fprintf('              Ts: []\n');
        else
            fprintf('              Ts: %g\n', sys.Ts);
        end
        
        fprintf('        Variable: ''%s''\n', sys.Variable);
        fprintf('        TimeUnit: ''%s''\n', sys.TimeUnit);
        fprintf('\n');
        fprintf('其他属性: InputDelay, OutputDelay, InputName, OutputName, ...\n');
        fprintf('\n');
        
    else
        % --- 模式 B: 默认显示 ---
        var_name = inputname(1);
        if isempty(var_name), var_name = 'ans'; end
        fprintf('\n%s =\n', var_name);
        fprintf('\n');

        % 获取并处理分子和分母系数
        num_coeffs = local_extract_coeffs(sys.num);
        den_coeffs = local_extract_coeffs(sys.den);
        
        % 去除前导零但保持原始系数
        num_coeffs = local_remove_leading_zeros(num_coeffs);
        den_coeffs = local_remove_leading_zeros(den_coeffs);
        
        % 格式化并打印传递函数
        local_print_tf(num_coeffs, den_coeffs, sys.Ts, sys.Variable);
        
        % 打印采样时间和系统类型
        if sys.Ts == 0
            fprintf('\n连续时间传递函数 (tf_zzy)。\n');
        else
            fprintf('\n采样时间: %g seconds\n', sys.Ts);
            fprintf('离散时间传递函数 (tf_zzy)。\n');
        end
        
        % 模型属性链接
        details_command = sprintf('display(%s, ''details'')', var_name);
        details_link = sprintf('<a href="matlab:%s">模型属性</a>', details_command);
        fprintf('%s\n\n', details_link);
    end
end

% =========================================================================
%                        文件内的本地辅助函数 (保持不变)
% =========================================================================
function coeffs = local_extract_coeffs(data)
    if isnumeric(data)
        coeffs = data;
    elseif iscell(data)
        if ~isempty(data) && isnumeric(data{1})
            coeffs = data{1};
        else
            coeffs = 1;
        end
    else
        coeffs = 1;
    end
    
    if iscolumn(coeffs)
        coeffs = coeffs';
    end
end

function coeffs_clean = local_remove_leading_zeros(coeffs)
    if isempty(coeffs) || ~isnumeric(coeffs)
        coeffs_clean = 1;
        return;
    end
    
    first_nonzero = find(abs(coeffs) > 1e-12, 1, 'first');
    
    if isempty(first_nonzero)
        coeffs_clean = 0;
    else
        coeffs_clean = coeffs(first_nonzero:end);
    end
end

function local_print_tf(num, den, Ts, Variable)
    var_name = Variable;
    
    num_str = local_format_polynomial(num, var_name);
    den_str = local_format_polynomial(den, var_name);
    
    num_len = length(num_str);
    den_len = length(den_str);
    max_len = max(num_len, den_len);
    
    separator = repmat('-', 1, max_len);
    
    num_padding = repmat(' ', 1, floor((max_len - num_len) / 2));
    den_padding = repmat(' ', 1, floor((max_len - den_len) / 2));
    
    fprintf('  %s%s\n', num_padding, num_str);
    fprintf('  %s\n', separator);
    fprintf('  %s%s\n', den_padding, den_str);
end

function poly_str = local_format_polynomial(coeffs, var_name)
    if length(coeffs) == 1
        if coeffs == 0
            poly_str = '0';
        else
            poly_str = local_format_coefficient(coeffs);
        end
        return;
    end
    
    poly_str = '';
    degree = length(coeffs) - 1;
    
    for i = 1:length(coeffs)
        coeff = coeffs(i);
        current_degree = degree - (i - 1);
        
        if abs(coeff) < 1e-12
            continue;
        end
        
        if i == 1
            if coeff < 0
                poly_str = [poly_str, '-'];
                coeff = -coeff;
            end
        else
            if coeff > 0
                poly_str = [poly_str, ' + '];
            else
                poly_str = [poly_str, ' - '];
                coeff = -coeff;
            end
        end
        
        if current_degree == 0
            poly_str = [poly_str, local_format_coefficient(coeff)];
        elseif current_degree == 1
            if coeff == 1
                poly_str = [poly_str, var_name];
            else
                poly_str = [poly_str, local_format_coefficient(coeff), ' ', var_name];
            end
        else
            if coeff == 1
                poly_str = [poly_str, var_name, '^', num2str(current_degree)];
            else
                poly_str = [poly_str, local_format_coefficient(coeff), ' ', var_name, '^', num2str(current_degree)];
            end
        end
    end
    
    if isempty(poly_str)
        poly_str = '0';
    end
end

function coeff_str = local_format_coefficient(coeff)
    if coeff == floor(coeff)
        coeff_str = num2str(coeff);
    else
        coeff_str = num2str(coeff, '%.4g');
    end
end