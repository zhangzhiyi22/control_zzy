% filepath: ss2tf_zzy.m
function [num, den] = ss2tf_zzy(A, B, C, D, ni)
% SS2TF_ZZY  将状态空间表示转换为传递函数表示
%
%   [NUM, DEN] = SS2TF_ZZY(A, B, C, D) 将单输入单输出(SISO)系统的
%   状态空间表示转换为等效的传递函数 H(s) = NUM(s)/DEN(s)
%
%   [NUM, DEN] = SS2TF_ZZY(A, B, C, D, NI) 计算多输入(MIMO)系统中，
%   从第 NI 个输入到所有输出的传递函数。NUM 将是一个矩阵，
%   其中第 i 行是从输入 NI 到输出 i 的传递函数分子
%
%   此函数严格遵循 ss2tfFun.c 中实现的 Faddeev-LeVerrier 算法

    % --- 1. 参数验证 ---
    if nargin < 4
        error('ss2tf_zzy: 至少需要 A, B, C, D 四个参数');
    end
    
    [n, n_check] = size(A);
    if n ~= n_check
        error('ss2tf_zzy: A 矩阵必须是方阵');
    end
    
    num_inputs = size(B, 2);
    num_outputs = size(C, 1);
    
    % 处理输入参数 ni
    if nargin < 5
        if num_inputs > 1
            error('ss2tf_zzy: 对于多输入系统，必须提供输入索引 ni');
        end
        ni = 1; % 默认为第一个输入
    end
    
    if ni > num_inputs
        error('ss2tf_zzy: 输入索引 ni 超出 B 矩阵的列数');
    end
    
    % 提取特定输入的 B 和 D 矩阵列
    b_vec = B(:, ni);
    d_vec = D(:, ni);

    % --- 2. 计算特征多项式 (分母) ---
    % 对应 C 代码步骤 1: computeCharPolyWithPoly
    den = poly(A);

    % --- 3. 计算伴随矩阵的系数 (Faddeev-LeVerrier 算法) ---
    % 对应 C 代码步骤 2: computeAdjCoeffs
    B_matrices = cell(1, n);
    
    % C 代码: gsl_matrix_set_identity((*adj_coeffs)[0])
    B_matrices{1} = eye(n);
    
    % C 代码: for (size_t k = 1; k < n; k++)
    for k = 1:n-1
        % C 代码: gsl_blas_dgemm(..., A, (*adj_coeffs)[k-1], ...)
        temp_prod = A * B_matrices{k};
        
        % C 代码: trace_val = trace(...) / k
        trace_val = trace(temp_prod) / k;
        
        % C 代码: ... - trace_val * I
        B_matrices{k+1} = temp_prod - trace_val * eye(n);
    end

    % --- 4. 计算分子多项式 ---
    % 对应 C 代码步骤 4: 计算 C * B_k * B 项
    num = zeros(num_outputs, n + 1);
    
    for p = 1:num_outputs
        c_row = C(p, :);
        d_val = d_vec(p);
        
        % 步骤 4: 计算 C * B_k * B 项
        % C 代码: for (size_t k = 0; k < n; k++)
        num_p = zeros(1, n);
        for k = 0:n-1
            % C 代码: size_t matrix_idx = n - 1 - k
            % 对应 MATLAB: B_matrices{n-k}
            matrix_idx = n - k;
            
            % C 代码中的三重循环在 MATLAB 中是高效的矩阵乘法
            coeff = c_row * B_matrices{matrix_idx} * b_vec;
            
            % C 代码: gsl_matrix_set(num, 0, k, coeff)
            num_p(k+1) = coeff;
        end
        
        % 步骤 5: 翻转分子系数 (对应 C 代码步骤 5)
        % C 代码: for (size_t i = 0; i < (n + 1) / 2; i++)
        num_p = fliplr(num_p);
        
        % 将结果放入长度为 n+1 的向量中，以便与 den 对齐
        num_p_padded = [zeros(1, (n + 1) - length(num_p)), num_p];
        
        % 步骤 6: 加上 D * den 项 (对应 C 代码步骤 6)
        % C 代码: current_coeff + d_val * den_coeff
        num(p, :) = num_p_padded + d_val * den;
    end

    % 注意：我们永远保留前导零，不执行 C 代码的步骤 7 (去除前导零)
    % 这样确保输出格式与 MATLAB 内置 ss2tf 一致
end