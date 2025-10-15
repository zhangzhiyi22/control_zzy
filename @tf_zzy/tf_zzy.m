% filepath: @tf_zzy/tf_zzy.m
function sys = tf_zzy(num, den, varargin)
% TF_ZZY 传递函数对象的构造函数 (zzy版本)

    % --- 1. 定义对象的完整结构 ---
    s.num = {1};
    s.den = {1};
    s.Ts = 0;
    s.Variable = 's';
    s.InputDelay = 0;
    s.OutputDelay = 0;
    s.IODelay = 0;
    s.InputName = {''};
    s.OutputName = {''};
    s.InputUnit = {''};
    s.OutputUnit = {''};
    s.InputGroup = struct();
    s.OutputGroup = struct();
    s.Notes = {};
    s.UserData = [];
    s.Name = '';
    s.TimeUnit = 'seconds';

    if nargin == 0, sys = class(s, 'tf_zzy'); return; end

    % --- 2. 输入参数验证 ---
    if nargin < 2, error('创建tf_zzy对象至少需要分子(num)和分母(den)两个参数。'); end
    if ~isnumeric(num) || ~isvector(num) || ~isnumeric(den) || ~isvector(den)
        error('分子(num)和分母(den)必须是数值向量。');
    end

    % --- 3. 核心数据处理 ---
    num_vec = num(:).';
    den_vec = den(:).';
    tol = 1e-12;

    % 去除前导零
    first_num_idx = find(abs(num_vec) > tol, 1, 'first');
    if isempty(first_num_idx)
        num_vec = 0;
    else
        num_vec = num_vec(first_num_idx:end);
    end

    first_den_idx = find(abs(den_vec) > tol, 1, 'first');
    if isempty(first_den_idx)
        error('分母(den)多项式不能为零。');
    else
        den_vec = den_vec(first_den_idx:end);
    end

    % 检查分母首项系数
    if abs(den_vec(1)) < tol
        error('分母(den)的首项系数不能为零。');
    end

    % --- 4. 填充核心属性 (保持原始系数) ---
    s.num = {num_vec};
    s.den = {den_vec};

    % 处理采样时间和变量名
    if ~isempty(varargin) && isnumeric(varargin{1})
        s.Ts = varargin{1};
    end

    % 根据采样时间正确设置变量名
    % 注意：您的C代码中 Ts = -1.0 表示连续系统，Ts > 0 表示离散系统
    if s.Ts == 0 || s.Ts == -1.0 || s.Ts < 0
        % 连续系统
        s.Variable = 's';
        if s.Ts < 0
            s.Ts = 0;  % 将内部的 -1.0 转换为标准的 0
        end
    else
        % 离散系统
        s.Variable = 'z';
    end

    % --- 5. 创建并返回 tf_zzy 对象 ---
    sys = class(s, 'tf_zzy');
end



