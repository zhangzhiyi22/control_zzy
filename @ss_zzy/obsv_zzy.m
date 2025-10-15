% filepath: @ss_zzy/obsv_zzy.m
function Ob = obsv_zzy(sys)
% OBSV_ZZY  计算 ss_zzy 对象的可观测性矩阵
%
%   Ob = OBSV_ZZY(SYS) 返回状态空间对象 SYS 的可观测性矩阵
%   此函数计算 Ob = [C; CA; CA^2; ...; CA^(n-1)]

    % --- 1. 输入验证 ---
    % 确保输入是 ss_zzy 类的对象
    if ~isa(sys, 'ss_zzy')
        error('OBSV_ZZY 函数的输入必须是 ss_zzy 对象。');
    end

    % --- 2. 获取 A 和 C 矩阵 ---
    % 从 ss_zzy 对象的属性中获取状态矩阵 A 和输出矩阵 C
    A_matrix = sys.A;
    C_matrix = sys.C;

    % --- 3. 计算可观测性矩阵 ---
    % 可观测性矩阵定义为 Ob = [C; CA; CA^2; ...; CA^(n-1)]
    % 其中 n 是系统的状态维数
    
    n = size(A_matrix, 1);  % 状态维数
    p = size(C_matrix, 1);  % 输出维数
    
    % 初始化可观测性矩阵
    Ob = zeros(n*p, n);
    
    % 第一行块：C
    Ob(1:p, :) = C_matrix;
    
    % 计算 C * A^k，k = 1, 2, ..., n-1
    CA_power = C_matrix;  % CA^0 = C
    for k = 1:(n-1)
        % CA^k = (CA^(k-1)) * A
        CA_power = CA_power * A_matrix;
        
        % 填充到可观测性矩阵
        start_row = k*p + 1;
        end_row = (k+1)*p;
        Ob(start_row:end_row, :) = CA_power;
    end
end