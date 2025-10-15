% filepath: @ss/ss2tf_zzy.m
function [num, den] = ss2tf_zzy(sys, ni)
% SS2TF_ZZY  将 ss_zzy 对象转换为传递函数表示
%
%   [NUM, DEN] = SS2TF_ZZY(SYS) 将单输入单输出(SISO) ss_zzy 对象转换为
%   等效的传递函数
%
%   [NUM, DEN] = SS2TF_ZZY(SYS, NI) 计算多输入(MIMO) ss_zzy 对象中，
%   从第 NI 个输入到所有输出的传递函数

    % --- 1. 输入验证 ---
    if ~isa(sys, 'ss_zzy')
        error('ss2tf_zzy 方法的第一个参数必须是 ss 对象');
    end

    % --- 2. 提取矩阵并调用核心函数 ---
    if nargin < 2
        % 调用独立函数，不传 ni 参数
        [num, den] = ss2tf_zzy(sys.A, sys.B, sys.C, sys.D);
    else
        % 调用独立函数，传入 ni 参数
        [num, den] = ss2tf_zzy(sys.A, sys.B, sys.C, sys.D, ni);
    end
end