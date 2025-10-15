% filepath: lyap_zzy.m
function X = lyap_zzy(A, Q, B)
% LYAP_ZZY  求解李雅普诺夫方程和西尔维斯特方程
%
%   X = lyap_zzy(A, Q) 返回 AX + XA' + Q = 0 的解
%   X = lyap_zzy(A, B, C) 返回 AX + X*B' + C = 0 的解

    if nargin == 2
        % AX + XA' + Q = 0
        if ~ismatrix(A) || ~ismatrix(Q) || size(A,1) ~= size(A,2) || ~isequal(size(A), size(Q))
            error('A 和 Q 必须是相同大小的方阵');
        end

        n = size(A,1);
        I = eye(n);

        % Kronecker积
        K = kron(I, A) + kron(A, I);

        % 拉直Q并取负号（按列拉直）
        q_vec = -reshape(Q, [], 1);

        % 求解线性方程组
        x_vec = K \ q_vec;

        % 重组为矩阵
        X = reshape(x_vec, n, n);

        % 如果Q对称，则X也对称
        if issymmetric(Q)
            X = (X + X') / 2;
        end

    elseif nargin == 3
        % AX + X*B' + C = 0
        % 注意：这里的第二个参数是B，第三个参数是C
        if ~ismatrix(A) || ~ismatrix(Q) || ~ismatrix(B)
            error('A, B, C 必须是矩阵');
        end
        
        % 重命名参数以明确含义
        C = B;  % 第三个参数实际上是C
        B = Q;  % 第二个参数实际上是B
        
        m = size(A,1);
        n = size(B,1);

        if size(A,1) ~= size(A,2)
            error('A 必须是方阵');
        end
        if size(B,1) ~= size(B,2)
            error('B 必须是方阵');
        end
        if size(C,1) ~= m || size(C,2) ~= n
            error('C 必须是 %dx%d 矩阵', m, n);
        end

        I_m = eye(m);
        I_n = eye(n);

        % Kronecker积
        K = kron(I_n, A) + kron(B', I_m);

        % 拉直C并取负号（按列拉直）
        c_vec = -reshape(C, [], 1);

        % 求解线性方程组
        x_vec = K \ c_vec;

        % 重组为矩阵
        X = reshape(x_vec, m, n);
    else
        error('参数数量错误，应为2或3个参数');
    end
end