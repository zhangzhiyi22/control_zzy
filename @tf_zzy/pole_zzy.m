% filepath: @tf/pole_zzy.m
function p = pole_zzy(sys)
% POLE_ZZY  计算 tf_zzy 对象的极点 (不使用内置的 roots 函数)。
%
%   P = POLE_ZZY(SYS) 返回传递函数对象 SYS 的极点。
%   此函数通过构建伴随矩阵并计算其特征值的方式来求根。

    % --- 1. 输入验证 ---
    % 确保输入是 tf 类的对象
    if ~isa(sys, 'tf_zzy')
        error('POLE_ZZY 函数的输入必须是 tf_zzy 对象。');
    end

    % --- 2. 获取分母多项式 ---
    % 从 tf 对象的属性中获取分母系数向量。
    denominator_polynomial = sys.den{1};

    % --- 3. 计算极点 ---
    % 极点即为分母多项式的根。
    % 我们调用自己实现的、基于伴随矩阵的求根函数。
    p = local_roots_companion(denominator_polynomial);

end


% =========================================================================
%                        文件内的本地辅助函数
% =========================================================================
function r = local_roots_companion(poly_coeffs)
% LOCAL_ROOTS_COMPANION  使用伴随矩阵方法计算多项式 poly_coeffs 的根。
%   poly_coeffs: 一个包含多项式系数的行向量，按降幂排列。

    % --- 1. 数据预处理 ---
    
    % 去除前导零
    first_nonzero_idx = find(poly_coeffs ~= 0, 1, 'first');
    if isempty(first_nonzero_idx)
        r = []; % 零多项式没有根
        return;
    end
    poly_coeffs = poly_coeffs(first_nonzero_idx:end);
    
    n = length(poly_coeffs);
    
    % 如果多项式只有一个常数项 (n=1)，则没有根
    if n <= 1
        r = [];
        return;
    end

    % --- 2. 构建伴随矩阵 (Companion Matrix) ---
    
    % 归一化多项式，使其首项系数为 1
    p_norm = poly_coeffs / poly_coeffs(1);
    degree = n - 1;
    
    % 创建伴随矩阵
    C = zeros(degree, degree);
    
    % 设置第一行
    C(1, :) = -p_norm(2:end);
    
    % 设置次对角线为 1
    if degree > 1
        C(2:end, 1:end-1) = eye(degree - 1);
    end

    % --- 3. 计算特征值 ---
    % 伴随矩阵的特征值就是原多多项式的根。
      r = eig(C);

end