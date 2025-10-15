% filepath: @ss_zzy/ctrb_zzy.m
function Co = ctrb_zzy(sys)
% CTRB_ZZY  计算 ss_zzy 对象的可控性矩阵
%
%   Co = CTRB_ZZY(SYS) 返回状态空间对象 SYS 的可控性矩阵
%   此函数计算 Co = [B AB A^2*B ... A^(n-1)*B]

    % --- 1. 输入验证 ---
    % 确保输入是 ss_zzy 类的对象
    if ~isa(sys, 'ss_zzy')
        error('CTRB_ZZY 函数的输入必须是 ss_zzy 对象。');
    end

    % --- 2. 获取 A 和 B 矩阵 ---
    % 从 ss_zzy 对象的属性中获取状态矩阵 A 和输入矩阵 B
    A_matrix = sys.A;
    B_matrix = sys.B;

    % --- 3. 计算可控性矩阵 ---
    % 可控性矩阵定义为 Co = [B AB A^2*B ... A^(n-1)*B]
    % 其中 n 是系统的状态维数
    
    n = size(A_matrix, 1);  % 状态维数
    m = size(B_matrix, 2);  % 输入维数
    
    % 初始化可控性矩阵
    Co = zeros(n, n*m);
    
    % 第一列块：B
    Co(:, 1:m) = B_matrix;
    
    % 计算 A^k * B，k = 1, 2, ..., n-1
    A_power = A_matrix;  % A^1
    for k = 1:(n-1)
        % A^k * B
        A_k_B = A_power * B_matrix;
        
        % 填充到可控性矩阵
        start_col = k*m + 1;
        end_col = (k+1)*m;
        Co(:, start_col:end_col) = A_k_B;
        
        % 更新A的幂：A^(k+1) = A^k * A
        if k < n-1
            A_power = A_power * A_matrix;
        end
    end
end