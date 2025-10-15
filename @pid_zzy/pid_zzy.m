% filepath: @pid_zzy/pid_zzy.m
classdef pid_zzy
    %PID_ZZY PID 控制器类
    %   创建连续时间或离散时间 PID 控制器
    
    properties
        Kp = 1              % 比例增益
        Ki = 0              % 积分增益
        Kd = 0              % 微分增益
        Tf = 0.01           % 微分滤波器时间常数
        IFormula = ''       % 积分公式
        DFormula = ''       % 微分公式
        InputDelay = 0      % 输入延迟
        OutputDelay = 0     % 输出延迟
        InputName = {''}    % 输入名称
        InputUnit = {''}    % 输入单位
        InputGroup          % 输入分组
        OutputName = {''}   % 输出名称
        OutputUnit = {''}   % 输出单位
        OutputGroup         % 输出分组
        Notes = []          % 注释
        UserData = []       % 用户数据
        Name = ''           % 模型名称
        Ts = 0              % 采样时间
        TimeUnit = 'seconds' % 时间单位
        SamplingGrid        % 采样网格
    end
    
    methods
        function obj = pid_zzy(varargin)
            %PID_ZZY 构造 PID 控制器对象
            
            % 初始化结构体属性
            obj.InputGroup = struct();
            obj.OutputGroup = struct();
            obj.SamplingGrid = struct();
            
            % 解析输入参数
            if nargin >= 1, obj.Kp = varargin{1}; end
            if nargin >= 2, obj.Ki = varargin{2}; end
            if nargin >= 3, obj.Kd = varargin{3}; end
            if nargin >= 4, obj.Tf = varargin{4}; end
            if nargin >= 5, obj.Ts = varargin{5}; end
            
            % 参数验证
            if obj.Tf < 0
                error('pid_zzy:InvalidTf', 'Tf 必须非负');
            end
            if obj.Ts < 0
                error('pid_zzy:InvalidTs', '采样时间 Ts 必须非负');
            end
            
            % 设置默认公式
            if obj.Ts > 0
                if isempty(obj.IFormula)
                    obj.IFormula = 'ForwardEuler';
                end
                if isempty(obj.DFormula)
                    obj.DFormula = 'ForwardEuler';
                end
            end
        end
        
        function disp(obj)
            %DISP 显示 PID 控制器
            
            % 检测控制器类型
            isP = (obj.Ki == 0 && obj.Kd == 0);
            isPI = (obj.Ki ~= 0 && obj.Kd == 0);
            isPD = (obj.Ki == 0 && obj.Kd ~= 0);
            
            fprintf('\n');
            
            if obj.Ts == 0
                % ========== 连续时间 ==========
                if isP
                    fprintf('  Kp\n');
                    fprintf(' \n');
                    fprintf('  且 Kp = %g\n', obj.Kp);
                    fprintf(' \n');
                    fprintf('连续时间 P 控制器。\n');
                    
                elseif isPI
                    fprintf('            1\n');
                    fprintf('  Kp + Ki * ---\n');
                    fprintf('            s\n');
                    fprintf(' \n');
                    fprintf('  且 Kp = %g, Ki = %g\n', obj.Kp, obj.Ki);
                    fprintf(' \n');
                    fprintf('并联型的连续时间 PI 控制器。\n');
                    
                elseif isPD
                    if obj.Tf == 0
                        fprintf('  Kp + Kd * s\n');
                        fprintf(' \n');
                        fprintf('  且 Kp = %g, Kd = %g\n', obj.Kp, obj.Kd);
                    else
                        fprintf('              Kd*s\n');
                        fprintf('  Kp + ----------\n');
                        fprintf('         Tf*s + 1\n');
                        fprintf(' \n');
                        fprintf('  且 Kp = %g, Kd = %g, Tf = %g\n', obj.Kp, obj.Kd, obj.Tf);
                    end
                    fprintf(' \n');
                    fprintf('并联型的连续时间 PD 控制器。\n');
                    
                else % PID
                    if obj.Tf == 0
                        fprintf('            1\n');
                        fprintf('  Kp + Ki * --- + Kd * s\n');
                        fprintf('            s\n');
                        fprintf(' \n');
                        fprintf('  且 Kp = %g, Ki = %g, Kd = %g\n', obj.Kp, obj.Ki, obj.Kd);
                    else
                        fprintf('            1           Kd*s\n');
                        fprintf('  Kp + Ki * --- + ----------\n');
                        fprintf('            s        Tf*s + 1\n');
                        fprintf(' \n');
                        fprintf('  且 Kp = %g, Ki = %g, Kd = %g, Tf = %g\n', ...
                            obj.Kp, obj.Ki, obj.Kd, obj.Tf);
                    end
                    fprintf(' \n');
                    fprintf('并联型的连续时间 PID 控制器。\n');
                end
                
            else
                % ========== 离散时间 ==========
                % 根据离散化方法显示不同的公式
                
                if isP
                    fprintf('  Kp\n');
                    fprintf(' \n');
                    fprintf('  且 Kp = %g, Ts = %g\n', obj.Kp, obj.Ts);
                    fprintf(' \n');
                    fprintf('采样时间: %g seconds\n', obj.Ts);
                    fprintf('离散时间 P 控制器。\n');
                    
                elseif isPI
                    % PI 控制器 - 根据积分方法显示
                    switch obj.IFormula
                        case 'ForwardEuler'
                            fprintf('              Ts  \n');
                            fprintf('  Kp + Ki * ------\n');
                            fprintf('              z-1 \n');
                        case 'BackwardEuler'
                            fprintf('              Ts*z\n');
                            fprintf('  Kp + Ki * ------\n');
                            fprintf('              z-1 \n');
                        case 'Trapezoidal'
                            fprintf('            Ts*(z+1)\n');
                            fprintf('  Kp + Ki * --------\n');
                            fprintf('            2*(z-1)\n');
                        otherwise
                            fprintf('              Ts  \n');
                            fprintf('  Kp + Ki * ------\n');
                            fprintf('              z-1 \n');
                    end
                    fprintf(' \n');
                    fprintf('  且 Kp = %g, Ki = %g, Ts = %g\n', obj.Kp, obj.Ki, obj.Ts);
                    fprintf(' \n');
                    fprintf('采样时间: %g seconds\n', obj.Ts);
                    fprintf('并联型的离散时间 PI 控制器。\n');
                    
                elseif isPD
                    % PD 控制器
                    if obj.Tf == 0
                        N_val = Inf;
                    else
                        N_val = obj.Tf / obj.Ts;
                    end
                    
                    switch obj.DFormula
                        case 'ForwardEuler'
                            fprintf('            N*(z-1)\n');
                            fprintf('  Kp + Kd * ------\n');
                            fprintf('              z   \n');
                        case 'BackwardEuler'
                            fprintf('            N*(z-1)\n');
                            fprintf('  Kp + Kd * ------\n');
                            fprintf('              z   \n');
                        case 'Trapezoidal'
                            fprintf('            N*(z-1)\n');
                            fprintf('  Kp + Kd * ----------\n');
                            fprintf('            z+(N-1)\n');
                        otherwise
                            fprintf('            N*(z-1)\n');
                            fprintf('  Kp + Kd * ------\n');
                            fprintf('              z   \n');
                    end
                    fprintf(' \n');
                    if isinf(N_val)
                        fprintf('  且 Kp = %g, Kd = %g, N = Inf, Ts = %g\n', ...
                            obj.Kp, obj.Kd, obj.Ts);
                    else
                        fprintf('  且 Kp = %g, Kd = %g, N = %g, Ts = %g\n', ...
                            obj.Kp, obj.Kd, N_val, obj.Ts);
                    end
                    fprintf(' \n');
                    fprintf('采样时间: %g seconds\n', obj.Ts);
                    fprintf('并联型的离散时间 PD 控制器。\n');
                    
                else % PID
                    if obj.Tf == 0
                        N_val = Inf;
                    else
                        N_val = obj.Tf / obj.Ts;
                    end
                    
                    % 根据公式组合显示
                    if strcmp(obj.IFormula, 'ForwardEuler') && strcmp(obj.DFormula, 'ForwardEuler')
                        fprintf('              Ts          N*(z-1)\n');
                        fprintf('  Kp + Ki * ------ + Kd * ------\n');
                        fprintf('              z-1           z   \n');
                    elseif strcmp(obj.IFormula, 'Trapezoidal') && strcmp(obj.DFormula, 'Trapezoidal')
                        fprintf('            Ts*(z+1)       N*(z-1)\n');
                        fprintf('  Kp + Ki * -------- + Kd * ----------\n');
                        fprintf('            2*(z-1)       z+(N-1)\n');
                    else
                        % 默认显示
                        fprintf('              Ts          N*(z-1)\n');
                        fprintf('  Kp + Ki * ------ + Kd * ----------\n');
                        fprintf('              z-1         z+(N-1)\n');
                    end
                    
                    fprintf(' \n');
                    if isinf(N_val)
                        fprintf('  且 Kp = %g, Ki = %g, Kd = %g, N = Inf, Ts = %g\n', ...
                            obj.Kp, obj.Ki, obj.Kd, obj.Ts);
                    else
                        fprintf('  且 Kp = %g, Ki = %g, Kd = %g, N = %g, Ts = %g\n', ...
                            obj.Kp, obj.Ki, obj.Kd, N_val, obj.Ts);
                    end
                    fprintf(' \n');
                    fprintf('采样时间: %g seconds\n', obj.Ts);
                    fprintf('并联型的离散时间 PID 控制器。\n');
                end
            end
            
            % ========== 添加"模型属性"超链接 ==========
            var_name = inputname(1);
            if isempty(var_name)
                var_name = 'ans';
            end
            
            link_text = sprintf('<a href="matlab:get(%s)">模型属性</a>', var_name);
            fprintf('%s\n\n', link_text);
        end
        
        function sys = tf(obj)
            %TF 将 PID 控制器转换为传递函数
            
            if obj.Ts == 0
                % 连续时间
                if obj.Tf == 0
                    if obj.Ki == 0 && obj.Kd == 0
                        num = obj.Kp;
                        den = 1;
                    elseif obj.Kd == 0
                        num = [obj.Kp, obj.Ki];
                        den = [1, 0];
                    elseif obj.Ki == 0
                        num = [obj.Kd, obj.Kp];
                        den = 1;
                    else
                        num = [obj.Kd, obj.Kp, obj.Ki];
                        den = [1, 0];
                    end
                else
                    num = [(obj.Kp*obj.Tf + obj.Kd), ...
                           (obj.Kp + obj.Ki*obj.Tf), ...
                           obj.Ki];
                    den = [obj.Tf, 1, 0];
                end
                sys = tf_zzy(num, den);
                
            else
                % 离散时间 - 使用 ForwardEuler 作为默认方法
                num_p = obj.Kp;
                den_p = 1;
                
                % 积分部分: Ki * Ts/(z-1)
                if obj.Ki ~= 0
                    if strcmp(obj.IFormula, 'ForwardEuler')
                        num_i = obj.Ki * obj.Ts;
                        den_i = [1, -1];
                    elseif strcmp(obj.IFormula, 'BackwardEuler')
                        num_i = obj.Ki * obj.Ts * [1, 0];
                        den_i = [1, -1];
                    else % Trapezoidal
                        num_i = obj.Ki * obj.Ts * [1, 1] / 2;
                        den_i = [1, -1];
                    end
                else
                    num_i = 0;
                    den_i = 1;
                end
                
                % 微分部分: Kd * N*(z-1)/z 或 Kd * N*(z-1)/(z+(N-1))
                if obj.Kd ~= 0
                    if obj.Tf == 0
                        N = Inf;
                        num_d = obj.Kd * [1, -1];
                        den_d = obj.Ts;
                    else
                        N = obj.Tf / obj.Ts;
                        if strcmp(obj.DFormula, 'Trapezoidal')
                            num_d = obj.Kd * N * [1, -1];
                            den_d = [1, N-1];
                        else % ForwardEuler or BackwardEuler
                            num_d = obj.Kd * N * [1, -1];
                            den_d = [1, 0];
                        end
                    end
                else
                    num_d = 0;
                    den_d = 1;
                end
                
                % 合并 P + I
                num1 = conv(num_p, den_i) + conv(num_i, den_p);
                den1 = conv(den_p, den_i);
                
                % 合并 (P+I) + D
                num_final = conv(num1, den_d) + conv(num_d, den1);
                den_final = conv(den1, den_d);
                
                num_final = removeLeadingZeros(num_final);
                den_final = removeLeadingZeros(den_final);
                
                sys = tf_zzy(num_final, den_final, obj.Ts);
            end
        end
        
        function sys = c2d(obj, Ts, method)
            %C2D 将连续时间 PID 转换为离散时间 PID
            
            if nargin < 3
                method = 'tustin';
            end
            
            if obj.Ts > 0
                error('pid_zzy:AlreadyDiscrete', '控制器已经是离散时间的');
            end
            
            sys = pid_zzy(obj.Kp, obj.Ki, obj.Kd, obj.Tf, Ts);
            
            switch lower(method)
                case {'tustin', 'trapezoidal'}
                    sys.IFormula = 'Trapezoidal';
                    sys.DFormula = 'Trapezoidal';
                case 'forward'
                    sys.IFormula = 'ForwardEuler';
                    sys.DFormula = 'ForwardEuler';
                case 'backward'
                    sys.IFormula = 'BackwardEuler';
                    sys.DFormula = 'BackwardEuler';
                otherwise
                    warning('pid_zzy:UnknownMethod', '未知方法，使用默认前向欧拉法');
                    sys.IFormula = 'ForwardEuler';
                    sys.DFormula = 'ForwardEuler';
            end
            
            sys.Name = obj.Name;
            sys.InputName = obj.InputName;
            sys.OutputName = obj.OutputName;
            sys.Notes = obj.Notes;
            sys.UserData = obj.UserData;
        end
    end
end

function v = removeLeadingZeros(v)
    if isempty(v)
        v = 0;
        return;
    end
    idx = find(abs(v) > eps*100, 1, 'first');
    if isempty(idx)
        v = 0;
    else
        v = v(idx:end);
    end
end