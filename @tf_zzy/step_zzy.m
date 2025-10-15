% filepath: @tf_zzy/step_zzy.m
function [y, tOut] = step_zzy(sys, t)
%STEP_ZZY 计算传递函数的单位阶跃响应
%
%   step_zzy(sys)           % 自动绘图
%   step_zzy(sys, t)        % 指定时间范围并绘图
%   [y, t] = step_zzy(...)  % 返回数据

    if ~isa(sys, 'tf_zzy')
        error('输入必须是 tf_zzy 对象');
    end
    
    if nargin == 1
        t_end = 10.0;
    else
        t_end = t;
    end
    
    % 提取分子分母并转换为列向量（从高次到低次）
    num = sys.num{1}(:);
    den = sys.den{1}(:);
    
    % 去除前导零
    num = removeLeadingZeros(num);
    den = removeLeadingZeros(den);
    
    % 归一化：使分母首项系数为1
    a0 = den(1);
    num = num / a0;
    den = den / a0;
    
    m = length(num) - 1;  % 分子阶数
    n = length(den) - 1;  % 分母阶数
    
    % 时间向量
    dt = 0.01;
    n_points = floor(t_end / dt) + 1;
    tOut = (0:n_points-1)' * dt;
    
    %% 特殊情况：零阶系统（纯增益）
    if n == 0
        K = num(1);
        y = K * ones(n_points, 1);
        if nargout == 0
            plot(tOut, y, 'LineWidth', 1.5);
            xlabel('时间 (s)'); ylabel('幅值'); 
            title('单位阶跃响应'); grid on;
        end
        return;
    end
    
    %% 使用部分分式展开计算阶跃响应
    % 阶跃响应 = L^{-1}{G(s)/s}
    
    % 构造新的传递函数：G(s)/s = num(s) / [s * den(s)]
    num_new = num;
    den_new = conv([1 0], den);  % s * den(s)
    
    % 部分分式展开
    [r, p, k] = residue(num_new, den_new);
    
    % 计算直接传递项 D（对应原系统的 D）
    if m >= n
        D = num(1) / den(1);  % 已经归一化，den(1)=1
    else
        D = 0;
    end
    
    % 初始化输出
    y = zeros(n_points, 1);
    u = 1.0;  % 单位阶跃输入
    
    % 计算每个时间点的响应
    for idx = 1:n_points
        t_curr = tOut(idx);
        
        if t_curr == 0
            % t=0 时刻，只有直接传递项 D 的影响
            y(idx) = D * u;
        else
            % 直接传递项（多项式部分）
            y_direct = 0;
            for i = 1:length(k)
                y_direct = y_direct + k(i) * t_curr^(length(k) - i);
            end
            
            % 极点贡献（指数项）
            y_poles = 0;
            for i = 1:length(r)
                y_poles = y_poles + real(r(i) * exp(p(i) * t_curr));
            end
            
            y(idx) = y_direct + y_poles;
        end
    end
    
    % 判断是否绘图
    if nargout == 0
        plot(tOut, y, 'LineWidth', 1.5);
        xlabel('时间 (s)'); 
        ylabel('幅值'); 
        title('单位阶跃响应'); 
        grid on;
        xlim([0 t_end]);
    end
end

function v = removeLeadingZeros(v)
    idx = find(abs(v) > 1e-12, 1, 'first');
    if isempty(idx)
        v = 0;
    else
        v = v(idx:end);
    end
    if isempty(v)
        v = 0;
    end
end