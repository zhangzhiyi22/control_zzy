% filepath: @tf_zzy/subsref.m
function varargout = subsref(sys, s)
%SUBSREF 下标引用重载
%   允许使用 sys.num, sys.den, sys.Ts 等语法访问属性

    switch s(1).type
        case '.'
            % 属性访问
            switch s(1).subs
                case {'num', 'numerator', 'Numerator'}
                    varargout{1} = sys.num;
                case {'den', 'denominator', 'Denominator'}
                    varargout{1} = sys.den;
                case {'Ts', 'ts', 'SamplingTime', 'samplingtime'}
                    varargout{1} = sys.Ts;
                case {'Variable', 'variable'}
                    varargout{1} = sys.Variable;
                case {'InputDelay', 'inputdelay'}
                    varargout{1} = sys.InputDelay;
                case {'OutputDelay', 'outputdelay'}
                    varargout{1} = sys.OutputDelay;
                case {'IODelay', 'iodelay'}
                    varargout{1} = sys.IODelay;
                case {'InputName', 'inputname'}
                    varargout{1} = sys.InputName;
                case {'OutputName', 'outputname'}
                    varargout{1} = sys.OutputName;
                case {'InputUnit', 'inputunit'}
                    varargout{1} = sys.InputUnit;
                case {'OutputUnit', 'outputunit'}
                    varargout{1} = sys.OutputUnit;
                case {'InputGroup', 'inputgroup'}
                    varargout{1} = sys.InputGroup;
                case {'OutputGroup', 'outputgroup'}
                    varargout{1} = sys.OutputGroup;
                case {'Notes', 'notes'}
                    varargout{1} = sys.Notes;
                case {'UserData', 'userdata'}
                    varargout{1} = sys.UserData;
                case {'Name', 'name'}
                    varargout{1} = sys.Name;
                case {'TimeUnit', 'timeunit'}
                    varargout{1} = sys.TimeUnit;
                otherwise
                    error('tf_zzy:InvalidProperty', '未知属性: %s', s(1).subs);
            end
            
            % 处理多级引用
            if length(s) > 1
                varargout{1} = subsref(varargout{1}, s(2:end));
            end
            
        case '()'
            % 数组索引 - 用于 MIMO 系统（当前只支持 SISO）
            if length(s(1).subs) == 1
                idx = s(1).subs{1};
                if strcmp(idx, ':') || idx == 1
                    varargout{1} = sys;
                else
                    error('tf_zzy:InvalidIndex', '当前只支持 SISO 系统，索引必须为 1 或 ":"');
                end
            elseif length(s(1).subs) == 2
                idx1 = s(1).subs{1};
                idx2 = s(1).subs{2};
                if (strcmp(idx1, ':') || idx1 == 1) && (strcmp(idx2, ':') || idx2 == 1)
                    varargout{1} = sys;
                else
                    error('tf_zzy:InvalidIndex', '当前只支持 SISO 系统，索引必须为 (1,1) 或 (:,:)');
                end
            else
                error('tf_zzy:InvalidIndex', '索引维度不正确');
            end
            
            % 处理多级引用
            if length(s) > 1
                varargout{1} = subsref(varargout{1}, s(2:end));
            end
            
        case '{}'
            % 单元数组索引 - 不支持
            error('tf_zzy:UnsupportedOperation', 'tf_zzy 对象不支持 {} 索引');
    end
end