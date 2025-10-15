% filepath: feedback_zzy.m
function sys = feedback_zzy(sys1, sys2, sign)
%FEEDBACK_ZZY 计算两个系统的反馈连接
%
%   SYS = FEEDBACK_ZZY(SYS1, SYS2) 计算负反馈系统
%   其中 SYS1 是前向通道, SYS2 是反馈通道
%   结果为: SYS = SYS1 / (1 + SYS1*SYS2)
%
%   SYS = FEEDBACK_ZZY(SYS1, SYS2, SIGN) 指定反馈类型
%   SIGN = +1 或省略: 负反馈 (默认)
%   SIGN = -1: 正反馈
%
%   负反馈: SYS = SYS1 / (1 + SYS1*SYS2)
%   正反馈: SYS = SYS1 / (1 - SYS1*SYS2)
%
%   完全对应 C 代码 feedbackFun.c 的算法
%
%   示例:
%       % 负反馈
%       G = tf_zzy([1], [1 1]);
%       H = tf_zzy([1], [1]);
%       T = feedback_zzy(G, H);
%
%       % 正反馈
%       T = feedback_zzy(G, H, -1);

    % --- 1. 参数验证 ---
    if nargin < 2 || nargin > 3
        error('FEEDBACK_ZZY: 需要2或3个输入参数');
    end
    
    % 检查输入类型
    if ~isa(sys1, 'tf_zzy') || ~isa(sys2, 'tf_zzy')
        error('FEEDBACK_ZZY: 两个输入都必须是 tf_zzy 对象');
    end
    
    % 检查采样时间是否一致
    Ts1 = get(sys1, 'Ts');
    Ts2 = get(sys2, 'Ts');
    
    if Ts1 ~= Ts2
        error('FEEDBACK_ZZY: 两个系统的采样时间必须一致');
    end
    
    % 确定反馈类型 (默认为负反馈)
    if nargin < 3
        sign = 1;  % 负反馈
    end
    
    isNegativeFeedback = (sign >= 0);  % sign=1或正数为负反馈, sign=-1为正反馈
    
    % --- 2. 获取分子和分母多项式 ---
    num1 = sys1.num{1};
    den1 = sys1.den{1};
    num2 = sys2.num{1};
    den2 = sys2.den{1};
    
    % 确保是行向量
    num1 = num1(:)';
    den1 = den1(:)';
    num2 = num2(:)';
    den2 = den2(:)';
    
    % --- 3. 计算反馈系统 ---
    % 反馈公式: G / (1 ± G*H)
    
    try
        % 步骤1: 计算 G*H (对应 C: multiplyTF)
        GH_num = polyConv_local(num1, num2);
        GH_den = polyConv_local(den1, den2);
        
        % 步骤2: 计算 1 ± G*H 的分子
        % 负反馈: 1 + G*H, 分子 = GH_den + GH_num
        % 正反馈: 1 - G*H, 分子 = GH_den - GH_num
        
        % 对齐分子和分母
        maxLen = max(length(GH_num), length(GH_den));
        
        % 零填充到相同长度
        if length(GH_num) < maxLen
            GH_num = [zeros(1, maxLen - length(GH_num)), GH_num];
        end
        if length(GH_den) < maxLen
            GH_den = [zeros(1, maxLen - length(GH_den)), GH_den];
        end
        
        % 计算分母: 1 ± G*H
        if isNegativeFeedback
            % 负反馈: den_denom = GH_den + GH_num
            den_denom = GH_den + GH_num;
        else
            % 正反馈: den_denom = GH_den - GH_num
            den_denom = GH_den - GH_num;
        end
        
        % 步骤3: 计算最终结果 G / (1 ± G*H)
        % num_result = num1 * den_denom
        % den_result = den1 * GH_den (因为 (1±G*H) 的分母是 GH_den)
        
        % 但实际上应该是:
        % num_result = num1 * GH_den (G 的分子 × (1±G*H)的分母)
        % den_result = den1 * den_denom (G 的分母 × (1±G*H)的分子)
        
        num_result = polyConv_local(num1, GH_den);
        den_result = polyConv_local(den1, den_denom);
        
        % 去除前导零
        num_result = remove_leading_zeros(num_result);
        den_result = remove_leading_zeros(den_result);
        
        % --- 4. 化简传递函数 ---
        % 计算最大公约式并约简
        gcd_poly = compute_poly_gcd(num_result, den_result);
        gcdDegree = length(gcd_poly) - 1;
        
        if gcdDegree > 0
            num_gcd = poly_exact_div(num_result, gcd_poly);
            den_gcd = poly_exact_div(den_result, gcd_poly);
            
            if ~isempty(num_gcd) && ~isempty(den_gcd)
                num_result = num_gcd;
                den_result = den_gcd;
            end
        end
        
        % 再次去除前导零
        num_result = remove_leading_zeros(num_result);
        den_result = remove_leading_zeros(den_result);
        
        % --- 5. 创建结果传递函数 ---
        sys = tf_zzy(num_result, den_result, Ts1);
        
    catch ME
        error('FEEDBACK_ZZY: 计算反馈连接失败: %s', ME.message);
    end
end

%% ========== 辅助函数 ==========

function result = polyConv_local(p1, p2)
%POLYCONV_LOCAL 多项式卷积
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
%COMPUTE_POLY_GCD 计算多项式最大公约式
    p1 = remove_leading_zeros(p1);
    p2 = remove_leading_zeros(p2);
    
    if length(p1) < length(p2)
        temp = p1;
        p1 = p2;
        p2 = temp;
    end
    
    while length(p2) > 1 || abs(p2(1)) > eps
        [~, r] = poly_div_internal(p1, p2);
        p1 = p2;
        p2 = remove_leading_zeros(r);
        
        if isscalar(p2) && abs(p2) < eps
            break;
        end
    end
    
    gcd_poly = p1;
    
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
%POLY_EXACT_DIV 多项式精确除法
    [q, r] = poly_div_internal(dividend, divisor);
    
    if all(abs(r) < 1e-10)
        result = q;
    else
        result = dividend;
    end
    
    result = remove_leading_zeros(result);
end