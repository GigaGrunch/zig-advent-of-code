const std = @import("std");

pub fn build(b: *std.Build) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const run_all_step = b.step("run", "Run all days");
    const test_all_step = b.step("test", "Tests all days");

    const utils = b.createModule(.{
        .source_file = .{ .path = "lib/utils.zig" },
    });

    const years: []const []const u8 = &.{ "2015", "2023" };
    for (years) |year| {
        var dir = try std.fs.cwd().openIterableDir(year, .{});
        var dir_it = dir.iterate();
        while (try dir_it.next()) |entry| {
            var source_path = std.ArrayList(u8).init(gpa.allocator());
            defer source_path.deinit();
            try source_path.writer().print("{s}/{s}/{s}.zig", .{ year, entry.name, entry.name });

            var exe_name = std.ArrayList(u8).init(gpa.allocator());
            defer exe_name.deinit();
            try exe_name.writer().print("{s}.{s}", .{ year, entry.name });

            var input_path = std.ArrayList(u8).init(gpa.allocator());
            defer input_path.deinit();
            try input_path.writer().print("{s}/{s}/input.txt", .{ year, entry.name });

            var tests_name = std.ArrayList(u8).init(gpa.allocator());
            defer tests_name.deinit();
            try tests_name.writer().print("{s}.{s}.test", .{ year, entry.name });

            const exe = b.addExecutable(.{
                .name = exe_name.items,
                .root_source_file = .{ .path = source_path.items },
                .target = target,
                .optimize = optimize,
            });
            exe.addModule("utils", utils);

            b.installArtifact(exe);
            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());
            run_cmd.addArg(input_path.items);

            const run_step = b.step(exe_name.items, "");
            run_step.dependOn(&run_cmd.step);
            run_all_step.dependOn(&run_cmd.step);

            const unit_tests = b.addTest(.{
                .root_source_file = .{ .path = source_path.items },
                .target = target,
                .optimize = optimize,
            });
            unit_tests.addModule("utils", utils);
            const run_unit_tests = b.addRunArtifact(unit_tests);
            test_all_step.dependOn(&run_unit_tests.step);
        }
    }
}
