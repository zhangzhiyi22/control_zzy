% filepath: series_zzy.m
function sys = series_zzy(sys1, sys2)
%SERIES_ZZY 计算两个 tf_zzy 传递函数的串联连接
%
%   SYS = SERIES_ZZY(SYS1, SYS2) 计算传递函数 SYS1 和 SYS2 的串联连接
%   完全对应 C 代码 seriesFun.c 的算法
%   串联连接：sys = sys2 * sys1

    % --- 1. 输入验证 (对应 C 代码的参数检查) ---
    if nargin ~= 2
        error('SERIES_ZZY: 需要恰好2个输入参数');
    end
    
    % 检查输入类型 (对应 C 代码的 typeTransferFunctionValue 检查)
    if ~isa(sys1, 'tf_zzy') || ~isa(sys2, 'tf_zzy')
        error('SERIES_ZZY: 两个输入都必须是 tf_zzy 对象');
    end
    
    % 检查采样时间是否一致 (对应 C 代码的 tf1->Ts != tf2->Ts 检查)
    if sys1.Ts ~= sys2.Ts
        error('SERIES_ZZY: 两个传递函数的采样时间必须一致');
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
    
    % --- 3. 计算串联连接 (完全对应 C 代码算法) ---
    % 串联就是相乘：G = G2 * G1
    % numResult = num2 * num1
    % denResult = den2 * den1
    
    try
        % 使用多项式卷积计算分子和分母 (对应 C: polyConv)
        numResult = polyConv_local(num2, num1);  % polyConv(tf1->num, tf2->num)
        denResult = polyConv_local(den2, den1);  % polyConv(tf1->den, tf2->den)
        
        % 去除前导零
        numResult = remove_leading_zeros(numResult);
        denResult = remove_leading_zeros(denResult);
        
        % --- 4. 化简传递函数 (对应 C 代码的 computePolyGCD) ---
        % 计算最大公约式
        gcd = compute_poly_gcd(numResult, denResult);
        
        % 如果 GCD 的次数大于0，则约简
        gcdDegree = length(gcd) - 1;
        if gcdDegree > 0
            numGCD = poly_exact_div(numResult, gcd);
            denGCD = poly_exact_div(denResult, gcd);
            
            if ~isempty(numGCD) && ~isempty(denGCD)
                numResult = numGCD;
                denResult = denGCD;
            end
        end
        
        % 再次去除前导零
        numResult = remove_leading_zeros(numResult);
        denResult = remove_leading_zeros(denResult);
        
        % --- 5. 创建结果传递函数 ---
        % 对应 C 代码的:
        % result_tf->num = numResult;
        % result_tf->den = denResult;
        % result_tf->Ts = tf1->Ts;
        sys = tf_zzy(numResult, denResult, sys1.Ts);
        
    catch ME
        error('SERIES_ZZY: 计算串联连接失败: %s', ME.message);
    end
end

%% ========== 辅助函数 ==========

function result = polyConv_local(p1, p2)
%POLYCONV_LOCAL 多项式卷积 (对应 C 代码的 polyConv)
    p1 = double(p1(:)');
    p2 = double(p2(:)');
    
    n1 = length(p1);
    n2 = length(p2);
    n_result = n1 + n2 - 1;
    result = zeros(1, n_result);
    
    for i = 1:n1
        for j = 1:n2
            result(i + j - 1) = result(i + j - 1) + p1(i) * p2(j);
        end
    end
end

function poly = remove_leading_zeros(poly)
%REMOVE_LEADING_ZEROS 去除多项式前导零
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

function gcd_poly = compute_poly_gcd(p1, p2)
%COMPUTE_POLY_GCD 计算两个多项式的最大公约式 (对应 C: computePolyGCD)
    p1 = remove_leading_zeros(p1);
    p2 = remove_leading_zeros(p2);
    
    % 确保 p1 的次数 >= p2 的次数
    if length(p1) < length(p2)
        temp = p1;
        p1 = p2;
        p2 = temp;
    end
    
    % 欧几里得算法
    while length(p2) > 1 || abs(p2(1)) > eps
        [~, r] = poly_div_internal(p1, p2);
        p1 = p2;
        p2 = remove_leading_zeros(r);
        
        if isscalar(p2) && abs(p2) < eps
            break;
        end
    end
    
    gcd_poly = p1;
    
    % 归一化
    if ~isempty(gcd_poly) && abs(gcd_poly(1)) > eps
        gcd_poly = gcd_poly / gcd_poly(1);
    end
end

function [q, r] = poly_div_internal(dividend, divisor)
%POLY_DIV_INTERNAL 多项式除法
    dividend = remove_leading_zeros(dividend);
    divisor = remove_leading_zeros(divisor);
    
    if all(abs(divisor) < eps)
        error('除数不能为零多项式');
    end
    
    r = dividend;
    q = [];
    
    while length(r) >= length(divisor) && any(abs(r) > eps)
        coeff = r(1) / divisor(1);
        q = [q, coeff];
        
        temp = [coeff * divisor, zeros(1, length(r) - length(divisor))];
        r = r - temp;
        r = r(2:end);
        
        if isempty(r)
            break;
        end
    end
    
    if isempty(q)
        q = 0;
    end
    if isempty(r)
        r = 0;
    end
    
    r = remove_leading_zeros(r);
end

function result = poly_exact_div(dividend, divisor)
%POLY_EXACT_DIV 多项式精确除法 (对应 C: polyExactDiv)
    [q, r] = poly_div_internal(dividend, divisor);
    
    % 检查余数是否接近零
    if all(abs(r) < 1e-10)
        result = q;
    else
        % 如果有余数，返回原多项式
        result = dividend;
    end
    
    result = remove_leading_zeros(result);
end