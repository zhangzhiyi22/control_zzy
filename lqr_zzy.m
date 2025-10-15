% filepath: lqr_zzy.m
function varargout = lqr_zzy(varargin)
%LQR_ZZY 线性二次型调节器设计
%   计算连续时间或离散时间状态空间系统的最优反馈增益矩阵
%
%   语法:
%       K = lqr_zzy(SYS, Q, R)
%       K = lqr_zzy(SYS, Q, R, N)
%       K = lqr_zzy(A, B, Q, R)
%       K = lqr_zzy(A, B, Q, R, N)
%       [K, S, P] = lqr_zzy(...)
%
%   输入参数:
%       SYS - ss_zzy 状态空间对象
%       A   - 状态矩阵 (n×n)
%       B   - 输入矩阵 (n×m)
%       Q   - 状态权重矩阵 (n×n, 半正定对称矩阵)
%       R   - 控制权重矩阵 (m×m, 正定对称矩阵)
%       N   - 交叉项矩阵 (n×m, 可选, 默认为零)
%
%   输出参数:
%       K - 最优反馈增益矩阵 (m×n)
%       S - 代数黎卡提方程的解 (n×n)
%       P - 闭环极点 (向量)
%
%   连续时间系统:
%       最小化性能指标: J = ∫[x'Qx + u'Ru + 2x'Nu] dt
%       最优控制律: u = -Kx
%       黎卡提方程: A'S + SA - (SB + N)R^(-1)(B'S + N') + Q = 0
%       反馈增益: K = R^(-1)(B'S + N')
%
%   离散时间系统:
%       最小化性能指标: J = Σ[x'Qx + u'Ru + 2x'Nu]
%       最优控制律: u = -Kx
%       黎卡提方程: A'SA - S - (A'SB + N)(R + B'SB)^(-1)(B'SA + N') + Q = 0
%       反馈增益: K = (R + B'SB)^(-1)(B'SA + N')

    % 解析输入参数
    narginchk(3, 5);
    
    % 判断第一个参数是 ss_zzy 对象还是矩阵
    if isa(varargin{1}, 'ss_zzy')
        % 语法: lqr_zzy(SYS, Q, R) 或 lqr_zzy(SYS, Q, R, N)
        sys = varargin{1};
        A = sys.A;
        B = sys.B;
        Q = varargin{2};
        R = varargin{3};
        
        if nargin >= 4
            N = varargin{4};
        else
            N = zeros(size(A, 1), size(B, 2));
        end
        
        Ts = sys.Ts;
        
    else
        % 语法: lqr_zzy(A, B, Q, R) 或 lqr_zzy(A, B, Q, R, N)
        A = varargin{1};
        B = varargin{2};
        Q = varargin{3};
        R = varargin{4};
        
        if nargin >= 5
            N = varargin{5};
        else
            N = zeros(size(A, 1), size(B, 2));
        end
        
        Ts = 0; % 默认为连续时间
    end
    
    % ========== 参数验证 ==========
    [n, n_col] = size(A);
    [n_b, m] = size(B);
    [n_q, m_q] = size(Q);
    [m_r, m_r_col] = size(R);
    [n_n, m_n] = size(N);
    
    % 检查 A 是否为方阵
    if n ~= n_col
        error('lqr_zzy:InvalidA', 'A 必须是方阵');
    end
    
    % 检查 B 的行数是否与 A 匹配
    if n_b ~= n
        error('lqr_zzy:DimensionMismatch', 'B 的行数必须与 A 的维度匹配');
    end
    
    % 检查 Q 是否为 n×n 方阵
    if n_q ~= n || m_q ~= n
        error('lqr_zzy:InvalidQ', 'Q 必须是 %d×%d 矩阵', n, n);
    end
    
    % 检查 R 是否为 m×m 方阵
    if m_r ~= m || m_r_col ~= m
        error('lqr_zzy:InvalidR', 'R 必须是 %d×%d 矩阵', m, m);
    end
    
    % 检查 N 的维度
    if n_n ~= n || m_n ~= m
        error('lqr_zzy:InvalidN', 'N 必须是 %d×%d 矩阵', n, m);
    end
    
    % 检查 Q 是否对称
    if norm(Q - Q', 'fro') > 1e-10
        warning('lqr_zzy:QNotSymmetric', 'Q 不是对称矩阵，将使用 (Q+Q'')/2');
        Q = (Q + Q') / 2;
    end
    
    % 检查 R 是否对称
    if norm(R - R', 'fro') > 1e-10
        warning('lqr_zzy:RNotSymmetric', 'R 不是对称矩阵，将使用 (R+R'')/2');
        R = (R + R') / 2;
    end
    
    % 检查 Q 是否半正定
    eigQ = eig(Q);
    if any(eigQ < -1e-10)
        error('lqr_zzy:QNotPositiveSemiDefinite', 'Q 必须是半正定矩阵');
    end
    
    % 检查 R 是否正定
    eigR = eig(R);
    if any(eigR <= 1e-10)
        error('lqr_zzy:RNotPositiveDefinite', 'R 必须是正定矩阵');
    end
    
    % ========== 求解黎卡提方程 ==========
    if Ts == 0
        % 连续时间系统
        S = care_local(A, B, Q, R, N);
        K = R \ (B' * S + N');
    else
        % 离散时间系统
        S = dare_local(A, B, Q, R, N);
        K = (R + B' * S * B) \ (B' * S * A + N');
    end
    
    % ========== 计算闭环极点 ==========
    if nargout >= 3
        A_cl = A - B * K;
        P = eig(A_cl);
    end
    
    % ========== 返回结果 ==========
    varargout{1} = K;
    
    if nargout >= 2
        varargout{2} = S;
    end
    
    if nargout >= 3
        varargout{3} = P;
    end
end

%% ========== 内部辅助函数 ==========

function S = care_local(A, B, Q, R, N)
%CARE_LOCAL 连续时间代数黎卡提方程求解器
%   求解: A'S + SA - (SB + N)R^(-1)(B'S + N') + Q = 0
%   使用 Hamilton 矩阵特征值分解方法

    n = size(A, 1);
    
    % 构造 Hamilton 矩阵
    % H = [  A            -B*R^(-1)*B'  ]
    %     [ -Q-N*R^(-1)*N'   -A'        ]
    
    R_inv = inv(R);
    BR_invBt = B * R_inv * B';
    NR_invNt = N * R_inv * N';
    
    H = [A, -BR_invBt; 
         -(Q + NR_invNt), -A'];
    
    % 计算 Hamilton 矩阵的特征值和特征向量
    [V, D] = eig(H);
    
    % 提取具有负实部的特征值对应的特征向量
    eigenvalues = diag(D);
    stable_idx = real(eigenvalues) < 0;
    
    if sum(stable_idx) ~= n
        error('care_local:NoStableSolution', ...
            '未找到稳定解: 稳定特征值数量 = %d, 期望 = %d', sum(stable_idx), n);
    end
    
    % 提取稳定的特征向量
    V_stable = V(:, stable_idx);
    
    % 分离 V1 和 V2
    V1 = V_stable(1:n, :);
    V2 = V_stable(n+1:2*n, :);
    
    % 计算 S = V2 / V1
    S = real(V2 / V1);
    
    % 确保 S 是对称的
    S = (S + S') / 2;
end

function S = dare_local(A, B, Q, R, N)
%DARE_LOCAL 离散时间代数黎卡提方程求解器
%   求解: A'SA - S - (A'SB + N)(R + B'SB)^(-1)(B'SA + N') + Q = 0
%   使用广义 Schur 分解方法

    n = size(A, 1);
    m = size(B, 2);
    
    % 构造广义特征值问题矩阵
    % M - λL = 0
    % 其中:
    % M = [ A+B*R^(-1)*N'           B*R^(-1)*B'      ]
    %     [ -Q-N*R^(-1)*N'    -(A-B*R^(-1)*N')' ]
    %
    % L = [ I    0 ]
    %     [ 0   A' ]
    
    R_inv = inv(R);
    BR_inv = B * R_inv;
    NR_inv = N * R_inv;
    
    M = [A + BR_inv * N', BR_inv * B'; 
         -(Q + NR_inv * N'), -(A - BR_inv * N')'];
    
    L = [eye(n), zeros(n); 
         zeros(n), A'];
    
    % 广义 Schur 分解
    [AA, BB, Q_mat, Z] = qz(M, L);
    
    % 提取稳定的广义特征值 (模小于1)
    eigenvalues = ordeig(AA, BB);
    stable_idx = abs(eigenvalues) < 1;
    
    if sum(stable_idx) ~= n
        error('dare_local:NoStableSolution', ...
            '未找到稳定解: 稳定特征值数量 = %d, 期望 = %d', sum(stable_idx), n);
    end
    
    % 重新排序使稳定的特征值在前
    [~, ~, ~, Z] = ordqz(AA, BB, Q_mat, Z, stable_idx);
    
    % 提取稳定子空间
    Z11 = Z(1:n, 1:n);
    Z21 = Z(n+1:2*n, 1:n);
    
    % 计算 S = Z21 / Z11
    S = real(Z21 / Z11);
    
    % 确保 S 是对称的
    S = (S + S') / 2;
end