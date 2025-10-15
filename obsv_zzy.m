% filepath: obsv_zzy.m
function Ob = obsv_zzy(varargin)
% OBSV_ZZY  计算系统的可观测性矩阵（zzy版本）
%
%   Ob = OBSV_ZZY(A, C) 计算可观测性矩阵 Ob = [C; CA; CA^2; ...; CA^(n-1)]
%   Ob = OBSV_ZZY(SYS) 计算系统对象的可观测性矩阵
%   
%   可观测性矩阵用于判断系统的状态可观测性：
%   - 系统完全可观测当且仅当可观测性矩阵满秩（rank(Ob) = n）
%   - 可观测性矩阵的秩等于系统的可观测状态数

    % 解析输入参数
    if nargin == 1
        % 单个参数：系统对象
        sys = varargin{1};
        
        if isa(sys, 'ss_zzy')
            % ss_zzy 对象 - 获取A和C矩阵
            A = sys.A;
            C = sys.C;
        elseif isa(sys, 'ss')
            % MATLAB 内置 ss 对象
            A = sys.A;
            C = sys.C;
        else
            error('OBSV_ZZY: 输入必须是状态空间系统对象');
        end
        
    elseif nargin == 2
        % 两个参数：A, C 矩阵
        A = varargin{1};
        C = varargin{2};
        
        % 验证输入
        if ~isnumeric(A) || ~isnumeric(C)
            error('OBSV_ZZY: A和C必须是数值矩阵');
        end
        
    else
        error('OBSV_ZZY: 输入参数个数错误。使用: obsv_zzy(A,C) 或 obsv_zzy(sys)');
    end
    
    % 验证矩阵维度
    if size(A,1) ~= size(A,2)
        error('OBSV_ZZY: A矩阵必须是方形矩阵');
    end
    
    if size(C,2) ~= size(A,1)
        error('OBSV_ZZY: C矩阵的列数必须等于A矩阵的行数');
    end
    
    % 计算可观测性矩阵
    try
        n = size(A, 1);  % 状态维数
        p = size(C, 1);  % 输出维数
        
        % 初始化可观测性矩阵 Ob = [C; CA; CA^2; ...; CA^(n-1)]
        Ob = zeros(n*p, n);
        
        % 第一行块：C
        Ob(1:p, :) = C;
        
        % 计算 C * A^k，k = 1, 2, ..., n-1
        CA_power = C;  % CA^0 = C
        for k = 1:(n-1)
            % CA^k = (CA^(k-1)) * A
            CA_power = CA_power * A;
            
            % 填充到可观测性矩阵
            start_row = k*p + 1;
            end_row = (k+1)*p;
            Ob(start_row:end_row, :) = CA_power;
        end
        
    catch ME
        error('OBSV_ZZY: 计算可观测性矩阵失败: %s', ME.message);
    end
end