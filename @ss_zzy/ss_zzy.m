% filepath: @ss_zzy/ss_zzy.m
function sys = ss_zzy(A, B, C, D, varargin)
% SS_ZZY  状态空间模型的构造函数（zzy版本）
%
%   SYS = SS_ZZY(A, B, C, D) 创建一个连续时间状态空间对象。
%
%   SYS = SS_ZZY(A, B, C, D, TS) 创建一个离散时间状态空间对象，
%   采样时间为 TS。

    % --- 1. 定义对象的默认结构 (蓝图) ---
    s.A = [];
    s.B = [];
    s.C = [];
    s.D = [];
    s.Ts = 0;
    s.StateName = {};
    s.InputName = {};
    s.OutputName = {};
    s.Name = '';
    s.Notes = {};
    s.UserData = [];
    s.TimeUnit = 'seconds';

    % 如果没有输入参数，返回一个空的默认对象
    if nargin == 0
        sys = class(s, 'ss_zzy');
        return;
    end

    % --- 2. 输入参数验证 ---
    if nargin < 4
        error('创建ss_zzy对象至少需要 A, B, C, D 四个矩阵。');
    end
    if ~isnumeric(A) || ~isnumeric(B) || ~isnumeric(C) || ~isnumeric(D)
        error('输入 A, B, C, D 必须是数值矩阵。');
    end
    
    % 验证矩阵维度兼容性
    [nA1, nA2] = size(A);
    [nB1, nB2] = size(B);
    [nC1, nC2] = size(C);
    [nD1, nD2] = size(D);
    
    if nA1 ~= nA2
        error('A 矩阵必须是方阵');
    end
    if nB1 ~= nA1
        error('B 矩阵的行数必须等于 A 矩阵的行数');
    end
    if nC2 ~= nA1
        error('C 矩阵的列数必须等于 A 矩阵的行数');
    end
    if nD1 ~= nC1 || nD2 ~= nB2
        error('D 矩阵的维度必须与 C 的行数和 B 的列数兼容');
    end

    % --- 3. 填充核心属性 ---
    s.A = A;
    s.B = B;
    s.C = C;
    s.D = D;
    
    % 处理可选的采样时间 Ts
    if ~isempty(varargin) && isnumeric(varargin{1})
        s.Ts = varargin{1};
    end

    % --- 4. 创建并返回 ss_zzy 对象 ---
    sys = class(s, 'ss_zzy');
end


