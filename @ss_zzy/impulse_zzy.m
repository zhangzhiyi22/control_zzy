% filepath: @ss_zzy/impulse_zzy.m
function [y, tOut] = impulse_zzy(sys, t)
%IMPULSE_ZZY 计算状态空间系统的单位脉冲响应
%
%   impulse_zzy(sys)           % 自动绘图
%   impulse_zzy(sys, t)        % 指定时间范围并绘图
%   [y, t] = impulse_zzy(...)  % 返回数据

    if ~isa(sys, 'ss_zzy')
        error('输入必须是 ss_zzy 对象');
    end
    
    if nargin == 1
        t_end = 10.0;
    else
        t_end = t;
    end
    
    A = sys.A;
    B = sys.B;
    C = sys.C;
    D = sys.D;
    
    dt = 0.01;
    n_points = floor(t_end / dt) + 1;
    tOut = (0:n_points-1)' * dt;
    
    y = zeros(n_points, 1);
    
    % === 最优方法：t=0+ 时刻 ===
    % 脉冲输入 δ(t) → x(0+) = B
    % y(0+) = C*B
    x = B(:, 1);  % 假设单输入系统
    y(1) = C * x;
    
    % 预计算 e^(A*dt)
    eAdt = expm(A * dt);
    
    % 从 t=dt 开始迭代
    for i = 2:n_points
        x = eAdt * x;
        y(i) = C * x;
    end
    
    if nargout == 0
        plot(tOut, y, 'LineWidth', 1.5);
        xlabel('时间 (s)'); 
        ylabel('幅值'); 
        title('单位脉冲响应'); 
        grid on;
        xlim([0 t_end]);
    end
end