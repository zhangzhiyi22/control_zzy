% filepath: @ss/zero_zzy.m
function [Z, gain] = zero_zzy(sys)
% ZERO_ZZY  计算状态空间系统的零点和增益
%
%   Z = ZERO_ZZY(SYS) 返回状态空间系统 SYS 的传递函数零点。
%   对于 SISO 系统，Z 是一个列向量，包含所有有限零点。
%
%   [Z, GAIN] = ZERO_ZZY(SYS) 同时返回零点 Z 和系统增益 GAIN。
%   增益是传递函数分子多项式的首项系数。
%
%   此函数通过将状态空间表示转换为传递函数，然后计算分子多项式的根来实现。

    % --- 1. 输入验证 ---
    if ~isa(sys, 'ss_zzy')
        error('zero_zzy: 输入参数必须是 ss_zzy 对象');
    end
    
    % 检查是否为 SISO 系统
    [num_outputs, num_inputs] = size(sys.D);
    if num_inputs ~= 1 || num_outputs ~= 1
        error('zero_zzy: 当前仅支持 SISO (单输入单输出) 系统');
    end

    % --- 2. 将状态空间转换为传递函数 ---
    try
        [num, den] = ss2tf_zzy(sys);
    catch ME
        error('zero_zzy: 状态空间到传递函数转换失败: %s', ME.message);
    end
    
    % --- 3. 处理分子多项式系数 ---
    % 确保 num 是数值向量
    if iscell(num)
        if ~isempty(num) && isnumeric(num{1})
            num_coeffs = num{1};
        else
            num_coeffs = 0;
        end
    elseif isnumeric(num)
        num_coeffs = num;
    else
        num_coeffs = 0;
    end
    
    % 确保是行向量
    if iscolumn(num_coeffs)
        num_coeffs = num_coeffs';
    end
    
    % --- 4. 去除前导零并计算增益 ---
    tol = 1e-12;
    first_nonzero_idx = find(abs(num_coeffs) > tol, 1, 'first');
    
    if isempty(first_nonzero_idx)
        % 分子为零，无零点
        Z = [];
        gain = 0;
        return;
    end
    
    % 去除前导零
    num_clean = num_coeffs(first_nonzero_idx:end);
    
    % 计算增益（分子多项式的首项系数）
    gain = num_clean(1);
    
    % --- 5. 计算零点 ---
    if length(num_clean) == 1
        % 分子是常数，无零点
        Z = [];
    else
        % 计算分子多项式的根
        Z = roots(num_clean);
        
        % 确保输出为列向量
        if isrow(Z)
            Z = Z';
        end
        
        % 移除数值上的无穷大零点（如果有的话）
        finite_idx = isfinite(Z);
        Z = Z(finite_idx);
        
        % 对零点进行排序（实数部分优先，虚数部分次之）
        if ~isempty(Z)
            if isreal(Z)
                Z = sort(Z);
            else
                % 复数排序：先按实部，再按虚部
                [~, sort_idx] = sortrows([real(Z), imag(Z)]);
                Z = Z(sort_idx);
            end
        end
    end
    
    % --- 6. 处理输出参数 ---
    if nargout <= 1
        % 只返回零点
        return;
    end
    
    % 如果请求增益但分子为零，设置增益为0
    if isempty(Z) && abs(gain) < tol
        gain = 0;
    end
end