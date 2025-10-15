% filepath: @ss_zzy/step_zzy.m
function [y, tOut] = step_zzy(sys, t)
%STEP_ZZY 计算状态空间系统的单位阶跃响应
%
%   step_zzy(sys)           % 自动绘图
%   step_zzy(sys, t)        % 指定时间范围并绘图
%   [y, t] = step_zzy(...)  % 返回数据

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
    
    n_states = size(A, 1);
    y = zeros(n_points, 1);
    u = 1.0;  % 单位阶跃输入
    
    % 检查 A 是否可逆
    if abs(det(A)) < 1e-10
        error('矩阵 A 奇异，无法求逆');
    end
    
    A_inv = inv(A);
    I = eye(n_states);
    
    % 计算所有时间点的阶跃响应
    for i = 1:n_points
        t_curr = tOut(i);
        
        if t_curr == 0
            % t=0 时刻
            y(i) = D * u;
        else
            % 计算 e^(A*t)
            eAt = expm(A * t_curr);
            
            % 计算状态 x(t) = A^(-1) * (e^(At) - I) * B * u
            x_t = A_inv * (eAt - I) * B * u;
            
            % 输出 y(t) = C*x(t) + D*u
            y(i) = C * x_t + D * u;
        end
    end
    
    if nargout == 0
        plot(tOut, y, 'LineWidth', 1.5);
        xlabel('时间 (s)'); 
        ylabel('幅值'); 
        title('单位阶跃响应'); 
        grid on;
        xlim([0 t_end]);
    end
end