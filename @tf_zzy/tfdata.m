% filepath: @tf_zzy/tfdata.m
function [num, den, Ts, varargout] = tfdata(sys, format)
% TFDATA  提取 tf_zzy 传递函数数据
%
%   [NUM, DEN] = TFDATA(SYS) 返回传递函数的分子和分母（元胞数组形式）
%   [NUM, DEN, TS] = TFDATA(SYS) 同时返回采样时间
%   [NUM, DEN] = TFDATA(SYS, 'v') 返回向量形式而不是元胞数组

    if ~isa(sys, 'tf_zzy')
        error('输入必须是 tf_zzy 对象');
    end
    
    if nargin < 2
        format = 'cell';
    end
    
    % 获取数据
    if strcmp(format, 'v') || strcmp(format, 'vector')
        % 返回向量形式
        num = sys.num{1};
        den = sys.den{1};
    else
        % 返回元胞数组形式（与 MATLAB tf 一致）
        num = sys.num;
        den = sys.den;
    end
    
    % 采样时间
    if nargout >= 3
        Ts = sys.Ts;
    end
    
    % 其他输出参数（为了与 MATLAB tf 兼容）
    if nargout > 3
        varargout{1} = sys.Variable;  % 变量名 ('s' 或 'z')
    end
end