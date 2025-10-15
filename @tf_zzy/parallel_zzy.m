% filepath: @tf_zzy/parallel_zzy.m
function sys = parallel_zzy(sys1, sys2)
% PARALLEL_ZZY  计算两个 tf_zzy 传递函数的并联连接
%
%   SYS = PARALLEL_ZZY(SYS1, SYS2) 计算传递函数 SYS1 和 SYS2 的并联连接
%   完全对应 C 代码 parallerFun.c 的算法

    % --- 1. 输入验证 (对应 C 代码的参数检查) ---
    if nargin ~= 2
        error('PARALLEL_ZZY: 需要恰好2个输入参数');
    end
    
    % 检查输入类型 (对应 C 代码的 typeTransferFunctionValue 检查)
    if ~isa(sys1, 'tf_zzy') || ~isa(sys2, 'tf_zzy')
        error('PARALLEL_ZZY: 两个输入都必须是 tf_zzy 对象');
    end
    
    % 检查采样时间是否一致 (对应 C 代码的 tf1->Ts != tf2->Ts 检查)
    if sys1.Ts ~= sys2.Ts
        error('PARALLEL_ZZY: 两个传递函数的采样时间必须一致');
    end
    
    % --- 2. 获取分子和分母多项式 (对应 C 代码的 tf1->num, tf1->den 等) ---
    % 从元胞数组中提取数值向量
    num1 = sys1.num{1};  % 对应 C: tf1->num
    den1 = sys1.den{1};  % 对应 C: tf1->den
    num2 = sys2.num{1};  % 对应 C: tf2->num
    den2 = sys2.den{1};  % 对应 C: tf2->den
    
    % 确保是行向量
    num1 = num1(:)';
    den1 = den1(:)';
    num2 = num2(:)';
    den2 = den2(:)';
    
    % --- 3. 计算并联连接 (完全对应 C 代码算法) ---
    try
        % 计算公共分母：den1 * den2 (对应 C: polyConv(tf1->den, tf2->den))
        common_den = conv(den1, den2);
        
        % 计算新分子的两部分 (对应 C: polyConv 操作)
        num1_scaled = conv(num1, den2);  % num1 * den2 (对应 C: polyConv(tf1->num, tf2->den))
        num2_scaled = conv(num2, den1);  % num2 * den1 (对应 C: polyConv(tf2->num, tf1->den))
        
        % 确保两个分子具有相同长度（用于相加）
        max_len = max(length(num1_scaled), length(num2_scaled));
        
        % 零填充到相同长度
        if length(num1_scaled) < max_len
            num1_scaled = [zeros(1, max_len - length(num1_scaled)), num1_scaled];
        end
        if length(num2_scaled) < max_len
            num2_scaled = [zeros(1, max_len - length(num2_scaled)), num2_scaled];
        end
        
        % 分子相加 (对应 C: polyAdd(num1_scaled, num2_scaled))
        new_num = num1_scaled + num2_scaled;
        
        % 去除前导零
        new_num = remove_leading_zeros(new_num);
        common_den = remove_leading_zeros(common_den);
        
        % --- 4. 创建结果传递函数 ---
        % 对应 C 代码的:
        % result_tf->num = new_num;
        % result_tf->den = common_den;
        % result_tf->Ts = tf1->Ts;
        sys = tf_zzy(new_num, common_den, sys1.Ts);
        
    catch ME
        error('PARALLEL_ZZY: 计算并联连接失败: %s', ME.message);
    end
end

% 辅助函数：去除多项式前导零
function poly = remove_leading_zeros(poly)
    if ~isnumeric(poly)
        error('输入必须是数值向量');
    end
    
    poly = poly(:)';
    first_nonzero = find(abs(poly) > eps, 1, 'first');
    
    if isempty(first_nonzero)
        poly = 0;
    else
        poly = poly(first_nonzero:end);
    end
    
    if isempty(poly)
        poly = 0;
    end
end