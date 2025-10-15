% filepath: @tf/zero_zzy.m
function [z, gain] = zero_zzy(sys)
% ZERO_ZZY  计算 tf_zzy 对象的零点和零极点增益 (不使用内置的 roots 函数)。
%
%   Z = ZERO_ZZY(SYS) 返回传递函数对象 SYS 的传输零点。
%
%   [Z, GAIN] = ZERO_ZZY(SYS) 同时返回零点 Z 和零极点增益 GAIN。
%
%   此函数通过构建伴随矩阵并计算其特征值的方式来求根。

    % --- 1. 输入验证 ---
    if ~isa(sys, 'tf_zzy')
        error('ZERO_ZZY 函数的输入必须是 tf_zzy 对象。');
    end

    % --- 2. 获取分子多项式 ---
    numerator_polynomial = sys.num{1};

    % --- 3. 计算零点 Z ---
    % 零点即为分子多项式的根。
    % 调用我们自己实现的、基于伴随矩阵的求根函数。
    z = local_roots_companion(numerator_polynomial);

    % --- 4. 计算增益 GAIN (如果用户请求了第二个输出) ---
    if nargout > 1
        % 增益 K 是分子多项式的首项非零系数。
        % (因为在构造函数中，分母的首项系数已被归一化为 1)
        
        % 找到第一个非零的系数
        first_nonzero_idx = find(numerator_polynomial ~= 0, 1, 'first');
        
        if isempty(first_nonzero_idx)
            % 如果分子是 0，则增益为 0
            gain = 0;
        else
            % 否则，增益就是这个首项非零系数
            gain = numerator_polynomial(first_nonzero_idx);
        end
    end

end


% =========================================================================
%                        文件内的本地辅助函数
% =========================================================================
function r = local_roots_companion(poly_coeffs)
% LOCAL_ROOTS_COMPANION  使用伴随矩阵方法计算多项式 poly_coeffs 的根。
%   poly_coeffs: 一个包含多项式系数的行向量，按降幂排列。

    % --- 1. 数据预处理 ---
    first_nonzero_idx = find(poly_coeffs ~= 0, 1, 'first');
    if isempty(first_nonzero_idx), r = []; return; end
    poly_coeffs = poly_coeffs(first_nonzero_idx:end);
    
    n = length(poly_coeffs);
    if n <= 1, r = []; return; end

    % --- 2. 构建伴随矩阵 ---
    p_norm = poly_coeffs / poly_coeffs(1);
    degree = n - 1;
    C = zeros(degree, degree);
    C(1, :) = -p_norm(2:end);
    if degree > 1, C(2:end, 1:end-1) = eye(degree - 1); end

    % --- 3. 计算特征值 ---
    r = eig(C);
end