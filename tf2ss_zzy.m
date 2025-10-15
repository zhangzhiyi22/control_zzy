% filepath: tf2ss_zzy.m
function [A, B, C, D] = tf2ss_zzy(num, den)
%TF2SS_ZZY 将传递函数转换为状态空间表示（可控标准型）
%
%   [A,B,C,D] = tf2ss_zzy(num, den) 
%       num: 分子多项式系数（降幂排列，行或列向量）
%       den: 分母多项式系数（降幂排列，行或列向量）
%
%   返回可控标准型状态空间实现

    % 参数检查
    if nargin ~= 2
        error('错误！tf2ss_zzy 需要 2 个参数，实际得到 %d 个', nargin);
    end
    
    % 检查参数类型 - 必须是向量
    if ~isnumeric(num) || ~isvector(num)
        error('错误！num 必须是数值向量');
    end
    if ~isnumeric(den) || ~isvector(den)
        error('错误！den 必须是数值向量');
    end
    
    % 转换为列向量
    num = num(:);
    den = den(:);
    
    % 检查向量长度
    if isempty(num) || isempty(den)
        error('错误！分子和分母向量不能为空');
    end
    
    % 去除分母前导零
    den_start = find(abs(den) >= 1e-12, 1, 'first');
    if isempty(den_start)
        error('错误！分母是零多项式');
    end
    den = den(den_start:end);
    
    % 检查分母首项
    leading_coeff = den(1);
    if abs(leading_coeff) < 1e-12
        error('错误！分母首项系数为零: %g', leading_coeff);
    end
    
    % 去除分子前导零
    num_start = find(abs(num) >= 1e-12, 1, 'first');
    if isempty(num_start)
        num = 0;  % 分子全为零
    else
        num = num(num_start:end);
    end
    
    % 归一化（使分母首项为1）
    num = num / leading_coeff;
    den = den / leading_coeff;
    
    % 系统阶次
    n = length(den) - 1;
    
    % 处理零阶系统（纯增益）
    if n == 0
        A = [];
        B = [];
        C = [];
        D = num(1);
        return;
    end
    
    % 分配状态空间矩阵
    A = zeros(n, n);
    B = zeros(n, 1);
    C = zeros(1, n);
    D = 0;
    
    % 1. 设置 A 矩阵 - 可控标准型
    % 上对角线填1
    for i = 1:n-1
        A(i, i+1) = 1.0;
    end
    
    % 最后一行填分母系数的相反数（去掉首项）
    A(n, :) = -den(2:end)';
    
    % 2. 设置 B 矩阵 = [0; 0; ...; 1]
    B(n) = 1.0;
    
    % 3. 判断是否为真分式
    is_proper = (length(num) <= n);
    
    if is_proper
        % 真分式，D = 0
        D = 0;
        
        % C 矩阵由分子系数设置（右对齐）
        for i = 1:n
            num_idx = length(num) - (n - i);
            if num_idx >= 1 && num_idx <= length(num)
                C(i) = num(num_idx);
            else
                C(i) = 0;
            end
        end
    else
        % 非真分式
        D = num(1);
        
        % C 矩阵需要减去 D*分母对应项
        for i = 1:n
            num_idx = length(num) - n + i;
            if num_idx >= 1 && num_idx <= length(num)
                num_coeff = num(num_idx);
            else
                num_coeff = 0;
            end
            
            den_coeff = den(i+1);
            C(i) = num_coeff - D * den_coeff;
        end
    end
end