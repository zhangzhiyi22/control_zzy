% filepath: @tf_zzy/get.m
function val = get(sys, property)
% GET  获取 tf_zzy 对象属性
%
%   VAL = GET(SYS, PROPERTY) 返回指定属性的值

    if ~isa(sys, 'tf_zzy')
        error('第一个参数必须是 tf_zzy 对象');
    end
    
    switch lower(property)
        case {'num', 'numerator'}
            val = sys.num;
        case {'den', 'denominator'}
            val = sys.den;
        case {'ts', 'samplingtime'}
            val = sys.Ts;
        case {'variable'}
            val = sys.Variable;
        case {'inputname'}
            val = sys.InputName;
        case {'outputname'}
            val = sys.OutputName;
        case {'name'}
            val = sys.Name;
        case {'notes'}
            val = sys.Notes;
        case {'userdata'}
            val = sys.UserData;
        otherwise
            error('未知属性: %s', property);
    end
end