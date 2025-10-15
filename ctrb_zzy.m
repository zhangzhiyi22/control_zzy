% filepath: ctrb_zzy.m
function Co = ctrb_zzy(varargin)
% CTRB_ZZY  计算系统的可控性矩阵（zzy版本）
%
%   Co = CTRB_ZZY(A, B) 计算可控性矩阵 Co = [B AB A^2*B ... A^(n-1)*B]
%   Co = CTRB_ZZY(SYS) 计算系统对象的可控性矩阵
%   
%   可控性矩阵用于判断系统的状态可控性：
%   - 系统完全可控当且仅当可控性矩阵满秩（rank(Co) = n）
%   - 可控性矩阵的秩等于系统的可控状态数

    % 解析输入参数
    if nargin == 1
        % 单个参数：系统对象
        sys = varargin{1};
        
        if isa(sys, 'ss_zzy')
            % ss_zzy 对象 - 获取A和B矩阵
            A = sys.A;
            B = sys.B;
        elseif isa(sys, 'ss')
            % MATLAB 内置 ss 对象
            A = sys.A;
            B = sys.B;
        else
            error('CTRB_ZZY: 输入必须是状态空间系统对象');
        end
        
    elseif nargin == 2
        % 两个参数：A, B 矩阵
        A = varargin{1};
        B = varargin{2};
        
        % 验证输入
        if ~isnumeric(A) || ~isnumeric(B)
            error('CTRB_ZZY: A和B必须是数值矩阵');
        end
        
    else
        error('CTRB_ZZY: 输入参数个数错误。使用: ctrb_zzy(A,B) 或 ctrb_zzy(sys)');
    end
    
    % 验证矩阵维度
    if size(A,1) ~= size(A,2)
        error('CTRB_ZZY: A矩阵必须是方形矩阵');
    end
    
    if size(A,1) ~= size(B,1)
        error('CTRB_ZZY: A和B矩阵的行数必须相同');
    end
    
    % 计算可控性矩阵
    try
        n = size(A, 1);  % 状态维数
        m = size(B, 2);  % 输入维数
        
        % 初始化可控性矩阵 Co = [B AB A^2B ... A^(n-1)B]
        Co = zeros(n, n*m);
        
        % 第一列块：B
        Co(:, 1:m) = B;
        
        % 计算 A^k * B，k = 1, 2, ..., n-1
        A_power = A;  % A^1
        for k = 1:(n-1)
            % A^k * B
            A_k_B = A_power * B;
            
            % 填充到可控性矩阵
            start_col = k*m + 1;
            end_col = (k+1)*m;
            Co(:, start_col:end_col) = A_k_B;
            
            % 更新A的幂：A^(k+1) = A^k * A
            if k < n-1
                A_power = A_power * A;
            end
        end
        
    catch ME
        error('CTRB_ZZY: 计算可控性矩阵失败: %s', ME.message);
    end
end