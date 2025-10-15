% filepath: @tf_zzy/impulse_zzy.m
function [y, tOut] = impulse_zzy(sys, t)
%IMPULSE_ZZY 计算传递函数的单位脉冲响应
%
%   impulse_zzy(sys)           % 自动绘图
%   impulse_zzy(sys, t)        % 指定时间范围并绘图
%   [y, t] = impulse_zzy(...)  % 返回数据

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
        y = zeros(n_points, 1);
        y(1) = K;
        if nargout == 0
            stem(tOut(1), y(1), 'filled');
            xlabel('时间 (s)'); ylabel('幅值'); 
            title('单位脉冲响应'); grid on;
            xlim([0 t_end]); ylim([0 y(1)*1.2]);
        end
        return;
    end
    
    %% 使用部分分式展开计算脉冲响应
    % 脉冲响应 = L^{-1}{G(s)} = L^{-1}{num(s)/den(s)}
    
    % 部分分式展开
    [r, p, k] = residue(num, den);
    
    % 初始化输出
    y = zeros(n_points, 1);
    
    % 计算每个时间点的响应
    for idx = 1:n_points
        t_curr = tOut(idx);
        
        if t_curr == 0
            % t=0 时刻，真分式系统的脉冲响应初值通常为所有留数之和
            % 这对应 lim(s→∞) s*G(s) 的值
            if m < n
                % 真分式：y(0+) = 0 或根据系统特性
                y(idx) = sum(real(r));
            else
                % 非真分式：有直接传递项
                y(idx) = sum(real(r));
            end
        else
            % t > 0 时刻
            
            % 多项式部分 k（对应脉冲及其导数，在 t>0 时贡献为 0）
            y_direct = 0;
            
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
        title('单位脉冲响应'); 
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