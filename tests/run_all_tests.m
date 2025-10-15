% filepath: tests/run_all_tests.m
% 批量运行 tests 文件夹下所有 .mlx 实时脚本（桌面 MATLAB 专用）

disp('========== 开始批量运行所有测试 ==========');

files = dir(fullfile(pwd, '*.mlx'));

for i = 1:length(files)
    fname = files(i).name;
    fprintf('\n------ 正在运行 %s ------\n', fname);
    try
        matlab.desktop.editor.openAndExecute(fullfile(pwd, fname));
        fprintf('✓ %s 已提交运行\n', fname);
    catch ME
        fprintf('✗ %s 测试失败: %s\n', fname, ME.message);
    end
end

disp('========== 所有测试运行结束 ==========');