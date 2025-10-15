% filepath: @ss_zzy/subsref.m
function varargout = subsref(sys, s)
%SUBSREF 下标引用重载
%   允许使用 sys.A, sys.B 等语法访问属性

    switch s(1).type
        case '.'
            % 属性访问
            switch s(1).subs
                case 'A'
                    varargout{1} = sys.A;
                case 'B'
                    varargout{1} = sys.B;
                case 'C'
                    varargout{1} = sys.C;
                case 'D'
                    varargout{1} = sys.D;
                case 'Ts'
                    varargout{1} = sys.Ts;
                case 'StateName'
                    varargout{1} = sys.StateName;
                case 'InputName'
                    varargout{1} = sys.InputName;
                case 'OutputName'
                    varargout{1} = sys.OutputName;
                case 'Name'
                    varargout{1} = sys.Name;
                case 'Notes'
                    varargout{1} = sys.Notes;
                case 'UserData'
                    varargout{1} = sys.UserData;
                case 'TimeUnit'
                    varargout{1} = sys.TimeUnit;
                otherwise
                    error('ss_zzy:InvalidProperty', '未知属性: %s', s(1).subs);
            end
            
            % 处理多级引用
            if length(s) > 1
                varargout{1} = subsref(varargout{1}, s(2:end));
            end
            
        case '()'
            % 数组索引
            error('ss_zzy:UnsupportedOperation', 'ss_zzy 对象不支持 () 索引');
            
        case '{}'
            % 单元数组索引
            error('ss_zzy:UnsupportedOperation', 'ss_zzy 对象不支持 {} 索引');
    end
end