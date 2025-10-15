% filepath: @ss/pole_zzy.m
function p = pole_zzy(sys)
% POLE_ZZY  计算 ss 对象的极点。
%
%   P = POLE_ZZY(SYS) 返回状态空间对象 SYS 的极点。
%   此函数的算法参考了 poleFun.c：对于状态空间模型，极点就是
%   其 A 矩阵的特征值。

    % --- 1. 输入验证 ---
    % 确保输入是 ss 类的对象
    if ~isa(sys, 'ss_zzy')
        error('POLE_ZZY 函数的输入必须是 ss_zzy 对象。');
    end

    % --- 2. 获取 A 矩阵 ---
    % 从 ss 对象的属性中获取状态矩阵 A。
    A_matrix = sys.A;

    % --- 3. 计算极点 ---
    % 根据 poleFun.c -> pole_ss -> pole_matrix 的逻辑，
    % 状态空间模型的极点就是其 A 矩阵的特征值。
    % MATLAB 的 eig() 函数对应您 C 代码中调用的 GSL 特征值求解器。
    p = eig(A_matrix);

end